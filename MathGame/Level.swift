//
//  Level.swift
//  MathGame
//
//  Created by Megan Corbett
//  Copyright © 2015 Megan Corbett. All rights reserved.



//////practice mode without timer
//****fractions
//mathletics
//marketing department - iPads

import Foundation
import GameplayKit

//define dimensions of game grid
let NumCol = 7
let NumRow = 10
var levelNum: Int = -1 //testing addition

var score: Int = 0

var difficulty: Int = 1 //need to change this dynamically throughout gameplay, default difficulty is one
var randRange: UInt32 = 1 //default for range will be 10 (4 for testing purposes until sprites updated)

var currentRowsFilled = 0

var numbersToClear = [Number]()

var colAIndex = [Int]()
var colBIndex = [Int]()
var colCIndex = [Int]()

var spriteCount = 0

class Level {
    
    //var levelNumber: Int = 0
    
    private var numbers = GameGrid<Number>(colCount: NumCol, rowCount: NumRow)
    
    var values = GameGrid<Int>(colCount: NumCol, rowCount: NumRow)
    
    //function to access Number object as specific position in grid
    func numAtCol(col: Int, row: Int) -> Number? {
        
        assert(col >= 0 && col < NumCol)
        assert(row >= 0 && row < NumRow)
        return numbers[col,row]
    }
    

    
    func firstFill() -> Set<Number> {
        return createInitialNumbers()
    }
    
    private func createInitialNumbers() -> Set<Number> {
        var set = Set<Number>()
            createEquations(3) //initial call to create equations
            var value: Int
            var numberType: NumberType
        var op :Number

            //let op = Number(col: 2, row: 2, value: levelNum, numberType: NumberType.Operator)
        switch levelNum{
        case -1:
            op = Number(col: 2, row: 2, value: -1, numberType: NumberType.AddOperator, uniqueID: -1)
        case -2:
            op = Number(col: 2, row: 2, value: -2, numberType: NumberType.SubOperator, uniqueID: -2)
        case -3:
            op = Number(col: 2, row: 2, value: -3, numberType: NumberType.MultOperator, uniqueID: -3)
        case -4:
            op = Number(col: 2, row: 2, value: -4, numberType: NumberType.DivOperator, uniqueID: -4)
        default:
            op = Number(col: 2, row: 2, value: -1, numberType: NumberType.AddOperator, uniqueID: -1)
            
        }
        
            numbers[2,2] = op //operator position in grid
            set.insert(op)
        
            //now create numbers to fill first 3 rows since it is first fill
            for row in 0..<3 {

                for col in 0..<NumCol {
                    //only generate numbers for valid columns
                    if col != 1 && col != 2 && col != 3 && col != 5 {
                        switch col {
                        case 0:
                            numberType = NumberType.Operand
                            value = self.values[0, row]!
                            let number = Number(col: col, row: row, value: value, numberType: numberType, uniqueID: spriteCount+1) //creating Number objects with values and sprite names
                            numbers[col,row] = number
                            set.insert(number)
                        case 4:
                            numberType = NumberType.Operand
                            value = self.values[1, row]!
                            let number = Number(col: col, row: row, value: value, numberType: numberType, uniqueID: spriteCount+1)
                            numbers[col,row] = number
                            set.insert(number)
                        case 6:
                            numberType = NumberType.Result
                            value = self.values[2, row]!
                            let number = Number(col: col, row: row, value: value, numberType: numberType, uniqueID: spriteCount+1)
                            numbers[col,row] = number
                            set.insert(number)
                        default:
                            print("default", terminator: "")
                        }
                    }
                }
            }
            return set //set will be used for displaying sprites
        }
        
        func createEquations(numEquations: Int){
            var value1: Int
            var value2: Int
            var result: Int
            
            //fill array with values to be used, values then used to create number objects with attributes needed for sprite display
            for num in 0..<numEquations {
                switch levelNum{
                case -1:
                   
                    //perform finding random values for equation 1
                    //generate 2 random numbers, set each in value1,2, do addition and put into values array
                    value1 = Int(arc4random_uniform(randRange)) // can change number passed to random fxn to change difficulty
                    value2 = Int(arc4random_uniform(randRange))
                    
                    result = value1 + value2
    
                        values[0, currentRowsFilled] = value1
                        values[1, currentRowsFilled] = value2
                        values[2, currentRowsFilled] = result
                    
                    currentRowsFilled = currentRowsFilled + 1
                    
                    print("current rows filled: \(currentRowsFilled)")
                    print(" ")
                case -2:
                    //subtraction
                    value1 = Int(arc4random_uniform(randRange))
                    value2 = Int(arc4random_uniform(randRange))
                    
                    //make result positive value
                    if value2 > value1 {
                        //swap values
                        let temp1 = value1
                        let temp2 = value2
                        
                        value1 = temp2
                        value2 = temp1
                    }
                    result = value1 - value2
                        
                    self.values[0, currentRowsFilled] = value1
                    self.values[1, currentRowsFilled] = value2
                    self.values[2, currentRowsFilled] = result
                        
                    currentRowsFilled = currentRowsFilled + 1
                        
                    
                    
                case -3:
                    //multiplication
                    value1 = Int(arc4random_uniform(6))
                    value2 = Int(arc4random_uniform(6))
                    
                    result = value2 * value1
                    
                    self.values[0, currentRowsFilled] = value1
                    self.values[1, currentRowsFilled] = value2
                    self.values[2, currentRowsFilled] = result
                    
                    currentRowsFilled = currentRowsFilled + 1
                    
                default:
                    value1 = -1
                    value2 = -1
                    
                    result = -1
                }
                
                //add call to shuffle equation values within their columns - occurs after dropping new equation
                
            }
        }
    /*func getShuffledBoard() -> [[Number]] {
        var columns = [[Number]]()
        
        for col in 0..<NumCol {
            for row in 0..<NumRow {
                if col == 0 || col == 4 || col == 6  {
                    var array = [Number]()
                    for row in 0..<NumRow {
                        ///logic here
                    }
                }
                
            }
        }
    }*/
    
