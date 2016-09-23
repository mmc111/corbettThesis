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
var randRange: UInt32 = 10 //default for range will be 10 (4 for testing purposes until sprites updated)

var currentRowsFilled = 0

var numbersToClear = [Number]()

var newResults = [Number]()

var maxResultValue: Int = -1

class Level {
    
    //var levelNumber: Int = 0
    
    private var numbers = GameGrid<Number>(colCount: NumCol, rowCount: NumRow)
    private var tempNumbers = GameGrid<Number>(colCount: NumCol, rowCount: NumRow)
    
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
            op = Number(col: 2, row: 2, value: -1, numberType: NumberType.AddOperator, prevY: -1)
        case -2:
            op = Number(col: 2, row: 2, value: -2, numberType: NumberType.SubOperator, prevY: -2)
        case -3:
            op = Number(col: 2, row: 2, value: -3, numberType: NumberType.MultOperator, prevY: -3)
        case -4:
            op = Number(col: 2, row: 2, value: -4, numberType: NumberType.DivOperator, prevY: -4)
        default:
            op = Number(col: 2, row: 2, value: -1, numberType: NumberType.AddOperator, prevY: -1)
            
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
                            let number = Number(col: col, row: row, value: value, numberType: numberType, prevY: row) //creating Number objects with values and sprite names
                            numbers[col,row] = number
                            set.insert(number)
                        case 4:
                            numberType = NumberType.Operand
                            value = self.values[1, row]!
                            let number = Number(col: col, row: row, value: value, numberType: numberType, prevY: row)
                            numbers[col,row] = number
                            set.insert(number)
                        case 6:
                            numberType = NumberType.Result
                            value = self.values[2, row]!
                            let number = Number(col: col, row: row, value: value, numberType: numberType, prevY: row)
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
            for _ in 0..<numEquations {
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
            }
        }

    
    func dropDownExisting() -> [[Number]] {
        var columns = [[Number]]()
        //**** problem here with gap???
        //loop through rows from bottom to top
        for col in 0..<NumCol {
            
            var array = [Number]()
            for row in 0..<NumRow {
                //hole if nil at this position and position above is not nil
                if col == 0 || col == 4 || col == 6  {
                    if numbers[col,row] == nil && row+1 < NumRow && containsNumber(col,row: row+1){
                        
                        for lookup in (row + 1)..<NumRow {
                            if let number = numbers[col, lookup] {
                                numbers[col, lookup] = nil
                                numbers[col, row] = number
                                number.row = row
                            
                                //add number to array, need them in order for animation purposes (when dropping down, higher numbers have longer delays)
                                array.append(number)
                        
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
            }//end for row
        }//end for col
        
        currentRowsFilled = currentRowsFilled - 1
        
        //check that the reduced set of numbers has valid results
        newResults.removeAll()
        let invalidResults = hasValidResults()
        if invalidResults.count > 0 {
            //reset values in number to something valid
            
            newResults = handleInvalidResults(invalidResults)
            //now need to scene will be updated during number drop
        }
        
        return columns
    }
    func getNewResults() -> [Number] {
        return newResults
    }
    
    func clearNewResults() {
        newResults.removeAll()
    }
    
    func handleInvalidResults(invalidResults: [Number]) -> [Number] {
        //see if there are any numbers missing results
        //or get random numbers for indicies into columns, perform operation and update
        let currentRows = UInt32(currentRowsFilled)
        
        let index1 = Int(arc4random_uniform(currentRows))
        let index2 = Int(arc4random_uniform(currentRows))
        var newValue = -1
        var updatedResults: [Number] = []
        for num in invalidResults {
            
            let value1 = numAtCol(0, row: index1)!.value
            let value2 = numAtCol(4, row: index2)!.value
            
            switch levelNum {
            case -1:
                newValue = value1+value2
            case -2:
                newValue = value1-value2
            case -3:
                newValue = value1*value2
            case -4:
                newValue = value1/value2
            default:
                newValue = -1
            }
            
            num.value = newValue
            num.update(newValue)
            
            updatedResults.append(num)
        }
            return updatedResults
        
    }
    
    func addNewRow() -> Set<Number> {
        //logic to add new row after unsuccessful match OR just to add
        //createEquations(1)
        //new row will be stored in values[currentRowsFilled,...]
        
        var newSet = Set<Number>()

        var numberType: NumberType
        let row = currentRowsFilled
        //make new equation values
        //work backwards instead??
        
        //get max result size, then generate a random number to op with it
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
            while value1%value2 != 0
            {
                value2 = value2+1
            }
            result = value1/value2
        default:
            result = value1+value2
        }
        
        
        for col in 0..<NumCol {
            //only generate numbers for valid columns
            if col != 1 && col != 2 && col != 3 && col != 5 {
                switch col {
                case 0:
                    numberType = NumberType.Operand
                    let number = Number(col: col, row: row, value: value1, numberType: numberType, prevY: row)
                    numbers[col,row] = number
                    newSet.insert(number)
                case 4:
                    numberType = NumberType.Operand
                    let number = Number(col: col, row: row, value: value2, numberType: numberType, prevY: row)
                    numbers[col,currentRowsFilled] = number
                    newSet.insert(number)
                case 6:
                    numberType = NumberType.Result
                    let number = Number(col: col, row: row, value: result, numberType: numberType, prevY: row)
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
        var numRows = 0
        for row in 0..<10 {
            if containsNumber(0, row: row){
                numRows = numRows+1
            }
        }
        currentRowsFilled = numRows
        return currentRowsFilled
    }
    
    func setCurrentRowsFilled(newRowsFilled: Int) {
        currentRowsFilled = newRowsFilled
    }
    
    func updateCurrentRowsFilled() {
        var numRows = 0
        for row in 0..<10 {
            if containsNumber(0, row: row){
                numRows = numRows+1
            }
        }
        currentRowsFilled = numRows
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
            
            let result = numsToCheck[3].value
            let value2 = numsToCheck[2].value
            let op = numsToCheck[1].value
            let value1 = numsToCheck[0].value
            
            switch op {
            case -1:
                if value1+value2 == result {
                    return true
                    
                } else {

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
    
    
    func setDifficulty(newDifficulty: Int) {
        
        difficulty = newDifficulty
        
        switch difficulty {
        case 2:
            //randRange = 50
            randRange = 20 //testing
        case 3:
            //randRange = 100
            randRange = 50 //testing
        default:
            randRange = 100
        }
        
    }
    
    func getLevel() -> Int {
        return levelNum
    }
    
    func setLevel(newLevelNum: Int) {
        levelNum = newLevelNum
        if levelNum == -2 {
            //remove add sprite, put subtraction
        }
    }
    
    func clearBoard (numbersToRemove: [Number]) {
        for num in numbersToRemove {
            if num.numberType.rawValue < 3 {  //don't remove operator from grid
                numbers[num.col, num.row] = nil
            }
        }
        
    }
    
    func removeNumbers(numbersToRemove: Array<Number>) {
        for num in numbersToRemove {
            if num.numberType.rawValue < 3 {  //don't remove operator from grid
               numbers[num.col, num.row] = nil
            }
            
        }
        currentRowsFilled = currentRowsFilled-1
    }

    
    func updatePrevY() {
        for col in 0..<7 {
            
            if col == 0 || col == 4 || col == 6 {
                for row in 0..<currentRowsFilled {
                    numbers[col,row]!.prevY = numbers[col,row]!.row
                }
            }
        }
    }
    
    func shuffleBoard() -> [[Number]] {
        
        updatePrevY()
    
        var columns = [[Number]]()
        
        shuffle()
        
        //loop through rows from bottom to top
        for col in 0..<NumCol {
            
            var array = [Number]()
            for row in 0..<currentRowsFilled {
                
                if col == 0 || col == 4 || col == 6  {
                    if numbers[col,row] != nil {
                        let number = numbers[col, row]
                        array.append(number!)
                    }
                }
            }
            columns.append(array)
        }
        
       return columns
    }
    
    func shuffle(){
        
        let currentRows = UInt32(currentRowsFilled)
        var index1 = 0
        var index2 = 0
        
        //perform a number of random swaps of elements within each column to get new locations
        for currentCol in 0..<7 {
            
            if currentCol == 0 || currentCol == 4 || currentCol == 6 {
                for _ in 0..<currentRowsFilled {
                    for _ in 0...10000 { //perform x random swaps
                        index1 = Int(arc4random_uniform(currentRows))
                        index2 = Int(arc4random_uniform(currentRows))
                        
                        swap(currentCol, rowIndex1: index1, rowIndex2: index2)
                        
                    }//swaps are complete
                }
            }
        }
        checkForSwap() //make sure every column had at least 1 swap
    }
    
    func swap(colToSwap: Int, rowIndex1: Int, rowIndex2:Int) {
        
        let temp1 = numAtCol(colToSwap, row: rowIndex1)
        let temp2 = numAtCol(colToSwap, row: rowIndex2)
        
        numbers[colToSwap,rowIndex1] = temp2
        numbers[colToSwap,rowIndex1]?.row = rowIndex1
        numbers[colToSwap,rowIndex2] = temp1
        numbers[colToSwap,rowIndex2]?.row = rowIndex2
    }
    
    func checkForSwap() {
        
        var swaps = 0
        
        for col in 0..<NumCol {
            if col == 0 || col == 4 || col == 6  {
                for row in 0..<currentRowsFilled {
                        //make sure at least 1 number has new place
                        //if not perform a random swap
                    if numAtCol(col, row: row)!.row != numAtCol(col, row: row)!.prevY {
                            swaps = swaps+1
                    }
                    
                }
                if swaps == 0 {
                    //perform a swap
                    let currentRows = UInt32(currentRowsFilled)
                    let index1 = Int(arc4random_uniform(currentRows))
                    var index2 = Int(arc4random_uniform(currentRows))
                    while(index1 == index2) {
                        index2 = Int(arc4random_uniform(currentRows))//make sure the rows are different
                    }
                    swap(col, rowIndex1: index1, rowIndex2: index2)
                }
                else {
                    swaps = 0
                }
            }
        }
    }
    
    func hasValidResults() -> [Number] {
        //checking that there is at least one combo of numbers in columns a and b that results in a value in column c
        var possibleResults:[Int] = []
        var invalidResults:[Number] = []
        
        var value1 = -1
        var value2 = -1
        var result = -1

        for row in 0..<getCurrentRowsFilled() {
            
            value1 = numAtCol(0, row: row)!.value
            
            for row1 in 0..<getCurrentRowsFilled() {
                value2 = numAtCol(4, row: row1)!.value
            
                switch levelNum {
                case -1:
                    result = value1+value2
                case -2:
                    result = value1-value2
                case -3:
                    result = value1*value2
                case -4:
                    result = value1/value2
                default:
                    result = -1
                    
                }
                possibleResults.append(result)
            }
        }
        for row in 0..<getCurrentRowsFilled() {
            if !possibleResults.contains(numAtCol(6, row: row)!.value) {

                invalidResults.append(numAtCol(6, row: row)!)
            }
        }
        return invalidResults
    }
    
}

