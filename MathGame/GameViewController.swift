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
    
    var score = 0
    var correct = 0
    var correctChain = 0
    
    var completionTime = ""
    
    var seconds = 0
    
    var highScore = 0
    
    var numbers: Array<Number> = []
    var timer = NSTimer()
    
    var needToShuffle = false
    
    //progress tracking variables to be stored in array as game progresses
    var progress: [[Int]] = [[]]
    var currentProgress: [Int] = []
    var progressUpdate = 0
    
    var clearOperator:Bool = false
    var currentlyDropping = false
    
    var incorrectChain = 0
    
    let maxRowsFilled = 8
    
    let maxScore = 300
    
    let defaultDropSeconds = 10
    var dropSeconds = 10
    
    let fixedMindsetGameplay = false
    let growthMindsetGameplay = true
    
    var handlingSwipe: Bool = false
    
    let dropDuration = 1.5
    
    var loop: Bool = false
    var count = 0
    
    var isFixedLevel: Bool = false
    
    @IBOutlet weak var agreeToPlayButton: UIButton!
    @IBOutlet weak var fullPlayThroughButton: UIButton!
    @IBOutlet weak var additionFocus: UIButton!
    @IBOutlet weak var subFocus: UIButton!
    @IBOutlet weak var multFocus: UIButton!
    @IBOutlet weak var divFocus: UIButton!
    @IBOutlet weak var mainMenuButton: UIButton!
    
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
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    @IBAction func agreeToPlayButtonPressed(_: AnyObject) {
        //move to login storyboard
        agreeToPlayButton.hidden = true
        assentText.hidden = true
        scene.removeStartBackground()
        
        //showBeginMessage()
        showMainMenu()
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
        
        messageImage.hidden = true
        timerLabel.hidden = true
        correctDescr.hidden = true
        scoreDescr.hidden = true
        correctLabel.hidden = true
        scoreLabel.hidden = true
        
        displayHighScore.hidden = true
        highScoreLabel.hidden = true
        
        displayScoreDescr.hidden = true
        displayScoreLabel.hidden = true
        
        completionTimeLabel.hidden = true
        displayCompletionTime.hidden = true
        
        mainMenuButton.hidden = true
        
        timerDescr.hidden = true
        
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
    
    func beginGame() {
        
        timerLabel.text = "0: 00"
        
        timerLabel.hidden = false
        timerDescr.hidden = false
        correctDescr.hidden = false
        scoreDescr.hidden = false
        correctLabel.hidden = false
        scoreLabel.hidden = false
        
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(GameViewController.addTime), userInfo: nil, repeats: true)
        
        updateLabels()
        
        let initEquations = level.firstFill()
        self.level.shuffleBoard()
        scene.addSpritesForNumbers(initEquations)
        //mainMenuButton.hidden = false
    }
    
    //function to reset/update board after gameplay has begun, call in viewDidLoad()
    func startNewChallenge() {
        
        score = 0
        correct = 0
        seconds = 0
        correctChain = 0
        completionTime = ""
        
        
        
        
        //clear board
        //if new level, clear operator from the board
        self.scene.animateClearBoard(clearOperator)
        clearOperator = false
        
        displayHighScore.hidden = true
        highScoreLabel.hidden = true
        
        displayScoreDescr.hidden = true
        displayScoreLabel.hidden = true
        
        completionTimeLabel.hidden = true
        displayCompletionTime.hidden = true
        timerLabel.text = "0: 00"
        
        timerLabel.hidden = false
        timerDescr.hidden = false
        correctDescr.hidden = false
        scoreDescr.hidden = false
        correctLabel.hidden = false
        scoreLabel.hidden = false
        
        
        updateLabels()
        
        
        let initEquations = level.firstFill()
        scene.addSpritesForNumbers(initEquations)
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(GameViewController.addTime), userInfo: nil, repeats: true)
        
        scene.animateShuffle(level.shuffleBoard()){
            self.mainMenuButton.hidden = false
            self.view.userInteractionEnabled = true
        }
    }
    
    func addTime() {
        
        seconds = seconds + 1
        
        let timeString = getTime(seconds)
        timerLabel.text = timeString
        //timerLabel.text = "\(seconds)"
        
        //can impose time limit here
        //base drop seconds on how full board is, drop less often if board is full
        
        /*if level.getCurrentRowsFilled() < 5 {
         dropSeconds = 10
         }
         else {
         dropSeconds = 20
         }*/
        
        if(seconds%dropSeconds == 0 && seconds > 0 && level.getCurrentRowsFilled() < maxRowsFilled && !handlingSwipe && !scene.getTouchingBoard()) { //this line makes it so that new rows are dropped only!! when the user is not touching
        
        //if(seconds%dropSeconds == 0 && seconds > 0 && level.getCurrentRowsFilled() < maxRowsFilled && !handlingSwipe) {
            currentlyDropping = true
            view.userInteractionEnabled = false
            let newSet = level.addNewRows(1)
            scene.animateNewDrop(newSet) {
                
                if !self.handlingSwipe && self.level.getCurrentRowsFilled() > 1 { //only shuffle if still not hanlding swipe, else wait till swipe is handled
                    let newColumns = self.level.shuffleBoard()
                    self.scene.animateShuffle(newColumns) {
                        self.currentlyDropping = false
                        self.view.userInteractionEnabled = true
                    }
                }
                else{
                    self.currentlyDropping = false
                }
            }
        }
    }
    
    func getTime(seconds: Int) -> String {
        
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
        correctLabel.text = String(format: "%ld", correct)
        scoreLabel.text = String(format: "%ld", score)
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
        
        //handleSwipes(number)
        if level.isValidEquation(number) {
            scene.showCorrectIndicator(number)
        } else {
            scene.showIncorrectIndicator(number)
        }
        
        //delay handling of swipes in case drop is called at exact same time
        //allows currently dropping variable to be set before continuing, which allows the animation of swipes to be delayed until the new row is finished dropping (or else there will be errors in the game board)
        let delay = 0.05
        NSTimer.scheduledTimerWithTimeInterval(delay, target: self, selector: #selector(GameViewController.autoDelaySwipes), userInfo: nil, repeats: false)
        
    }
    
    func autoDelaySwipes() {
        if currentlyDropping {
            let delay = scene.getDuration()
            NSTimer.scheduledTimerWithTimeInterval(delay, target: self, selector: #selector(GameViewController.handleSwipes), userInfo: nil, repeats: false)
        } else if seconds%dropSeconds == 0 && seconds > 0 {
            //automatically delay for a full drop time
            let delay = 0.25
            NSTimer.scheduledTimerWithTimeInterval(delay, target: self, selector: #selector(GameViewController.handleSwipes), userInfo: nil, repeats: false)
        } else {
            handleSwipes()
        }
    }
    
    
    func handleSwipes() {
        
        if level.isValidEquation(numbers) {
            count = count+1
            //scene.showCorrectIndicator(numbers)
            level.removeNumbers(self.numbers) //removes numbers from game board
            scene.animateCorrectEquation(self.numbers) //removes sprites
            {
                
                let columns = self.level.dropDownExisting()
                
                self.scene.animateNumberDrop(columns) {
                    
                    //correct drop has been animated, need to check for level changes
                    //allow user to continue until drops to zero equations on board
                    
                    self.score = self.score + 10
                    self.correct = self.correct + 1
                    self.correctChain = self.correctChain + 1
                    
                    //update score, correct and labels everytime a match has been made
                    self.updateLabels()
                    //growth mindset message
                    //check for level changes
                    self.getLevelChange()
                
                    
                    let invalidResults = self.level.invalidNumbers()
                    
                    if invalidResults {
                        self.scene.drawNumberChanges()
                    }
                    
                    //check if need to show growth solution
                    if self.incorrectChain >= 3 {
                        self.showGrowthSolution()
                        self.needToShuffle = true
                    } else if self.level.getCurrentRowsFilled() > 1 { //always shuffle to hide new valid results
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
                if self.level.getCurrentRowsFilled() < self.maxRowsFilled {
                    
                    //it's ok to add a new row, haven't reached top yet
                    let newSet = self.level.addNewRows(1)
                    self.scene.animateNewDrop(newSet) {
                        let newColumns = self.level.shuffleBoard() //shuffle after new row has dropped
                        self.scene.animateShuffle(newColumns) {
                            self.updateProgress()
                            self.handlingSwipe = false
                            self.view.userInteractionEnabled = true
                        }
                    }
                } else {
                    //not okay to drop (at top)
                    self.updateProgress()
                    self.handlingSwipe = false
                    self.view.userInteractionEnabled = true
                }
            }
        }
        
    }
    
    func updateProgress(){
        //update progress
        if correctChain > 0 {
            currentProgress = [progressUpdate,level.getLevel(), level.getDifficulty(), correctChain, correct, score]
            progress.append(currentProgress)
            progressUpdate = progressUpdate+1
        } else if correctChain == 0 && level.getCurrentRowsFilled() == maxRowsFilled {
            incorrectChain = incorrectChain+1 //record how many incorrect when board is full for fixed vs. growth mindset handling
        }
        
        //level regression for fixed mindset
        if fixedMindsetGameplay {
            if incorrectChain > 3 {
                regressLevel()
            }
        }
        correctChain = 0
    }
    
    func showBeginMessage(){
        
        score = 0
        correct = 0
        seconds = 0
        correctChain = 0
        
        agreeToPlayButton.hidden = true
        
        timerLabel.text = "0: 00"
        
        timerLabel.hidden = false
        timerDescr.hidden = false
        correctDescr.hidden = false
        scoreDescr.hidden = false
        correctLabel.hidden = false
        scoreLabel.hidden = false
        mainMenuButton.hidden = true
        
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
        //mainMenuButton.hidden = false
        scene.userInteractionEnabled = true
        startNewChallenge()
    }
    
    func showMessagePanel() {
        mainMenuButton.hidden = true
        if loop {
            messageImage.image = UIImage(named:"loopImage.png")
        } else if isFixedLevel && level.getDifficulty() > 3{
            level.setDifficulty(3)
            messageImage.image = UIImage(named:"loopImage.png")
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
        loop = false
        scoreLabel.text = "\(score)"
        displayHighScore.text = "\(highScore)"
        displayHighScore.hidden = false
        highScoreLabel.hidden = false
        
        displayScoreDescr.hidden = false
        displayScoreLabel.text = "\(score)"
        displayScoreLabel.hidden = false
        
        completionTimeLabel.hidden = false
        displayCompletionTime.text = "\(completionTime)"
        displayCompletionTime.hidden = false
        
        scene.userInteractionEnabled = true
        //self.view.userInteractionEnabled = true
        messageImage.hidden = false
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(self.hideMessagePanel))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    func hideMessagePanel() {
        view.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
        mainMenuButton.hidden = false
        messageImage.hidden = true
        scene.userInteractionEnabled = true
        startNewChallenge()
    }
    
    
    func regressLevel() {
        //regress for fixed mindset
        //show message about regression
        //force difficulty or level to revert
        switch level.getDifficulty() {
        case 1:
            if level.getLevel() == -1 {
                break
            } else if level.getLevel() == -2 {
                level.setLevel(-1)
                level.setDifficulty(3)
            } else if level.getLevel() == -3 {
                level.setLevel(-2)
                level.setDifficulty(3)
            } else if level.getLevel() == -4 {
                level.setLevel(-3)
                level.setDifficulty(3)
            }
        case 2:
            level.setDifficulty(1)
        case 3:
            level.setDifficulty(2)
        default:
            print("default regression")
        }
        //show regression message
        //on hide regression method, start new challenge call
    }
    
    func showGrowthSolution(){
        
        //took at least 3 swipes to get a match when the board was full
        //show praise message for growth mindset
        scene.userInteractionEnabled = true
        messageImage.image = UIImage(named:"growthSolution.png")
        
        messageImage.hidden = false
        
        mainMenuButton.hidden = true
        
        
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(self.hideGrowthSolution))
        view.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    func hideGrowthSolution() {
        view.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
        messageImage.hidden = true
        if self.level.getCurrentRowsFilled() > 1 && needToShuffle == true { //always shuffle to hide new valid results
            let columns = self.level.shuffleBoard()
            self.scene.animateShuffle(columns) {
                self.needToShuffle = false
                self.mainMenuButton.hidden = false
                self.view.userInteractionEnabled = true
                self.messageImage.hidden = true
                self.handlingSwipe = false
                
                self.scene.userInteractionEnabled = true
                
            }
        } else {
            self.needToShuffle = false
            mainMenuButton.hidden = false
            view.userInteractionEnabled = true
            messageImage.hidden = true
            handlingSwipe = false
            
            scene.userInteractionEnabled = true
        }
        
    }
    
    func getLevelChange() {
        
        if level.getCurrentRowsFilled() == 0 || correctChain >= 10 || score > maxScore{
            
            completionTime = getTime(seconds)
            
            timer.invalidate()
            
            //beat this challenge, reset board
            //clear board and reset amount of rows filled
            level.setCurrentRowsFilled(0)
            
            //force difficulty increase
            level.setDifficulty(level.getDifficulty()+1)
            
            if !isFixedLevel && level.getDifficulty() > 3 {
                //move to next level/operator type (mastered all difficulties of current operator type)
                clearOperator = true
                level.setDifficulty(1)
                
                if level.getLevel() == -4 {
                    //loop back to a random level
                    loop = true
                    var nextLevel = Int(arc4random_uniform(randRange))
                    if nextLevel == 0 {
                        nextLevel = nextLevel+1
                    }
                    
                    nextLevel = nextLevel*(-1)
                    
                    level.setLevel(nextLevel)
                }
                else if !isFixedLevel && level.getDifficulty() <= 3{
                    level.setLevel(level.getLevel()-1)
                }
            }
            
            //add a time bonus to the score
            addTimeBonus()
            
            if score > highScore {
                highScore = score
            }
            
            view.userInteractionEnabled = true
            showMessagePanel()
        }
        else {
            
            self.view.userInteractionEnabled = true
        }
        
    }
    
    func addTimeBonus() {
        if seconds <= 10 {
            score = score + (seconds*1000)
        } else {
            score = score + (seconds*10)
        }
    }
    
    @IBAction func fullButtonPressed(_: AnyObject) {
        
        isFixedLevel = false
        level.setIsFixedLevel(false)
        hideMainMenu()
        showBeginMessage()
    }
    
    func showMainMenu() {
        mainMenuButton.hidden = true
        
        displayHighScore.hidden = true
        highScoreLabel.hidden = true
        
        displayScoreDescr.hidden = true
        displayScoreLabel.hidden = true
        
        completionTimeLabel.hidden = true
        displayCompletionTime.hidden = true
        messageImage.hidden = true
        
        timerDescr.hidden = true
        timerLabel.hidden = true
        correctDescr.hidden = true
        scoreDescr.hidden = true
        correctLabel.hidden = true
        scoreLabel.hidden = true
        
        fullPlayThroughButton.hidden = false
        additionFocus.hidden = false
        subFocus.hidden = false
        multFocus.hidden = false
        divFocus.hidden = false
        mainMenuLabel.hidden = false
        focusLabel.hidden = false
        
        view.userInteractionEnabled = true
        scene.userInteractionEnabled = true
        
        
    }
    
    func hideMainMenu() {
        fullPlayThroughButton.hidden = true
        additionFocus.hidden = true
        subFocus.hidden = true
        multFocus.hidden = true
        divFocus.hidden = true
        mainMenuLabel.hidden = true
        focusLabel.hidden = true
    }
    
    @IBAction func addButtonPressed(_: AnyObject) {

        isFixedLevel = true
        level.setIsFixedLevel(true)
        level.setLevel(-1)
        level.setDifficulty(1)
        hideMainMenu()
        startNewChallenge()
    }
    
    @IBAction func subButtonPressed(_: AnyObject) {
        isFixedLevel = true
        level.setIsFixedLevel(true)
        level.setLevel(-2)
        level.setDifficulty(1)
        hideMainMenu()
        startNewChallenge()
    }
    
    @IBAction func multButtonPressed(_: AnyObject) {
        isFixedLevel = true
        level.setIsFixedLevel(true)
        level.setLevel(-3)
        level.setDifficulty(1)
        hideMainMenu()
        startNewChallenge()
    }
    
    @IBAction func divButtonPressed(_: AnyObject) {
        isFixedLevel = true
        level.setIsFixedLevel(true)
        level.setLevel(-4)
        level.setDifficulty(1)
        hideMainMenu()
        startNewChallenge()
    }
    
    @IBAction func mainMenuButtonPressed(_: AnyObject) {
        
        view.userInteractionEnabled = false
        scene.userInteractionEnabled = false
        
        //if there's anything on the board, clear it
        //disable menu button if there's an image currently showing

        if seconds%dropSeconds == 0 || currentlyDropping == true {
            timer.invalidate()
            let delay = 1.0
            NSTimer.scheduledTimerWithTimeInterval(delay, target: self, selector: #selector(GameViewController.clearBoard), userInfo: nil, repeats: false)
        }
        else if level.getCurrentRowsFilled() > 0 {
            timer.invalidate()
            scene.animateClearBoard(true)
            let delay = 0.75
            NSTimer.scheduledTimerWithTimeInterval(delay, target: self, selector: #selector(GameViewController.showMainMenuFromButton), userInfo: nil, repeats: false)
        } else {
            timer.invalidate()
            showMainMenuFromButton()
        }
        
    }
    
    func clearBoard() {
        if level.getCurrentRowsFilled() > 0 {
            let delay2 = 0.75
            NSTimer.scheduledTimerWithTimeInterval(delay2, target: self, selector: #selector(GameViewController.showMainMenuFromButton), userInfo: nil, repeats: false)
        } else {
            showMainMenuFromButton()
        }
    }
    
    func showMainMenuFromButton() {
        
        level.setDifficulty(1)
        level.setLevel(-1)
        
        isFixedLevel = false
        level.setIsFixedLevel(false)
        
        mainMenuButton.hidden = true

        showMainMenu()
    }
    
    
}