    func dropDownExisting() -> [[Number]] {
        var columns = [[Number]]()
        //**** problem here with gap???
        //loop through rows from bottom to top
        for col in 0..<NumCol {
            
            var array = [Number]()
            for row in 0..<NumRow {
                //hole if nil at this position and position above is not nil
                //print(" col: \(col), row: \(row)", terminator: "")
                if col == 0 || col == 4 || col == 6  {
                    if numbers[col,row] == nil && row+1 < NumRow && containsNumber(col,row: row+1){
                        
                        for lookup in (row + 1)..<NumRow {
                            if let number = numbers[col, lookup] {
                                numbers[col, lookup] = nil
                                numbers[col, row] = number
                                number.row = row
                            
                                //add number to array, need them in order for animation purposes (when dropping down, higher numbers have longer delays)
                                array.append(number)
                                //print("appended to array", terminator: "")
                        
                                //don't need to scan farther, break from loop
                                break
                            }
                        }
                    }
                } else {
                    break
                }
                //if colum does not have any holes, don't add to final array
                if !array.isEmpty {
                    columns.append(array)
                }
            }
        }
        
        currentRowsFilled = currentRowsFilled - 1
        
        return columns
    }
    
    func addNewRow() -> Set<Number> {
        //logic to add new row after unsuccessful match OR just to add
        //createEquations(1)
        //new row will be stored in values[currentRowsFilled,...]
        
        var newSet = Set<Number>()

        var numberType: NumberType
        let row = currentRowsFilled
        //make new equation values
        var value1 = Int(arc4random_uniform(randRange)) // can change number passed to random fxn to change difficulty
        var value2 = Int(arc4random_uniform(randRange))
        var result: Int
        
        //make value1 greater than value 2
        if value2 > value1 {
            let temp1 = value1
            let temp2 = value2
            
            value1 = temp2
            value2 = temp1
        }
        
        switch levelNum{
        case -1:
            result = value1 + value2
        case -2:
            result = value1 - value2
        case -3:
            result = value1 * value2
        case -4:
            result = value1/value2 //issue here
        default:
            result = value1+value2
        }
        
        
        for col in 0..<NumCol {
            //only generate numbers for valid columns
            if col != 1 && col != 2 && col != 3 && col != 5 {
                switch col {
                case 0:
                    numberType = NumberType.Operand
                    let number = Number(col: col, row: row, value: value1, numberType: numberType, uniqueID: spriteCount+1)
                    numbers[col,row] = number
                    newSet.insert(number)
                case 4:
                    numberType = NumberType.Operand
                    let number = Number(col: col, row: row, value: value2, numberType: numberType, uniqueID: spriteCount+1)
                    numbers[col,currentRowsFilled] = number
                    newSet.insert(number)
                case 6:
                    numberType = NumberType.Result
                    let number = Number(col: col, row: row, value: result, numberType: numberType, uniqueID: spriteCount+1)
                    numbers[col,currentRowsFilled] = number
                    newSet.insert(number)
                default:
                    print("default", terminator: "")
                }
            }
        }
        currentRowsFilled = currentRowsFilled + 1
        return newSet
        
    }
    
    func getCurrentRowsFilled() -> Int {
        return currentRowsFilled
    }
    
    func setCurrentRowsFilled(newRowsFilled: Int) {
        currentRowsFilled = newRowsFilled
    }
    
    func containsNumber(col: Int, row: Int) -> Bool {

            if numbers[col,row] != nil {
                return true
            } else {
                return false
            }
        
        }
    
