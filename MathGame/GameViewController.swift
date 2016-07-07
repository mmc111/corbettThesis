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
    
    var seconds = 0
    var maxSeconds = 20
    var dropSeconds = 5
    var timer = NSTimer()
    
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameOverPanel: UIImageView!
    
    @IBOutlet weak var gameOverLabel: UILabel!
    @IBOutlet weak var winningLabel: UILabel!
    
    @IBOutlet var timerLabel: UILabel!
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    
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
        
        gameOverPanel.hidden = true
        //present scene
        skView.presentScene(scene)
        
        beginGame()
    }
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    func beginGame() {
        gameOverLabel.hidden = true
        winningLabel.hidden = true
        score = 0
        correct = 0
        seconds = 0
        
        timerLabel.text = "Time: \(seconds)"
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(GameViewController.addTime), userInfo: nil, repeats: true)
        
        updateLabels()
        
        let initEquations = level.firstFill()
        scene.addSpritesForNumbers(initEquations)
    }
    
    //function to reset/update board after gameplay has begun, call in viewDidLoad()
    func startNewChallenge() {
        //need to implement change in difficulty or level type here (dependent upon game progress)
        gameOverLabel.hidden = true
        winningLabel.hidden = true
        //keep score
        correct = 0
        seconds = 0
        timerLabel.text = "Time: \(seconds)"
        updateLabels()
        
        //reset equations tables and game grid ***** need to fix this
        let initEquations = level.firstFill()
        scene.addSpritesForNumbers(initEquations)
    }
    
    func addTime() {
        seconds = seconds + 1
        timerLabel.text = "Time: \(seconds)"
        
        //can impose time limit here
        if(seconds%dropSeconds == 0 && seconds > 0)
        {
            let newSet = level.addNewRow()
            self.scene.animateNewDrop(newSet)
        }
        if(seconds == maxSeconds) {
            timer.invalidate()
            //game is over
            gameOverPanel.image = UIImage(named: "GameOver")
            gameOverLabel.hidden = false
            showGameOver()
        }
    }
    
    func updateLabels() {
        //update labels to show the correct score and number of correct swipes
        //called only after correct equation is swiped
        correctLabel.text = String(format: "%ld", correct)
        scoreLabel.text = String(format: "%ld", score)
    }
    
    func showGameOver() {
        //stop timer
        
        timer.invalidate()
        
        //add time bonus
        if(winningLabel.hidden == false){
            score = score + (seconds*5)
        }
        
        updateLabels()
        gameOverPanel.hidden = false
        scene.userInteractionEnabled = false
        
        ///////need to fix this - touch recognizer to restart game, restart game needs to be fixed
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideGameOver))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        
    }
    
    func hideGameOver() {
        //STARTS GAME OVER, resets score and correct equations
        view.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
        gameOverPanel.hidden = true
        gameOverLabel.hidden = true
        winningLabel.hidden = true
        scene.userInteractionEnabled = true
        //beginGame()
        //set new challenge/difficulty
        if(level.getCurrentRowsFilled() == 0)
        {
            //call to create a new challenge - this will be level change
            startNewChallenge()
        }
        /*else if(score >= 40) {
            //increase difficulty level
        }*/
        else {
            //repeat same level ************** need to fix this for future levels
            //need to remove all equations from board
            
            scene.animateClearBoard()
            
            level.clearBoard(numbersToClear)

            beginGame()
        }
    }
    
    func handleSwipe(numbers: Array<Number>)
    {
        //view.userInteractionEnabled = false
        if numbers.count > 4 || numbers.count < 4 {
            return
        }
        
        if level.isValidEquation(numbers) {
            
            //TODO: highlight numbers in green
            
            level.removeNumbers(numbers)
            
            //animate highlight and removal
            scene.animateCorrectEquation()
            /*({
                 //self.view.userInteractionEnabled = true
            })*/
            
            let columns = self.level.dropDownExisting()
            
            self.scene.animateNumberDrop(columns) {
                self.view.userInteractionEnabled = true
            }
            
            //update score, correct and labels everytime a match has been made
            score = score + 10
            correct = correct + 1
            updateLabels()
            
            //if score is high enough, level is passed show game over panel
            if score == 40 {
                /*gameOverPanel.image = UIImage(named: "difficulty increased")
                winningLabel.hidden = false
                showGameOver()*/
                //////change difficulty here dynamically
            }
            
            //allow user to continue until drops to zero equations on board
            
            //let newSet = level.addNewRow()
            //self.scene.animateNewDrop(newSet)
            
            if level.getCurrentRowsFilled() == 0 {
                //beat this challenge, reset bored
                gameOverPanel.image = UIImage(named: "difficulty increased")
                winningLabel.hidden = false
                showGameOver()
            }
            
            
        } else {
           // scene.animateIncorrectEquation() //highlight numbers in red
            let newSet = level.addNewRow()
            self.scene.animateNewDrop(newSet)
            //logic to show game over goes here
            //need to know if rows are greater than the number that can be displayed
            
            //fixed mindset
            if level.getCurrentRowsFilled() >= 7 {
                //game is over
                gameOverPanel.image = UIImage(named: "GameOver")
                gameOverLabel.hidden = false
                showGameOver()
            }
            
            //OR growth mindset - allow user to make a certain number of attmepts, reward for different attempts, then revert back to previous difficulty
            //shuffle after each subsequent attempt until max attempts is reached, then revert
            
        }
        
        
    }
}
