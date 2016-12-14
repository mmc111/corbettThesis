//
//  GameViewController.swift
//  MathGame
//
//  Created by Megan Corbett
//  Copyright (c) 2015 Megan Corbett. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    //create Sprite Kit scene and present it in SKView
    var scene: GameScene!
    var level: Level!
    
    var completionTime = ""
    
    var seconds = 0
    
    var numbers: Array<Number> = []
    var timer = NSTimer()
    
    var needToShuffle = false
    //var clearOperator:Bool = false
    var currentlyDropping = false
    var handlingSwipe: Bool = false
    var challengeModeFirstPlay: Bool = false
    var pauseDropTimer = false
    
    let fixedMindsetGameplay = false
    let growthMindsetGameplay = true
    
    let maxRowsFilled = 8
    var dropSeconds = 10
    let dropSecondsModifier = 1
    
    var userID = 1
    
    let fullLevel = 1
    let fixedLevel = 2
    let challengeLevel = 3
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    @IBOutlet weak var agreeToPlayButton: UIButton!
    @IBOutlet weak var fullPlayThroughButton: UIButton!
    @IBOutlet weak var additionFocus: UIButton!
    @IBOutlet weak var subFocus: UIButton!
    @IBOutlet weak var multFocus: UIButton!
    @IBOutlet weak var divFocus: UIButton!
    @IBOutlet weak var mainMenuButton: UIButton!
    @IBOutlet weak var challengeModeButton: UIButton!
    @IBOutlet weak var playAgainButton: UIButton!
    
    @IBOutlet weak var mainMenuLabel: UILabel!
    @IBOutlet weak var focusLabel: UILabel!
    
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var correctDescr: UILabel!
    @IBOutlet weak var scoreDescr: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var messageImage: UIImageView!
    @IBOutlet weak var assentText: UITextView!
    
    @IBOutlet weak var completionTimeLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var displayHighScore: UILabel!
    @IBOutlet weak var displayCompletionTime: UILabel!
    @IBOutlet weak var displayScoreLabel: UILabel!
    @IBOutlet weak var displayScoreDescr: UILabel!
    
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var timerDescr: UILabel!
    
    @IBOutlet var progressView: UIProgressView!
    
    @IBOutlet var idDescr: UILabel!
    @IBOutlet var idLabel: UILabel!
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //configure the view
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        
        //create and configure the scene
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill //set scale mode to scale to fit the window
        
        //create level instance
        level = Level()
        scene.level = level
        
        scene.swipeHandler = handleSwipe
        
        hideMainMenu()
        
        hideMessageElements()
        
        hideGamePlayElements()
        
        mainMenuButton.hidden = true
        
        playAgainButton.hidden = true
        
        agreeToPlayButton.hidden = false
        
        //present scene
        skView.presentScene(scene)
    }
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    
    //function to reset/update board after gameplay has begun, call in viewDidLoad()
    func startNewChallenge() {
        
        if level.getLevelType() != challengeLevel {
            level.resetLevel()
            completionTime = ""
            progressView.progress = 0.0
            seconds = 0
        } else {
            
            progressView.progress = 100.0
        }
        
        handlingSwipe = false
        //clear board (if new level, operator(s) will be cleared from board)
        
        //self.scene.animateClearBoard() {
            //self.clearOperator = false
            
            self.showGamePlayElements()
        
            let initEquations = self.level.firstFill()
            
            self.scene.addSpritesForNumbers(initEquations)
            if self.challengeModeFirstPlay || self.level.getLevel() > -5 {
                
                self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(GameViewController.addTime), userInfo: nil, repeats: true)

                self.updateLabels()
                self.challengeModeFirstPlay = false
            }
            self.scene.animateShuffle(self.level.shuffleBoard()){
                
                self.view.userInteractionEnabled = true
                self.level.setCanDraw(true)
                self.updateLabels()
                self.pauseDropTimer = false
                if self.level.getLevelType() == self.challengeLevel {
                    self.progressView.progressTintColor = UIColor .greenColor()
                    self.messageImage.hidden = true
                }
                self.mainMenuButton.hidden = false
                self.mainMenuButton.enabled = true
            }
            
        //}
        
    }
    
    func addTime() {
        
        seconds = seconds + 1
        
        let timeString = getTimeString(seconds)
        timerLabel.text = timeString
        //timerLabel.text = "\(seconds)"
        
        //can impose time limit here
        //base drop seconds on how full board is, drop less often if board is full
        
        if(seconds%dropSeconds == 0 && seconds > 0 && level.getCurrentRowsFilled() < maxRowsFilled && !handlingSwipe && !scene.getTouchingBoard()) && !pauseDropTimer { //this line makes it so that new rows are dropped only!! when the user is not touching
        
        //if(seconds%dropSeconds == 0 && seconds > 0 && level.getCurrentRowsFilled() < maxRowsFilled && !handlingSwipe) {
            currentlyDropping = true
            view.userInteractionEnabled = false
            let newSet = level.addNewRows(1)
            scene.animateNewDrop(newSet) {
                //check if at max for challenge mode game over
                if self.level.getLevelType() == self.challengeLevel && self.level.getCurrentRowsFilled() == self.maxRowsFilled {
                    self.timer.invalidate()
                    self.challengeGameOver()
                } else if !self.handlingSwipe && self.level.getCurrentRowsFilled() > 1 { //only shuffle if still not hanlding swipe, else wait till swipe is handled
                        let newColumns = self.level.shuffleBoard()
                        self.scene.animateShuffle(newColumns) {
                            if self.level.getLevelType() == self.challengeLevel && self.dropSeconds > 1 {
                                self.dropSeconds = self.dropSeconds - self.dropSecondsModifier
                            }
                            self.currentlyDropping = false
                            self.view.userInteractionEnabled = true
                        }
                } else {
                    self.currentlyDropping = false
                }
            }
        }
    }
    
    func getTimeString(seconds: Int) -> String {
        
        var timeString:String = ""
        var minutes = 0
        var sec = 0
        var secString = ""
        
        if seconds < 60 {
            if seconds < 10 {
                secString = "0\(seconds)"
            }
            else {
                secString = "\(seconds)"
            }
            timeString = "0: \(secString)"
        }
        else {
            minutes = seconds/60
            sec = seconds%60
            if sec < 10 {
                secString = "0\(sec)"
            }
            else {
                secString = "\(sec)"
            }
            timeString = "\(minutes): \(secString)"
        }
        return timeString
    }
    
    
    func updateLabels() {
        //update labels to show the correct score and number of correct swipes, called only after a correct swipe
        correctLabel.text = String(format: "%ld", level.getCorrectTotal())
        scoreLabel.text = String(format: "%ld", level.getScore())
    }
    
    
    func handleSwipe(number: Array<Number>)
    {
        handlingSwipe = true
        numbers = number
        if number.count > 4 || number.count < 4 {
            handlingSwipe = false
            return
        }
        
        //disable play
        view.userInteractionEnabled = false
        
        if level.isValidEquation(number) {
            
            progressView.progressTintColor = UIColor .greenColor()
            
            if level.getLevelType() != challengeLevel {
                progressView.setProgress(progressView.progress+0.10, animated: true)
            } else {
                if progressView.progress < 100.0 {
                    progressView.setProgress(100.0, animated: true)
                }
            }
            scene.showCorrectIndicator(number)
            //let delay = 0.05
            let delay = 1.2
            NSTimer.scheduledTimerWithTimeInterval(delay, target: self, selector: #selector(GameViewController.autoDelaySwipes), userInfo: nil, repeats: false)
        } else {
            progressView.progressTintColor = UIColor .redColor()
            if level.getLevelType() != challengeLevel {
              //  progressView.setProgress(0.0, animated: true)
            } else {
                progressView.setProgress(progressView.progress-0.20, animated: true)
                progressView.progressTintColor = UIColor .greenColor()
            }
            
            scene.showIncorrectIndicator(number)
            let delay = 0.05
            NSTimer.scheduledTimerWithTimeInterval(delay, target: self, selector: #selector(GameViewController.autoDelaySwipes), userInfo: nil, repeats: false)
        }
        
        //delay handling of swipes in case drop is called at exact same time
        //allows currently dropping variable to be set before continuing, which allows the animation of swipes to be delayed until the new row is finished dropping (or else there will be errors in the game board)
    }
    
    func autoDelaySwipes() {
        if currentlyDropping {
            let delay = scene.getDuration()
            NSTimer.scheduledTimerWithTimeInterval(delay, target: self, selector: #selector(GameViewController.handleMatches), userInfo: nil, repeats: false)
        } else if seconds%dropSeconds == 0 && seconds > 0 {
            //automatically delay for a full drop time
            let delay = 0.25
            NSTimer.scheduledTimerWithTimeInterval(delay, target: self, selector: #selector(GameViewController.handleMatches), userInfo: nil, repeats: false)
        } else {
            handleMatches()
        }
    }
    
    
    func handleMatches() {
        
        if level.isValidEquation(numbers) {

            level.removeNumbers(self.numbers) //removes numbers from game board
            
            scene.animateCorrectEquation(self.numbers) //removes sprites
            {
                
                let columns = self.level.dropDownExisting()
                
                self.scene.animateNumberDrop(columns) {
                    if self.level.getLevelType() == self.challengeLevel && self.dropSeconds < 10 {
                        self.dropSeconds = self.dropSeconds + self.dropSecondsModifier
                    }
                    //correct drop has been animated, need to check for level changes
                    //allow user to continue until drops to zero equations on board
                    
                    //update score and number correct
                    let showGrowth = self.level.handleCorrectMatch()
                    
                    //update score, correct and labels everytime a match has been made
                    self.updateLabels()
                    
                    //growth mindset message
                    //check for level changes

                    if self.level.checkLevelChange() {
                        //level or difficulty needs to change
                        self.dropSeconds = 10
                        //update and post? progress
                        self.level.updateProgress(self.seconds)
                        //self.clearOperator = self.level.changeLevel()
                        self.level.changeLevel()
                        if self.level.getLevelType() == self.challengeLevel {
                            
                            self.level.addTimeBonus(self.seconds)
                            self.pauseDropTimer = true
                            //display visual that level is complete
                            self.messageImage.image = UIImage(named:"checkMark.png")
                            self.messageImage.hidden = false
                            self.scene.animateClearBoard {
                                self.startNewChallenge()
                            }
                            
                        } else {
                            self.timer.invalidate()
                            self.completionTime = self.getTimeString(self.seconds)
                            self.scene.animateClearBoard{
                               self.showMessagePanel()
                            }
                        }
                        self.level.addTimeBonus(self.seconds)
                    }
                    
                    let invalidResults = self.level.invalidNumbers()
                    
                    if invalidResults {
                        self.scene.drawNumberChanges()
                    }
                    
                    //check if need to show growth solution
                    if showGrowth {
                        self.showGrowthSolution()
                        self.needToShuffle = true
                    } else if self.level.getCurrentRowsFilled() > 1 { //always shuffle to hide new valid results as long as there is at least two rows
                        let columns = self.level.shuffleBoard()
                        self.scene.animateShuffle(columns) {
                            self.needToShuffle = false
                            self.handlingSwipe = false
                            self.view.userInteractionEnabled = true
                     
                        }
                     } else {
                    
                        self.handlingSwipe = false
                        self.view.userInteractionEnabled = true
                    }
                }
            }
            
        } else {
            
            scene.fadeIncorrectIndicator(numbers){
                
                self.level.updateIncorrect()
                if self.level.getIncorrectChain() >= 5 && self.level.getLevelType() == self.challengeLevel {
                    self.timer.invalidate()
                    self.challengeGameOver()
                } else if self.level.getCurrentRowsFilled() < self.maxRowsFilled {
                    
                    //it's ok to add a new row, haven't reached top yet
                    let newSet = self.level.addNewRows(1)
                    self.scene.animateNewDrop(newSet) {
                        if self.level.getLevelType() == self.challengeLevel && self.level.getCurrentRowsFilled() == self.maxRowsFilled{
                            self.timer.invalidate()
                            self.challengeGameOver()
                        } else {
                            let newColumns = self.level.shuffleBoard() //shuffle after new row has dropped
                            self.scene.animateShuffle(newColumns) {
                                //self.updateProgress()
                                if self.level.getLevelType() == self.challengeLevel && self.dropSeconds > 1 {
                                    self.dropSeconds = self.dropSeconds - self.dropSecondsModifier
                                }
                                self.handlingSwipe = false
                                self.view.userInteractionEnabled = true
                            }
                        }
                    }
                } else {
                    //not okay to drop (at top)
                    self.handlingSwipe = false
                    self.view.userInteractionEnabled = true
                    
                    //if fixed mindset, level will regress if there is a chain of at least 3 incorrect swipes and board is full
                    if self.fixedMindsetGameplay {
                        if self.level.getIncorrectChain() > 3 {
                            self.level.regressLevel()
                        }
                    }
                }
            }
        }
    }
    
    
    func showBeginMessage(){
        level.setCanDraw(false)
        
        agreeToPlayButton.hidden = true
        
        timerLabel.text = "0: 00"
        
        showGamePlayElements()
        
        mainMenuButton.enabled = false
        mainMenuButton.hidden = false
        
        updateLabels()
        
        //brief informational message only to be shown at the beginning of game play
        messageImage.image = UIImage(named:"startImage.png")
        scene.userInteractionEnabled = true
        messageImage.hidden = false
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(self.hideBeginMessage))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func hideBeginMessage() {
        view.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
        
        messageImage.hidden = true
        scene.userInteractionEnabled = true
        level.setCanDraw(true)
        self.startNewChallenge()
        
    }
    
    func showMessagePanel() {
        level.setCanDraw(false)
        mainMenuButton.enabled = false
        
        getMessageForMessagePanel()
        scoreLabel.text = "\(level.getScore())"
        displayScoreLabel.text = "\(level.getScore())"
        
        if level.getLevelType() == challengeLevel {
            displayHighScore.text = "\(level.getChallengeHighScore())"
        } else {
           displayHighScore.text = "\(level.getHighScore())"
        }
        
        displayCompletionTime.text = "\(completionTime)"
        idLabel.text = " \(userID)"
        idDescr.text = "ID: "

        showMessageElements()
        
        scene.userInteractionEnabled = true

        
        if level.getLevelType() != challengeLevel {
            self.tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(self.hideMessagePanel))
            view.addGestureRecognizer(tapGestureRecognizer)
        } else {
            view.userInteractionEnabled = true
            playAgainButton.hidden = false
            mainMenuButton.hidden = false
            mainMenuButton.enabled = true
        }
    }
    
    
    func hideMessagePanel() {
        view.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
        hideMessageElements()
        messageImage.hidden = true
        scene.userInteractionEnabled = true
        level.setCanDraw(true)
        startNewChallenge()
    }
    
    
    func showGrowthSolution(){
        
        //took at least 3 swipes to get a match after the board was full
        //show praise message for growth mindset
        //scene.userInteractionEnabled = true
        messageImage.image = UIImage(named:"growthSolution.png")
        
        messageImage.hidden = false
        level.setCanDraw(false)
        mainMenuButton.enabled = false
        scene.userInteractionEnabled = true
        view.userInteractionEnabled = true
        tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(self.hideGrowthSolution))
        view.addGestureRecognizer(tapGestureRecognizer)
    
        //scene.userInteractionEnabled = true
    }
    
    func hideGrowthSolution() {
        level.setCanDraw(true)
        
        view.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
        messageImage.hidden = true
        if self.level.getCurrentRowsFilled() > 1 && needToShuffle == true { //always shuffle to hide new valid results
            let columns = self.level.shuffleBoard()
            self.scene.animateShuffle(columns) {
                self.needToShuffle = false
                self.mainMenuButton.enabled = true
                self.view.userInteractionEnabled = true
                self.messageImage.hidden = true
                self.handlingSwipe = false
                
                self.scene.userInteractionEnabled = true
                
            }
        } else {
            self.needToShuffle = false
            mainMenuButton.enabled = true
            view.userInteractionEnabled = true
            messageImage.hidden = true
            handlingSwipe = false
            
            scene.userInteractionEnabled = true
        }
        
    }
    
    func showMainMenu() {
        
        mainMenuButton.hidden = true
        hideMessageElements()
        hideGamePlayElements()
        
        agreeToPlayButton.hidden = true
        fullPlayThroughButton.hidden = false
        challengeModeButton.hidden = false
        additionFocus.hidden = false
        subFocus.hidden = false
        multFocus.hidden = false
        divFocus.hidden = false
        mainMenuLabel.hidden = false
        focusLabel.hidden = false
        
        view.userInteractionEnabled = true
        scene.userInteractionEnabled = true
        
        level.setCanDraw(false)
    }
    
    
    func hideGamePlayElements() {
        
        timerDescr.hidden = true
        timerLabel.hidden = true
        correctDescr.hidden = true
        scoreDescr.hidden = true
        correctLabel.hidden = true
        scoreLabel.hidden = true
        progressView.hidden = true
    }
    
    func showGamePlayElements() {
        timerDescr.hidden = false
        timerLabel.hidden = false
        correctDescr.hidden = false
        scoreDescr.hidden = false
        correctLabel.hidden = false
        scoreLabel.hidden = false
        progressView.hidden = false
    }
    
    func hideMessageElements() {
        displayHighScore.hidden = true
        highScoreLabel.hidden = true
        
        displayScoreDescr.hidden = true
        displayScoreLabel.hidden = true
        
        completionTimeLabel.hidden = true
        displayCompletionTime.hidden = true
        messageImage.hidden = true
        
        idLabel.hidden = true
        idDescr.hidden = true
    }
    
    func showMessageElements() {
        displayHighScore.hidden = false
        highScoreLabel.hidden = false
        
        displayScoreDescr.hidden = false
        displayScoreLabel.hidden = false
        
        completionTimeLabel.hidden = false
        displayCompletionTime.hidden = false
        messageImage.hidden = false
        
        idLabel.hidden = false
        idDescr.hidden = false
    }
    
    func hideMainMenu() {
        fullPlayThroughButton.hidden = true
        challengeModeButton.hidden = true
        additionFocus.hidden = true
        subFocus.hidden = true
        multFocus.hidden = true
        divFocus.hidden = true
        mainMenuLabel.hidden = true
        focusLabel.hidden = true
        level.setCanDraw(true)
    }
    
    @IBAction func fullButtonPressed(_: AnyObject) {
        
        level.setLevelType(fullLevel)
        hideMainMenu()
        showBeginMessage()
    }
    
    @IBAction func challengeButtonPressed(_: AnyObject) {
        challengeModeFirstPlay = true
        level.setLevelType(challengeLevel)
        level.setLevel(-5)
        level.setDifficulty(1)
        hideMainMenu()
        startNewChallenge()
    }
    
    @IBAction func addButtonPressed(_: AnyObject) {
        level.setLevelType(fixedLevel)
        level.setLevel(-1)
        level.setDifficulty(1)
        hideMainMenu()
        startNewChallenge()
    }
    
    @IBAction func subButtonPressed(_: AnyObject) {
        level.setLevelType(fixedLevel)
        level.setLevel(-2)
        level.setDifficulty(1)
        hideMainMenu()
        startNewChallenge()
    }
    
    @IBAction func multButtonPressed(_: AnyObject) {
        level.setLevelType(fixedLevel)
        level.setLevel(-3)
        level.setDifficulty(1)
        hideMainMenu()
        startNewChallenge()
    }
    
    @IBAction func divButtonPressed(_: AnyObject) {
        level.setLevelType(fixedLevel)
        level.setLevel(-4)
        level.setDifficulty(1)
        hideMainMenu()
        startNewChallenge()
    }
    
    @IBAction func playAgainButtonPressed(_: AnyObject) {
        seconds = 0
        dropSeconds = 10
        hideMessageElements()
        level.setLevel(-5)
        level.setDifficulty(1)
        level.resetLevel()
        playAgainButton.hidden = true
        challengeModeFirstPlay = true
        startNewChallenge()
    }
    @IBAction func mainMenuButtonPressed(_: AnyObject) {
        level.updateProgress(seconds)
        postProgress()
        dropSeconds = 10

        view.userInteractionEnabled = false
        scene.userInteractionEnabled = false
        
        //if there's anything on the board, clear it
        //disable menu button if there's an image currently showing

        if seconds%dropSeconds == 0 || currentlyDropping == true {
            timer.invalidate()
            seconds = 0
            let delay = 1.0
            NSTimer.scheduledTimerWithTimeInterval(delay, target: self, selector: #selector(GameViewController.clearBoard), userInfo: nil, repeats: false)
        }
        else if level.getCurrentRowsFilled() > 0 {
            timer.invalidate()
            seconds = 0
            scene.animateClearBoard() {
                self.showMainMenuFromButton()
            }
        } else {
            timer.invalidate()
            seconds = 0
            showMainMenuFromButton()
        }
        
    }
    
    @IBAction func agreeToPlayButtonPressed(_: AnyObject) {
        //set user id here
        getID()
        agreeToPlayButton.hidden = true
        assentText.hidden = true
        scene.removeStartBackground()
        
        showMainMenu()
    }
    
    func clearBoard() {
        //if new row has dropped after delay, make sure its done dropping then continue
        if level.getCurrentRowsFilled() > 0 {
            let delay2 = 0.75
            NSTimer.scheduledTimerWithTimeInterval(delay2, target: self, selector: #selector(GameViewController.showMainMenuFromButton), userInfo: nil, repeats: false)
        } else {
            showMainMenuFromButton()
        }
    }
    
    func showMainMenuFromButton() {
        //update and post progress
        level.setDifficulty(1)
        level.setLevel(-1)
        hideMessageElements()
        seconds = 0
        level.resetGame()
        //clearOperator = false
        playAgainButton.hidden = true
        mainMenuButton.hidden = true
        level.setCanDraw(false)
        showMainMenu()
    }
    
    
    func challengeGameOver() {
        //logic for ending game, displaying message, display play again and main menu buttons, display user ID
        //create array with information including longest correct chain, post it
        level.updateProgress(seconds)
        postProgress()
        self.scene.animateClearBoard() {
            self.completionTime = self.getTimeString(self.seconds)
            self.getMessageForMessagePanel()
            self.showMessagePanel()
        }
        
    }
    
    
    func postProgress() {
        
        let url = NSURL(string: "http://avisss.com/recorddata.php?id=\(userID)&data=randomDataString")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"

        let postString = level.getProgressString()
        //print(postString)
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        //let session = NSURLSession(configuration: config)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request)  {
            (data, response, error) in
            if error != nil {
                print("error: \(error)")
                return
            }
            if let httpStatus = response as? NSHTTPURLResponse {
            
                if httpStatus.statusCode != 200 {
                    print("status code is: \(httpStatus.statusCode)")
                    print("response: \(response)")
                }
            }
            
            let responseString = String(data: data!, encoding: NSUTF8StringEncoding)
            print("response string: \(responseString)")
        }
        task.resume()
        
    }
    
    func getID() {
        let url = NSURL(string: "http://avisss.com/sequence.php")!
        let request = NSMutableURLRequest(URL: url)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            if error != nil {
                print("error: \(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse {
                
                if httpStatus.statusCode != 200 {
                    print("status code is: \(httpStatus.statusCode)")
                    print("response: \(response)")
                    self.userID = 1
                } else {
                    let responseString = String(data: data!, encoding: NSUTF8StringEncoding)
                    
                    self.userID = Int(responseString!)!
                    self.level.setUserID(self.userID)
                    print("response string: \(responseString)")
                }
            }
            
        }
        task.resume()
    }
    
    func getMessageForMessagePanel() {
        // sets message panel to correct message
        if level.isLoop() {
            messageImage.image = UIImage(named:"loopImage.png")
        } else if level.getLevelType() == challengeLevel {
            
            messageImage.image = UIImage(named:"gameOver.png")
        
        } else {
            switch level.getDifficulty()
            {
            case 1:
                if level.getLevel() == -1 {
                    messageImage.image = UIImage(named:"loopImage.png")
                } else if level.getLevel() == -2 {
                    if growthMindsetGameplay {
                        messageImage.image = UIImage(named:"growthSubLevelChange.png")
                    } else {
                        messageImage.image = UIImage(named: "fixedSubLevelChange.png")
                    }
                } else if level.getLevel() == -3 {
                    if growthMindsetGameplay {
                        messageImage.image = UIImage(named:"growthMultLevelChange.png")
                    } else {
                        messageImage.image = UIImage(named: "fixedMultLevelChange.png")
                    }
                } else if level.getLevel() == -4 {
                    if growthMindsetGameplay {
                        messageImage.image = UIImage(named:"growthDivLevelChange.png")
                    } else {
                        messageImage.image = UIImage(named: "fixedDivLevelChange.png")
                    }
                }
            case 2:
                if level.getLevel() == -1 {
                    if growthMindsetGameplay {
                        messageImage.image = UIImage(named:"growthDiffChange.png")
                    } else {
                        messageImage.image = UIImage(named: "fixedDiffChange.png")
                    }
                } else if level.getLevel() == -2 {
                    if growthMindsetGameplay {
                        messageImage.image = UIImage(named:"growthDiffChange.png")
                    } else {
                        messageImage.image = UIImage(named: "fixedDiffChange.png")
                    }
                } else if level.getLevel() == -3 {
                    if growthMindsetGameplay {
                        messageImage.image = UIImage(named:"growthDiffChange.png")
                    } else {
                        messageImage.image = UIImage(named: "fixedDiffChange.png")
                    }
                } else if level.getLevel() == -4 {
                    if growthMindsetGameplay {
                        messageImage.image = UIImage(named:"growthDiffChange.png")
                    } else {
                        messageImage.image = UIImage(named: "fixedDiffChange.png")
                    }
                }
            case 3:
                if level.getLevel() == -1 {
                    if growthMindsetGameplay {
                        messageImage.image = UIImage(named:"growthDiffChange.png")
                    } else {
                        messageImage.image = UIImage(named: "fixedDiffChange.png")
                    }
                } else if level.getLevel() == -2 {
                    if growthMindsetGameplay {
                        messageImage.image = UIImage(named:"growthDiffChange.png")
                    } else {
                        messageImage.image = UIImage(named: "fixedDiffChange.png")
                    }
                } else if level.getLevel() == -3 {
                    if growthMindsetGameplay {
                        messageImage.image = UIImage(named:"growthDiffChange.png")
                    } else {
                        messageImage.image = UIImage(named: "fixedDiffChange.png")
                    }
                } else if level.getLevel() == -4 {
                    if growthMindsetGameplay {
                        messageImage.image = UIImage(named:"growthDiffChange.png")
                    } else {
                        messageImage.image = UIImage(named: "fixedDiffChange.png")
                    }
                }
            default:
                print("default showMessage")
            }
        }
    }
}