    func isValidEquation(numsToCheck: Array<Number>) -> Bool
    {
        if numsToCheck.count == 4 {
            //check if its a valid equation
            //print("true", terminator: "")
            
            let result = numsToCheck[3].value
            let value2 = numsToCheck[2].value
            let op = numsToCheck[1].value
            let value1 = numsToCheck[0].value
            //print("op value: \(op)", terminator: "")
            switch op {
            case -1:
                if value1+value2 == result {
                    //print("is valid true", terminator: "")
                    return true
                    
                } else {
                    //print("is valid false", terminator: "")
                    return false
                }
            case -2:
                if value1-value2 == result {
                    //print("equation: \(value2) - \(value1) = \(result)")
                    //print(" ")
                    return true
                } else {
                    //print("equation: \(value2) - \(value1) = \(result)")
                    //print(" ")
                    return false
                }
            case -3:
                if value1*value2 == result {
                    return true
                } else {
                    return false
                }
            default:
                return false
            }
            
        } else {
            print("false", terminator: "")
            return false
        }
    }
    
    func getDifficulty() -> Int {
        return difficulty
    }
    
    func getColA() -> [Int] {
        return colAIndex
    }
    
    func getColB() -> [Int] {
        return colBIndex
    }
    
    func getColC() -> [Int] {
        return colCIndex
    }
    
    func setDifficulty(newDifficulty: Int) {
        
        difficulty = newDifficulty
        
        switch difficulty {
        case 2:
            //randRange = 50
            randRange = 3 //testing
        case 3:
            //randRange = 100
            randRange = 4 //testing
        default:
            randRange = 10
        }
        
    }
    
    func getLevel() -> Int {
        return levelNum
    }
    
    func setLevel(newLevelNum: Int) {
        levelNum = newLevelNum
    }
    
    func clearBoard (numbersToRemove: [Number]) {
        for num in numbersToRemove {
            if num.numberType.rawValue < 3 {  //don't remove operator from grid
                numbers[num.col, num.row] = nil
                //print("number removed from grid", terminator: "")
            }
        }
        
    }
    func removeNumbers(numbersToRemove: Array<Number>) {
        for num in numbersToRemove {
            if num.numberType.rawValue < 3 {  //don't remove operator from grid
               numbers[num.col, num.row] = nil
                //print("number removed from grid", terminator: "")
            }
            
        }
    }
    
    /*func getNumbersCurrentPositionsColA() {
        
        
        
        for i in 0..<currentRowsFilled {
            
        }
        
    }*/
    
    
    
    func shuffleBoard() {
        
        colAIndex.removeAll()
        colBIndex.removeAll()
        colCIndex.removeAll()
        
        var index1 = 0
        var index2 = 0
        
        for i in 0..<currentRowsFilled {
            colAIndex.append(i)
            colBIndex.append(i)
            colBIndex.append(i)
        }
        //var shuffledSet = Set<Number>()
        
        let currentRows = UInt32(currentRowsFilled)
        
        
        
        //perform a number of random swaps of elements within each column to get new locations
        //this is the shuffle! move to its own method!!!!!
        for currentCol in 0..<7 {
            
            if currentCol == 0 || currentCol == 4 || currentCol == 6 {
                for _ in 0..<currentRowsFilled {
                    //print("column swapping: \(currentCol)")
                    for swapCount in 0...1000 { //perform 50 random swaps
                        index1 = Int(arc4random_uniform(currentRows))
                        index2 = Int(arc4random_uniform(currentRows))
                        
                        swap(currentCol, rowIndex1: index1, rowIndex2: index2)
                        //print("SwapCount = \(swapCount)")
                    
                        //want to keep track of new indicies assigned and return it somehow.
                    
                    }//swaps are complete
                
                    
                }
            }
        }
        //print method for swaps - for error checking purposes, not included in final game
        /*for k in 0..<7 {
            if k == 0 || k == 4 || k == 6 {
                for m in 0...currentRowsFilled {
                    let numj = numAtCol(k, row: m)
                    let valuek = numj?.value
                    print("[\(k),\(m) = \(valuek)")
                }
            }
        }*/
        
            
     
        
    }
    func swap(colToSwap: Int, rowIndex1: Int, rowIndex2:Int) {
        
        //swap the indices in tracking array
        let tempidx1 = rowIndex1
        let tempidx2 = rowIndex2
        
        switch colToSwap {
        case 0 :
            colAIndex[rowIndex2] = tempidx1
            colAIndex[rowIndex1] = tempidx2
        case 4:
            colBIndex[rowIndex2] = tempidx1
            colBIndex[rowIndex1] = tempidx2
        case 4:
            colCIndex[rowIndex2] = tempidx1
            colCIndex[rowIndex1] = tempidx2
        default:
            print("default swap")
        }
        
        
        
        let temp1 = numAtCol(colToSwap, row: rowIndex1)
        let temp2 = numAtCol(colToSwap, row: rowIndex2)
        numbers[colToSwap,rowIndex1] = temp2
        numbers[colToSwap,rowIndex1]?.row = rowIndex1
        numbers[colToSwap,rowIndex2] = temp1
        
        //update col information??
        numbers[colToSwap,rowIndex2]?.row = rowIndex2
    }
    
    
}

