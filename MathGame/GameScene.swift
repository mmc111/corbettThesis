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
    let pathLayer = SKNode()
    
    //variables to get square of number swiped from
    var swipeFromCol: Int?
    var swipeFromRow: Int?
    
    var isTouchingBoard = false
    
    var numbersTouched = [Number]()
    var numbersToClear = [Number]()
    
    
    var selectionSpriteList = [SKSpriteNode()]
    var incorrectSpriteList = [SKSpriteNode()]
    var incorrectSprite = SKSpriteNode()
    var opSpriteLayer = SKSpriteNode()
    var startBackground = SKSpriteNode()
    
    var startTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
    
    var swipeHandler: ((Array<Number>) -> ())?
    
    var pathStart = CGPoint()
    var touchPoint = CGPoint()
    var validPathStart: Bool = false
    
    var touchPoints = [CGPoint]()
    
    var fixedPathNodes = [SKShapeNode()]
    var allPathNodes = [SKShapeNode()]
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size:CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5) //scenes anchor point, so background image will always be centered on screen
        
        let background = SKSpriteNode(imageNamed: "Background") //sprite node named background, containing backgroudn sprite
        addChild(background)
        
        startBackground = SKSpriteNode(imageNamed: "startBackground")//background for start screen, add on top so can be removed
        addChild(startBackground)
        
        addChild(gameLayer)
        
        
        let layerPos = CGPoint(
            x: -TileWidth * CGFloat(NumCol) / 2,
            y: -TileHeight * CGFloat(NumRow) / 2)
        
        numberLayer.position = layerPos
        pathLayer.position = layerPos
        gameLayer.addChild(pathLayer)
        gameLayer.addChild(numberLayer)
    }
    
    func removeStartBackground(){
        startBackground.removeFromParent()
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
    
    func getTouchingBoard() -> Bool {
        return isTouchingBoard
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        pathLayer.removeAllChildren()
        if fixedPathNodes.count > 0 {
            fixedPathNodes.removeAll()
        }
        if allPathNodes.count > 0 {
           allPathNodes.removeAll()
        }
        
        isTouchingBoard = false
        validPathStart = false
        if let handler = swipeHandler {
            
            handler(numbersTouched)
        }
        
        if numbersTouched.count > 0 {
            numbersTouched.removeAll() //clear array for next swipe movement
        }
        
        hideSelectionIndicator()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {

        //check for sprites along swipe direction
        if allPathNodes.count > 0 {
            for pathNode in allPathNodes {
                pathNode.removeFromParent()
            }
            allPathNodes.removeAll()
        }
        
        for touch in touches {
            let location = touch.locationInNode(numberLayer)
            let(success, col, row) = convertPoint(location)
            
            touchPoints.append(location)
            
            //deselect sprites if swipe left
            let prevNum1 = numbersTouched.last
            if success && col < prevNum1?.col {
                
                //remove highlight from last number touched
                let selectionSprite = selectionSpriteList.last
                selectionSprite!.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.3),SKAction.removeFromParent()]))
                numbersTouched.removeLast()
                selectionSpriteList.removeLast()
                if fixedPathNodes.count >= 1 && validPathStart{
                    fixedPathNodes.last?.removeFromParent()
                    fixedPathNodes.removeLast()
                    let num = numbersTouched.last
                    pathStart = pointForColumn(num!.col, row: num!.row)
                }
                
            }
            
            if success && level.containsNumber(col, row: row) {
                
                
                //add this Number to the list if it is a different location, only add if it is a column greater than previous add (so can't swipe within columns)
                let prevNum = numbersTouched.last
                let num = level.numAtCol(col, row: row)
                if num!.col == 0 && validPathStart == false{
                    //get that this is the start of a new path for drawing line purposes
                    validPathStart = true
                    let loc = pointForColumn(num!.col, row: num!.row) //get start of path to draw
                    pathStart = loc
                } else if col == 6 || col == 2 {
                    //allow up and down swipes within columns -- doesn't work, too easy to accidentally swipe on something else
                    if col == prevNum?.col && (row > prevNum?.row || row < prevNum?.row) {
                        //remove highlight from last number touched
                        
                        let selectionSprite = selectionSpriteList.last
                        selectionSprite!.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.3),SKAction.removeFromParent()]))
                        numbersTouched.removeLast()
                        selectionSpriteList.removeLast()
                        
                        fixedPathNodes.last?.removeFromParent()
                        fixedPathNodes.removeLast()
                        
                        let prevNum = numbersTouched.last
                        
                        numbersTouched.append(num!)
                        if validPathStart {
                            let loc = pointForColumn(num!.col, row: num!.row)
                            pathStart = pointForColumn(prevNum!.col, row: prevNum!.row)
                        
                            drawPath(pathStart, end: loc, fixed: true)
                            pathStart = loc
                        }
                        showSelectionIndicatorForNumber(num!)
                    }
                }
                //add sprites if swiped right and on new number
                if level.numAtCol(col, row: row) != prevNum && col > prevNum?.col {
                    //create fixed path from previous number to new number
                
                    numbersTouched.append(num!)
                    let loc = pointForColumn(num!.col, row: num!.row)
                    if validPathStart {
                        drawPath(pathStart, end: loc, fixed: true)
                        showSelectionIndicatorForNumber(num!)
                    } else {
                        showSelectionIndicatorForNumber(num!)
                    }
                    
                    
                }
            }
        }
        
        if numbersTouched.count < 4 && validPathStart{
            touchPoint = touchPoints.last!
            drawPath(pathStart, end: touchPoint, fixed: false)
        
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        isTouchingBoard = true
        
        //convert touch location to point relative to numbers layer
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
                if num!.col == 0 {
                    validPathStart = true
                    let loc = pointForColumn(num!.col, row: num!.row) //get start of path to draw
                    pathStart = loc
                } else {
                    validPathStart = false
                }
                numbersTouched.append(num!)
                showSelectionIndicatorForNumber(num!)
            }
        }
        
    }
    
    func drawPath(start: CGPoint, end: CGPoint, fixed: Bool){
        if level.getCanDraw() {
            let dPath = CGPathCreateMutable()
            CGPathMoveToPoint(dPath, nil, start.x, start.y)
            CGPathAddLineToPoint(dPath, nil, end.x, end.y)
            
            let dShape = SKShapeNode()
            dShape.path = dPath
            dShape.strokeColor = UIColor.yellowColor()
            dShape.lineWidth = 5
            //dShape.zPosition = 1
            pathLayer.addChild(dShape)
            //numberLayer.addChild(fixedShape)
        if fixed {
            fixedPathNodes.append(dShape)
            pathStart = end
        } else {
            allPathNodes.append(dShape)
        }
        }
        
    }
    
    
    func showSelectionIndicatorForNumber(num: Number) {
        
        let selectionSprite = SKSpriteNode()
        
        
        if let sprite = num.sprite {
            if num.numberType.rawValue <= 6 && level.getCanDraw() == true {
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
    
    func showIncorrectIndicator(numbers: Array<Number>)
    {
        for num in numbers {
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
    }
    
    func fadeIncorrectIndicator(numbers: Array<Number>, completion:() -> ())
    {
        for sprite in incorrectSpriteList {
            sprite.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.75),SKAction.removeFromParent()]))
        }
        //wait for numbers to fade back to normal
        runAction(SKAction.waitForDuration(0.75), completion: completion)
        incorrectSpriteList.removeAll()
    }
    
    func showCorrectIndicator(numbers: Array<Number>){
        //don't need to layer, just replace sprite with green highlighted sprite
        for num in numbers {
            if let sprite = num.sprite {
                let texture = SKTexture(imageNamed: num.correctSpriteName)
                if num.numberType.rawValue >= 3 {
                    
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
    
    func animateCorrectEquation( numbers: Array<Number>, completion:() -> ()) {
        
        //showCorrectIndicator(numbers)
        for num in numbers{
            //fade back to normal if operator
            if num.numberType.rawValue >= 3 {//fade out .3
                opSpriteLayer.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.3),SKAction.removeFromParent()]))
            }
            else if num.numberType.rawValue < 3 { //remove from board if its not the operator
                if let sprite = num.sprite {
                    if sprite.actionForKey("removing") == nil {
                        let scaleAction = SKAction.scaleTo(0.1, duration: 1)//duration1
                        scaleAction.timingMode = .EaseOut
                        sprite.runAction(SKAction.sequence([scaleAction, SKAction.removeFromParent()]), withKey:"removing")
                    }
                }
            }
        }
        
        //wait for all numbers to move before allowing gameplay to continue
        runAction(SKAction.waitForDuration(1.2), completion: completion)
    }
    
    func setNumbersToClear() {
        
        for row in 0..<10 {
            
            for col in 0..<7 {
                if col != 1 && col != 3 && col != 5 {
                    if level.containsNumber(col, row: row) {
                        //print("[ \(col), \(row)] : \(level.containsNumber(col, row: row))")
                        numbersToClear.append((level.numAtCol(col, row: row))!)
                    }
                }
                
            }
        }
    }
    
    
    
    func animateClearBoard(completion: () -> ()) {
        numbersToClear.removeAll()
        setNumbersToClear()
        level.clearBoard(true)
        let duration = 0.5
        for num in numbersToClear {
            if let sprite = num.sprite {
                if sprite.actionForKey("removing") == nil {
                    let scaleAction = SKAction.scaleTo(0.01, duration: duration)
                    scaleAction.timingMode = .EaseOut
                    sprite.runAction(SKAction.sequence([scaleAction, SKAction.removeFromParent()]), withKey:"removing")
                }
            }
        }
        runAction(SKAction.waitForDuration(duration), completion: completion)
    }
    /*func animateClearBoard(removeOperator:Bool, completion: () -> ()) {
        print("remove operator: \(removeOperator)")
        numbersToClear.removeAll()
        setNumbersToClear()
        
        level.clearBoard(removeOperator)
        
        var duration = 0.5

        for num in numbersToClear {
            if removeOperator || (!removeOperator && num.numberType.rawValue < 3) {
                if let sprite = num.sprite {
                    if num.numberType.rawValue == 3 {
                        sprite.removeAllChildren()
                        print("removing all children")
                    }
                    if sprite.actionForKey("removing") == nil {
                        let scaleAction = SKAction.scaleTo(0.01, duration: duration)
                        scaleAction.timingMode = .EaseOut
                        sprite.runAction(SKAction.sequence([scaleAction, SKAction.removeFromParent()]), withKey:"removing")
                    }
                }
            }
        }
        runAction(SKAction.waitForDuration(duration), completion: completion)
    }*/
    
    func drawNumberChanges() {
        //perform check after the numbers have dropped down to ensure accuracy
        //make call to get invalid numbers array
        let numbersToChange = level.getNewNumbers()
        for num in numbersToChange {
            //remove sprite that's there and change the sprite to the correct one
            num.sprite?.removeFromParent()
            let sprite = SKSpriteNode(imageNamed: num.spriteName)
            sprite.position = pointForColumn(num.col, row: num.row)
            numberLayer.addChild(sprite)
            num.sprite = sprite
        }
    }
    
    func animateNumberDrop(col: [[Number]], completion: () -> ()) {
        //drops existing rows down
        //need to compute duration because of varying locations of numbers dropping
        
        /*//first check for invalid results and update
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
         }*/
        
        var longestDuration: NSTimeInterval = 0
        
        var y1: CGFloat = 0
        var y2: CGFloat = 0
        for array in col {
            for (idx, number) in array.enumerate() {
                if(number.sprite != nil){
                    let newPosition = pointForColumn(number.col, row: number.row)
                    let oldPosition = pointForColumn(number.col, row: number.prevY)
                    let delay = 0.25 + 0.15*NSTimeInterval(idx) //.05+
                    //duration of animation depends on how far number drops, 0.1 second per tile
                    
                    let sprite = number.sprite!
                    //check if sprite is moving up or down
                    y1 = oldPosition.y
                    y2 = newPosition.y
                    if newPosition.y > oldPosition.y{
                        y1 = newPosition.y
                        y2 = oldPosition.y
                    }
                    let duration = NSTimeInterval(((y1 - y2) / TileHeight) * 0.1) * 1.0
                    //calculate which has longest duration
                    longestDuration = max(longestDuration, duration + delay)
                    //perform animation (delay + movement)
                    let moveAction = SKAction.moveTo(newPosition, duration: duration)
                    moveAction.timingMode = .EaseOut
                    
                    sprite.runAction(SKAction.sequence([SKAction.waitForDuration(delay),moveAction]))
                }
            }
            
        }
        //wait for all numbers to fall before allowing gameplay to continue
        runAction(SKAction.waitForDuration((longestDuration)), completion: completion)
        
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
                    let duration = NSTimeInterval(((y1 - y2) / TileHeight) * 0.1) * 5 ///*5 originally
                    //calculate which has longest duration
                    longestDuration = max(longestDuration, duration + delay)
                    //perform animation (delay + movement)
                    let moveAction = SKAction.moveTo(newPosition, duration: duration)
                    moveAction.timingMode = .EaseOut
                    
                    sprite.runAction(SKAction.sequence([SKAction.waitForDuration(delay),moveAction]))
                }
            }
        }
        //wait for all numbers to move before allowing gameplay to continue
        runAction(SKAction.waitForDuration(longestDuration), completion: completion)
        
    }
    
    func animateNewDrop(numbers: Set<Number>, completion: () -> ()) {
        
        
        //drops completely new row down on top of existing rows
        //needs to happen after incorrect and after x amount of time has passed (tracked via timer)
        
        let startRow = level.getCurrentRowsFilled()+1
        
        //let startRow = 7
        startTime = CFAbsoluteTimeGetCurrent()
        var duration: NSTimeInterval = 0
        for number in numbers {
            let sprite = SKSpriteNode(imageNamed: number.spriteName)
            sprite.position = pointForColumn(number.col, row: startRow)
            numberLayer.addChild(sprite)
            number.sprite = sprite
            
            duration = NSTimeInterval(startRow - number.row)*0.5  //*0.75 for 1.5
            
            let newPosition = pointForColumn(number.col, row: number.row)
            let moveAction = SKAction.moveTo(newPosition, duration: duration)
            moveAction.timingMode = .EaseOut
            
            sprite.alpha = 0
            
            sprite.runAction(SKAction.group([SKAction.fadeInWithDuration(0.05), moveAction]))
            startTime = CFAbsoluteTimeGetCurrent()
        }
        
        runAction(SKAction.waitForDuration(duration), completion: completion)
        
        //duration = 1.5 here
        //somehow time and communicate how much of the duration time has passed to minimize waiting on correct animations
        
    }
    
    func getDuration() -> Double {
        //calculates time until the drop has finished animating, used to minimize waiting on correct animations
        let timeElapsed = startTime - CFAbsoluteTimeGetCurrent()
        let duration = 1.0 + (Double(timeElapsed))
        return duration
        
    }
    
}
