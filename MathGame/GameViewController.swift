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
    
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameOverPanel: UIImageView!
    
    @IBOutlet weak var gameOverLabel: UILabel!
    @IBOutlet weak var winningLabel: UILabel!
    
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
        updateLabels()
        let initEquations = level.firstFill()
        scene.addSpritesForNumbers(initEquations)
    }
    
    func updateLabels() {
        //update labels to show the correct score and number of correct swipes
        //called only after correct equation is swiped
        correctLabel.text = String(format: "%ld", correct)
        scoreLabel.text = String(format: "%ld", score)
    }
    
    func showGameOver() {
        gameOverPanel.hidden = false
        scene.userInteractionEnabled = false
        
        ///////need to fix this - touch recognizer to restart game, restart game needs to be fixed
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideGameOver))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        //show labels for now
        //gameOverLabel.hidden = false
        
    }
    
    func hideGameOver() {
        //STARTS GAME OVER, resets score and correct equations
        view.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
        gameOverPanel.hidden = true
        gameOverLabel.hidden = true
        winningLabel.hidden = true
        scene.userInteractionEnabled = true
        beginGame()
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
                gameOverPanel.image = UIImage(named: "difficulty increased")
                winningLabel.hidden = false
                showGameOver()
            }
            let newSet = level.addNewRow()
            self.scene.animateNewDrop(newSet)
            
            
        } else {
           // scene.animateIncorrectEquation() //highlight numbers in red
            let newSet = level.addNewRow()
            self.scene.animateNewDrop(newSet)
            //logic to show game over goes here
            //need to know if rows are greater than the number that can be displayed
            if level.getCurrentRowsFilled() >= 7 {
                //game is over
                gameOverPanel.image = UIImage(named: "GameOver")
                gameOverLabel.hidden = false
                showGameOver()
            }
            
        }
        
        
    }
}
