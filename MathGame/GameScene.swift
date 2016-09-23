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
    var numbersToClear = [Number]()

    
    var selectionSpriteList = [SKSpriteNode()]
    var incorrectSpriteList = [SKSpriteNode()]
    var incorrectSprite = SKSpriteNode()
    var opSpriteLayer = SKSpriteNode()
    
    
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
            
            //deselect sprites if swipe left
            let prevNum1 = numbersTouched.last
            if success && col < prevNum1?.col {
                
                //remove highlight from last number touched
                let selectionSprite = selectionSpriteList.last
                selectionSprite!.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.3),SKAction.removeFromParent()]))
                numbersTouched.removeLast()
                selectionSpriteList.removeLast()
                
            }
            
            if success && level.containsNumber(col, row: row) {
                
                
                //add this Number to the list if it is a different location, only add if it is a column greater than previous add (so can't swipe within columns)
                let prevNum = numbersTouched.last
                let num = level.numAtCol(col, row: row)
                
                if col == 6 {
                    //allow up and down swipes within answer column
                    if col == prevNum?.col && (row > prevNum?.row || row < prevNum?.row) {
                        //remove highlight from last number touched
                        
                        let selectionSprite = selectionSpriteList.last
                        selectionSprite!.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.3),SKAction.removeFromParent()]))
                        numbersTouched.removeLast()
                        selectionSpriteList.removeLast()
                        
                        numbersTouched.append(num!)
                        showSelectionIndicatorForNumber(num!)
                    }
                }
                //add sprites if swiped right and on new number
                if level.numAtCol(col, row: row) != prevNum && col > prevNum?.col {
                    
                    numbersTouched.append(num!)
                    showSelectionIndicatorForNumber(num!)
                    
                }
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        //convert touch location to point relative to cookiesLayer
        let touch = touches.first
        let location = touch!.locationInNode(numberLayer)
        
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
                showSelectionIndicatorForNumber(num!)
            }
        }
    }
    
    
    func showSelectionIndicatorForNumber(num: Number) {
        
        let selectionSprite = SKSpriteNode()
        
        
        if let sprite = num.sprite {
            if num.numberType.rawValue <= 3{
                let texture = SKTexture(imageNamed: num.highlightedSpriteName)
                selectionSprite.size = texture.size()
                selectionSprite.runAction(SKAction.setTexture(texture))
            
                sprite.addChild(selectionSprite)
                selectionSprite.alpha = 1.0
                
                selectionSpriteList.append(selectionSprite)
            }
        }
    }
    
    func hideSelectionIndicator() {
        for selectionSprite in selectionSpriteList {
            selectionSprite.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.3),SKAction.removeFromParent()]))
        }
        selectionSpriteList.removeAll()
    }
    
    func showIncorrectIndicator(completion:() -> ())
    {
        var incorrectSpriteList = [SKSpriteNode()]
        
        for num in numbersTouched {
            if let sprite = num.sprite {
                incorrectSprite = SKSpriteNode()
                let texture = SKTexture(imageNamed: num.incorrectSpriteName)
                incorrectSprite.size = texture.size()
                incorrectSprite.runAction(SKAction.setTexture(texture))
                
                sprite.addChild(incorrectSprite)
                incorrectSprite.alpha = 1.0
                incorrectSpriteList.append(incorrectSprite)
            }
        }
        
        for sprite in incorrectSpriteList {
         sprite.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(2),SKAction.removeFromParent()]))
        }
        //wait for numbers to fade back to normal
        runAction(SKAction.waitForDuration(2), completion: completion)
        incorrectSpriteList.removeAll()
    }
    
    func showCorrectIndicator(){
        //don't need to layer, just replace sprite with green highlighted sprite
        for num in numbersTouched {
            if let sprite = num.sprite {
                let texture = SKTexture(imageNamed: num.correctSpriteName)
                if num.numberType.rawValue == 3 {
                    
                    //layer sprite on operator
                    opSpriteLayer = SKSpriteNode()
                    if opSpriteLayer.parent != nil {
                        opSpriteLayer.removeFromParent()
                     }
                    opSpriteLayer.size = texture.size()
                    opSpriteLayer.runAction(SKAction.setTexture(texture))
                    
                    sprite.addChild(opSpriteLayer)
                }
                
                else if num.numberType.rawValue < 3 {
                    sprite.alpha = 1.0
                    sprite.texture = texture
                }
            }
        }
    }

    func animateCorrectEquation(completion:() -> ()) {
        showCorrectIndicator()
        for num in numbersTouched {
            //fade back to normal if operator
            if num.numberType.rawValue == 3 {
                opSpriteLayer.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.3),SKAction.removeFromParent()]))
            }
            else if num.numberType.rawValue < 3 { //remove from board if its not the operator
                if let sprite = num.sprite {
                    if sprite.actionForKey("removing") == nil {
                        let scaleAction = SKAction.scaleTo(0.1, duration: 1.5)
                        scaleAction.timingMode = .EaseOut
                        sprite.runAction(SKAction.sequence([scaleAction, SKAction.removeFromParent()]), withKey:"removing")
                    }
                }
            }
        }

        //wait for all numbers to move before allowing gameplay to continue
        runAction(SKAction.waitForDuration(1.5), completion: completion)
    }
    
    func clearSprites() {
        
        //or use remove children method???????
        for row in 0..<10 {
            
            for col in 0..<7 {
                if col != 1 && col != 2 && col != 3 && col != 5 {
                    if level.containsNumber(col, row: row) {
                        print("[ \(col), \(row)] : \(level.containsNumber(col, row: row))")
                        numbersToClear.append((level.numAtCol(col, row: row))!)
                }
            }

            }
        }
        
    }
    
    
    func animateClearBoard() {
        clearSprites()
        for num in numbersToClear {
            if num.numberType.rawValue < 3 {
                if let sprite = num.sprite {
                    if sprite.actionForKey("removing") == nil {
                        let scaleAction = SKAction.scaleTo(0.1, duration: 1.5)
                        scaleAction.timingMode = .EaseOut
                        sprite.runAction(SKAction.sequence([scaleAction, SKAction.removeFromParent()]), withKey:"removing")
                    }
                }
                
            }
        }
        level.clearBoard(numbersToClear)
    }
    
    
    func animateNumberDrop(col: [[Number]], completion: () -> ()) {
        //drops completely new row down on top of existing rows
        //needs to happen after incorrect and after x amount of time has passed (tracked via timer)
        //need to compute duration because of varying number of numbers dropping
        var longestDuration: NSTimeInterval = 0
        
        if level.getNewResults().count > 0 {
            for num in level.getNewResults() {
                //change the sprite to the correct one
                num.sprite?.removeFromParent()
                let sprite = SKSpriteNode(imageNamed: num.spriteName)
                sprite.position = pointForColumn(num.col, row: num.row)
                numberLayer.addChild(sprite)
                num.sprite = sprite
            }
            level.clearNewResults()
        }
        
        for array in col {
            for (idx, number) in array.enumerate() {
                
                let newPosition = pointForColumn(number.col, row: number.row)
                let delay = 0.05 + 0.15*NSTimeInterval(idx)
                //duration of animation depends on how far number drops, 0.1 second per tile
                let sprite = number.sprite!
                let duration = NSTimeInterval(((sprite.position.y - newPosition.y) / TileHeight) * 0.1) * 1
                //calculate which has longest duration
                longestDuration = max(longestDuration, duration + delay)
                //perform animation (delay + movement)
                let moveAction = SKAction.moveTo(newPosition, duration: duration)
                moveAction.timingMode = .EaseOut
                
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
    
    func animateShuffle(col: [[Number]], completion: () -> ()) {
        //logic for animating shuffle (swapping numbers within columns)

        var longestDuration: NSTimeInterval = 0
        var y1: CGFloat = 0
        var y2: CGFloat = 0
        for array in col {
            for (idx, number) in array.enumerate() {
                if(number.sprite != nil){
                    let newPosition = pointForColumn(number.col, row: number.row)
                    let oldPosition = pointForColumn(number.col, row: number.prevY)
                    let delay = 0.05 + 0.15*NSTimeInterval(idx)
                    //duration of animation depends on how far number drops, 0.1 second per tile
                
                    let sprite = number.sprite!
                    //check if sprite is moving up or down
                    y1 = oldPosition.y
                    y2 = newPosition.y
                    if newPosition.y > oldPosition.y{
                        y1 = newPosition.y
                        y2 = oldPosition.y
                    }
                    let duration = NSTimeInterval(((y1 - y2) / TileHeight) * 0.1) * 5
                    //calculate which has longest duration
                    longestDuration = max(longestDuration, duration + delay)
                    //perform animation (delay + movement)
                    let moveAction = SKAction.moveTo(newPosition, duration: duration)
                    moveAction.timingMode = .EaseOut
                
                    sprite.runAction(SKAction.sequence([SKAction.waitForDuration(delay),moveAction]))
                }
            }
            //wait for all numbers to move before allowing gameplay to continue
            runAction(SKAction.waitForDuration(longestDuration), completion: completion)
        }
        
    }
    
    func animateNewDrop(numbers: Set<Number>, completion: () -> ()) {
        
        //drops existing rows down
        //take top most row and drop from top of screen to correct location
        
        let startRow = level.getCurrentRowsFilled()
        var duration: NSTimeInterval = 0
        for number in numbers {
            let sprite = SKSpriteNode(imageNamed: number.spriteName)
            sprite.position = pointForColumn(number.col, row: startRow)
            numberLayer.addChild(sprite)
            number.sprite = sprite
            
            duration = NSTimeInterval(startRow - number.row)*1.25
            
            let newPosition = pointForColumn(number.col, row: number.row)
            let moveAction = SKAction.moveTo(newPosition, duration: duration)
            moveAction.timingMode = .EaseOut
            
            sprite.alpha = 0
            
            sprite.runAction(SKAction.group([SKAction.fadeInWithDuration(0.05), moveAction]))
        }
        runAction(SKAction.waitForDuration(duration), completion: completion)
    
    }
}
