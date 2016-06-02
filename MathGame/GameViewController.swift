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
        
        //create lvel instance
        level = Level()
        scene.level = level
        
        scene.swipeHandler = handleSwipe
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
        let initEquations = level.firstFill()
        scene.addSpritesForNumbers(initEquations)
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
            let newSet = level.addNewRow()
            self.scene.animateNewDrop(newSet)
            
        } else {
           // scene.animateIncorrectEquation() //highlight numbers in red
            let newSet = level.addNewRow()
            self.scene.animateNewDrop(newSet)
        }
        
        
    }
    

    
    /*override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }*/
}
