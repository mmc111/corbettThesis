//
//  GameScene.swift
//  MathGame
//
//  Created by Megan Corbett ]
//  Copyright (c) 2015 Megan Corbett. All rights reserved.
//

import UIKit
import SpriteKit

class GameScene: SKScene {
    
    var level: Level!
    
    //dimensions of each square in grid
    //32.0 x 36.0
    let TileWidth: CGFloat = 102.0
    let TileHeight: CGFloat = 109.0
    
    let gameLayer = SKNode()
    let numberLayer = SKNode()
    
    //variables to get square of number swiped from
    var swipeFromCol: Int?
    var swipeFromRow: Int?
    
    var numbersTouched = [Number]()
    
    var selectionSprite = SKSpriteNode()
    
    var swipeHandler: ((Array<Number>) -> ())?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size:CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5) //scenes anchor point, so background image will always be centered on screen
        
        let background = SKSpriteNode(imageNamed: "Background") //sprite node named background, containing backgroudn sprite
        addChild(background)
        
        addChild(gameLayer)
        
        let layerPos = CGPoint(
            x: -TileWidth * CGFloat(NumCol) / 2,
            y: -TileHeight * CGFloat(NumRow) / 2)
        
        numberLayer.position = layerPos
        gameLayer.addChild(numberLayer)
    }
    
    func addSpritesForNumbers(number: Set<Number>) {
        for number in number {
            let sprite = SKSpriteNode(imageNamed: number.spriteName)
            sprite.position = pointForColumn(number.col, row: number.row)
            numberLayer.addChild(sprite)
            number.sprite = sprite
        }
    }
    
    func pointForColumn(col: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(NumCol)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRow)*TileHeight {
                return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if let handler = swipeHandler {
            handler(numbersTouched)
        }
        numbersTouched.removeAll() //clear array for next swipe movement
        hideSelectionIndicator()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        //check for sprites along swipe direction
        for touch in touches {
            let location = touch.locationInNode(numberLayer)
            let(success, col, row) = convertPoint(location)
            
//            for nums in numbersTouched {
//                showSelectionIndicatorForNumber(nums)
//            }
            
            if success && level.containsNumber(col, row: row) {
                
                
                //add this Number to the list if it is a different location, only add if it is a column greater than previous add (so can't swipe within columns)
                let prevNum = numbersTouched.last
                let num = level.numAtCol(col, row: row)
                
                if level.numAtCol(col, row: row) != prevNum && col > prevNum?.col {
                //numbersTouched.append(level.numAtCol(col, row: row)
                    if numbersTouched.count == 1 {
                        print("array size: \(numbersTouched.count), num = \(numbersTouched.last?.value)", terminator: "")
                        
                    }
                    numbersTouched.append(num!)
                    //terminator appends instead of new line
                    print("array size: \(numbersTouched.count), num = \(numbersTouched.last?.value)", terminator: "")
                    
                }
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        //convert touch location to point relative to cookiesLayer
        let touch = touches.first
        let location = touch!.locationInNode(numberLayer)
        //print("in touches began")
        //find out if touch is inside a square on the level grid (basically user put finger somewhere inside grid)
        let(success, col, row) = convertPoint(location)
   
        if success{
            //verify touch is on number, not empty square
            if level.containsNumber(col, row: row){
                //record column and row where swipe started for comparison later
                swipeFromCol = col
                swipeFromRow = row
                
                //get the number at the location and add to list
                let num = level.numAtCol(col, row: row)
                numbersTouched.append(num!)
                //showSelectionIndicatorForNumber(num!)
            }
        }
    }
    
    
    func showSelectionIndicatorForNumber(num: Number) {
        
        
        if selectionSprite.parent != nil {
            
            selectionSprite.removeFromParent()
            
        }
        
        
        if let sprite = num.sprite {
            if num.numberType != NumberType.Operator {
            let texture = SKTexture(imageNamed: num.highlightedSpriteName)
            selectionSprite.size = texture.size()
                selectionSprite.runAction(SKAction.setTexture(texture))
            
            sprite.addChild(selectionSprite)
            selectionSprite.alpha = 1.0
            }
        }
        
        
    }
    
    func hideSelectionIndicator() {
        selectionSprite.runAction(SKAction.sequence([
            SKAction.fadeOutWithDuration(0.3),
            SKAction.removeFromParent()]))
    }
    
    //func animateCorrectEquation(completion: () -> ())
    func animateCorrectEquation() {
        for num in numbersTouched {
            if num.numberType != NumberType.Operator{
                if let sprite = num.sprite {
                    if sprite.actionForKey("removing") == nil {
                        let scaleAction = SKAction.scaleTo(0.1, duration: 1.5)
                        scaleAction.timingMode = .EaseOut
                        sprite.runAction(SKAction.sequence([scaleAction, SKAction.removeFromParent()]), withKey:"removing")
                    }
                }
            }
        }
    }
    
    func animateIncorrectEquation() {
        //highlight numbers in red
        //shuffle columns
    }
    
    func animateNumberDrop(col: [[Number]], completion: () -> ()) {
       
        
        //need to compute duration because of varying number of numbers dropping
        var longestDuration: NSTimeInterval = 0

        for array in col {
            for (idx, number) in array.enumerate() {
                print("in enumerate for")
                
                let newPosition = pointForColumn(number.col, row: number.row)
                let delay = 0.05 + 0.15*NSTimeInterval(idx)
                //duration of animation depends on how far number drops, 0.1 second per tile
                let sprite = number.sprite!
                let duration = NSTimeInterval(((sprite.position.y - newPosition.y) / TileHeight) * 0.1) * 1.25
                //calculate which has longest duration
                longestDuration = max(longestDuration, duration + delay)
                //perform animation (delay + movement)
                let moveAction = SKAction.moveTo(newPosition, duration: duration)
                moveAction.timingMode = .EaseOut
                print("before run action")
                sprite.runAction(
                    SKAction.sequence([
                        SKAction.waitForDuration(delay),
                        moveAction])
                )
            }
            //wait for all numbers to fall before allowing gameplay to continue
            runAction(SKAction.waitForDuration(longestDuration), completion: completion)
        }
        

    }
    
    
    func animateShuffle(numbers: Array<Number>) {
        //logic for animating shuffle (swapping numbers within columns)
    }
    
    func animateNewDrop(numbers: Set<Number>) {
        
        //take top most row and drop from top of screen to correct location
        //get number object
        let startRow = level.getCurrentRowsFilled()
        for number in numbers {
            let sprite = SKSpriteNode(imageNamed: number.spriteName)
            sprite.position = pointForColumn(number.col, row: startRow)
            numberLayer.addChild(sprite)
            number.sprite = sprite
            
            let duration = NSTimeInterval(startRow - number.row)*1.25
            
            let newPosition = pointForColumn(number.col, row: number.row)
            let moveAction = SKAction.moveTo(newPosition, duration: duration)
            moveAction.timingMode = .EaseOut
            
            sprite.alpha = 0
            
            sprite.runAction(SKAction.group([SKAction.fadeInWithDuration(0.05), moveAction]))
        }
    
    }
    
    
    
    
    
    
    
    
    
    
    //original code in class
   /* override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!";
        myLabel.fontSize = 45;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        self.addChild(myLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }*/
}
