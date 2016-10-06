//
//  Level.swift
//  MathGame
//
//  Created by Megan Corbett
//  Copyright © 2015 Megan Corbett. All rights reserved.


import Foundation
import GameplayKit

//define dimensions of game grid
let NumCol = 7
let NumRow = 10
var levelNum: Int = -1 //testing addition

var score: Int = 0

var difficulty: Int = 1 //need to change this dynamically throughout gameplay, default difficulty is one
var randRange: UInt32 = 5 //randrange is the max result value/ max value on board, initialized to first difficulty1

let difficulty1 = 5
let difficulty2 = 10
let difficulty3 = 20

var currentRowsFilled = 0

var numbersToClear = [Number]()

var newNumbers = [Number]()

var maxResultValue: Int = -1

let numStartEquations = 3

var isFixedLevel: Bool = false

class Level {
    
    private var numbers = GameGrid<Number>(colCount: NumCol, rowCount: NumRow)
    
    var values = GameGrid<Int>(colCount: NumCol, rowCount: NumRow)
    
    
    func firstFill() -> Set<Number> {
        return createInitialNumbers()
    }
    
    private func createInitialNumbers() -> Set<Number> {
        
        //create a set of numbers including the operator to draw
        var set = Set<Number>()
        
        var op :Number
        
        
        set = addNewRows(numStartEquations)
        
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
        
        return set //set will be used for displaying sprites
    }
    
    func getEquationValues() -> [Int]{
        //creates an array of a single valid equation and returns it
        var equationValues = [Int]()
        
        var value1 = 0
        var value2 = 0
        var result = 0
        
        switch levelNum {
        case -1:
            result = Int(arc4random_uniform(randRange))
            value1 = Int(arc4random_uniform(randRange))
            
            if value1 > result {
                //swap values
                let temp1 = value1
                let temp2 = result
                
                value1 = temp2
                result = temp1
            }
            
            value2 = result - value1
            equationValues = [value1, value2, result]
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
            equationValues = [value1, value2, result]
        case -3:
            //multiplication
            result = Int(arc4random_uniform(randRange))
            value1 = Int(arc4random_uniform(randRange))
            if result == 0 {
                if value1 != 0 {
                    value2 = 0
                } else {
                    value2 = Int(arc4random_uniform(randRange))
                }
            } else if value1 == 0 {
                value2 = Int(arc4random_uniform(randRange))
                result = 0
            } else {
                if value1 > result {
                    //swap values
                    let temp1 = value1
                    let temp2 = result
                    
                    value1 = temp2
                    result = temp1
                }
                while (result % value1) != 0 {
                    value1 = value1 + 1
                }
                value2 = result/value1
                
                equationValues = [value1, value2, result]
                
            }
            
        case -4:
            //division
            value1 = Int(arc4random_uniform(randRange))
            value2 = Int(arc4random_uniform(randRange))
            if value1 == 0 {
                value1 = 1
            }
            if value2 == 0 {
                value2 = 1
            }
            if value1 < value2 {
                let temp1 = value1
                let temp2 = value2
                
                value1 = temp2
                value2 = temp1
            }
            
            
            while (value1 % value2) != 0 {
                value2 = value2 + 1
            }
            
            result = value1/value2
            equationValues = [value1, value2, result]
            
        default:
            print("default")
        }
        return equationValues
        
    }
    
    func isValidEquation(numsToCheck: Array<Number>) -> Bool
    {
        //checks if numbers swiped across form a valid equation
        if numsToCheck.count == 4 {
            //check if its a valid equation
            
            let result = numsToCheck[3].value
            let value2 = numsToCheck[2].value
            //let op = numsToCheck[1].value
            let value1 = numsToCheck[0].value
            
            let calculatedResult = checkValid(value1, num2: value2, calculating: true)
            
            if result == calculatedResult {
                return true
            }
        }
        return false
    }
    
    ////////////////////////functions to perform operations on game board, some based on swipe handling////////////////
    func dropDownExisting() -> [[Number]] {
        var columns = [[Number]]()
        
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
        
        return columns
    }
    
    func addNewRows(numberRows:Int) -> Set<Number> {
        //logic to add new row after unsuccessful match or first fill
        //new dropped row will be stored in values[currentRowsFilled,...]
        
        var newSet = Set<Number>()
        
        var row = 0
        
        var numberType: NumberType
        if numberRows == 1 {
            //if only 1, then just dropping a new row
            row = currentRowsFilled
        }
        
        //array to hold equation values
        var newValues = [Int]()
        
        for _ in 0..<numberRows {
            //get new equation values
            newValues = getEquationValues()
            while newValues.isEmpty {
                //spin until everything has initialized
                newValues = getEquationValues()
            }
            let value1 = newValues[0]
            let value2 = newValues[1]
            let result = newValues[2]
            
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
            row = row+1
            currentRowsFilled = currentRowsFilled + 1
        }
        return newSet
    }
    
    func clearBoard (numbersToRemove: [Number], clearOperator: Bool) {
        for num in numbersToRemove {
            if clearOperator {
                numbers[num.col, num.row] = nil
            }
            else {
                if num.numberType.rawValue < 3 {  //don't remove operator from grid
                    numbers[num.col, num.row] = nil
                }
            }
        }
        
        currentRowsFilled = 0
    }
    
    func removeNumbers(numbersToRemove: Array<Number>) {
        for num in numbersToRemove {
            if num.numberType.rawValue < 3 {  //don't remove operator from grid
                numbers[num.col, num.row] = nil
            }
            
        }
        currentRowsFilled = currentRowsFilled-1
    }
    
    
    
    ////////////////////////functions for shuffling the game board/////////////////////////////////
    func shuffleBoard() -> [[Number]] {
        //updateCurrentRowsFilled()
        
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
    
    func updatePrevY() {
        
        for col in 0..<7 {
            
            if col == 0 || col == 4 || col == 6 {
                for row in 0..<currentRowsFilled {
                    if numbers[col,row] != nil {
                        numbers[col,row]!.prevY = numbers[col,row]!.row
                        
                    }
                }
            }
        }
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
        //updateCurrentRowsFilled()
        var swaps = 0
        
        for col in 0..<NumCol {
            if col == 0 || col == 4 || col == 6  {
                for row in 0..<currentRowsFilled {
                    //make sure at least 1 number has new place
                    //if not perform a random swap
                    if numbers[col, row] != nil{
                        if numAtCol(col, row: row)!.row != numAtCol(col, row: row)!.prevY {
                            swaps = swaps+1
                        }
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
    
    /////////////functions used to detect invalid board settings//////////////////////////////////
    func invalidNumbers() -> Bool {
        
        //check that the numbers on the board can result in a valid result for that level and difficulty
        //if there is anything invalid, update the numbers to update array and return true
        newNumbers.removeAll()
        
        let possibleResults:[Int] = getPossibleResults()

        
        //if there is nothing in possible results, then there is no valid combination of numbers on the board
        if possibleResults.count == 0 {
            //choose a result from column three and change a number/numbers on the board to make it valid
            newNumbers = updateInvalidEquations()

            return true
        } else {
            //check that the results listed are valid, if not change invalid results to valid ones
            let invalidResults = checkAllResultsValid(possibleResults) //array of results that have no matching combo of numbers
            if invalidResults.count > 0 { //there is at least one invalid result to update
                newNumbers = updateInvalidResults(possibleResults, invalidResults: invalidResults)

                return true
            }
        }
        
        return false
        
    }
    
    func getPossibleResults() -> [Int] {
        var num1 = 0
        var num2 = 0
        var result = -1
        
        var validResults:[Int] = []
        
        for row in 0..<9 {
            if numbers[0,row] != nil {
                num1 = numbers[0,row]!.value
                for row in 0..<9 {
                    
                    if numbers[4,row] != nil {
                        num2 = numbers[4,row]!.value
                        //check if result is valid within difficulty range settings
                        //append to a valid results array if it is
                        //result equals operation on num1 and num2
                        result = checkValid(num1, num2: num2, calculating: false)
                        if result >= 0 && !validResults.contains(result) { //only add if not already in list
                            validResults.append(result)
                        }
                        
                    }
                    
                }
            }
        }
        return validResults
    }
    
    func checkAllResultsValid(possibleResults:[Int]) -> [Number] {
        var invalidResults: [Number] = []
        for row in 0..<9 {
            if numbers[6, row] != nil {
                //there's a number here, check if it's in the possible results list
                //if it is, it's fine, if not add to invalid results array
                let num1 = numbers[6,row]!.value
                if !possibleResults.contains(num1) {
                    invalidResults.append(numbers[6,row]!)
                }
            }
        }
        return invalidResults
    }
    
    
    func updateInvalidResults(validResults:[Int], invalidResults:[Number]) -> [Number] {
        
        var numbersToUpdate:[Number] = []
        
        for num in invalidResults {
            //get a random index into the valid results array and set it's value equal to that
            let count = UInt32(validResults.count-1)
            let randIndex = Int(arc4random_uniform(count))
            
            let newValue = validResults[randIndex]
            num.value = newValue
            num.update(newValue)
            numbersToUpdate.append(num)
        }
        return numbersToUpdate
    }
    
    func updateInvalidEquations() -> [Number] {
        //get a random result from column 6 and force there to be a combo of numbers that results in it
        //or just create a new random equation and reset the sprites on the board at row 0 to be that, shuffle is called after anyway
        /*let rowCount = UInt32(currentRowsFilled)
         let randIndex = Int(arc4random_uniform(rowCount))*/
        var numbersToUpdate = [Number]()
        var newValues = getEquationValues()
        
        while newValues.isEmpty {
            //spin until everything has initialized
            newValues = getEquationValues()
        }
        
        //set the bottom most row to be equal to new equation
        if numbers[0,0] != nil && numbers[4,0] != nil && numbers[6,0] != nil {
            let num1 = numbers[0,0]
            let num2 = numbers[4,0]
            let num3 = numbers[6,0]
            
            let newValue1 = newValues[0]
            let newValue2 = newValues[1]
            let newValue3 = newValues[2]
            
            num1!.value = newValue1
            num1?.update(newValue1)
            numbersToUpdate.append(num1!)
            
            num2!.value = newValue2
            num2?.update(newValue2)
            numbersToUpdate.append(num2!)
            
            num3!.value = newValue3
            num3?.update(newValue3)
            numbersToUpdate.append(num3!)
        }
        return numbersToUpdate
    }
    
    func checkValid(num1:Int, num2:Int, calculating: Bool) -> Int {
        //checks whether the combination of a number from column1 and column2 results in a valid or correct result
        var result = -1
        
        switch levelNum {
        case -1:
            result = num1 + num2
            if calculating {
                return result
            }
            switch difficulty {
            case 1:
                if result <= difficulty1 {
                    return result
                }
            case 2:
                if result <= difficulty2 {
                    return result
                }
            case 3:
                if result <= difficulty3 {
                    return result
                }
            default:
                return -1
            }
        case -2:
            result = num1 - num2
            if calculating {
                return result
            }
            if result >= 0 {
                return result
            }
        case -3:
            result = num1*num2
            if calculating {
                return result
            }
            switch difficulty {
            case 1:
                if result <= difficulty1 {
                    return result
                }
            case 2:
                if result <= difficulty2 {
                    return result
                }
            case 3:
                if result <= difficulty3 {
                    return result
                }
            default:
                return -1
            }
        case -4:
            if num1%num2 == 0 {
                result = num1/num2
                return result
            }
        default:
            return -1
        }
        return -1
    }
    
    
    //////////////////////////getters and setters/////////////////////////////
    func getDifficulty() -> Int {
        return difficulty
    }
    
    func setDifficulty(newDifficulty: Int) {
        
        difficulty = newDifficulty
        
        switch difficulty {
        case 1:
            randRange = UInt32(difficulty1)
        case 2:
            randRange = UInt32(difficulty2)
        case 3:
            randRange = UInt32(difficulty3)
        default:
            randRange = UInt32(difficulty2)
        }
        
    }
    
    func getLevel() -> Int {
        return levelNum
    }
    
    func setLevel(newLevelNum: Int) {
        levelNum = newLevelNum
    }
    
    func getNewNumbers() -> [Number] {
        return newNumbers
    }
    
    func getCurrentRowsFilled() -> Int {
        
        return currentRowsFilled
    }
    
    func setIsFixedLevel(fixed: Bool) {
        isFixedLevel = fixed
    }
    
    func setCurrentRowsFilled(newRowsFilled: Int) {
        currentRowsFilled = newRowsFilled
    }
    
    //function to access Number object as specific position in grid
    func numAtCol(col: Int, row: Int) -> Number? {
        
        assert(col >= 0 && col < NumCol)
        assert(row >= 0 && row < NumRow)
        return numbers[col,row]
    }
    
    func containsNumber(col: Int, row: Int) -> Bool {
        
        if numbers[col,row] != nil {
            return true
        } else {
            return false
        }
    }
    
    
    
    func printBoard() {
        //print method for testing
        for row in (0..<currentRowsFilled+1).reverse() {
            
            var num1 = "nil"
            
            var num2 = "nil"
            
            var num3 = "nil"
            
            if numbers[0,row] != nil {
                num1 = String(numbers[0,row]!.value)
            }
            if numbers[4,row] != nil {
                num2 = String(numbers[4,row]!.value)
            }
            if numbers[6,row] != nil {
                num3 = String(numbers[0,row]!.value)
            }
            
            print("[ \(num1)   \(num2)   \(num3)]")
        }
    }
    
}

