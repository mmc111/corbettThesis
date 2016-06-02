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

//define dimensions of game grid
let NumCol = 7
let NumRow = 10

var levelNum: Int = -1
var score: Int = 0

var currentRowsFilled = 0

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
            createEquations(3)
            var value: Int
            var numberType: NumberType

            //let op = Number(col: 2, row: 2, value: levelNum, numberType: NumberType.Operator)
            let op = Number(col: 2, row: 2, value: -1, numberType: NumberType.Operator)
            numbers[2,2] = op
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
                            let number = Number(col: col, row: row, value: value, numberType: numberType)
                            numbers[col,row] = number
                            set.insert(number)
                        case 4:
                            numberType = NumberType.Operand
                            value = self.values[1, row]!
                            let number = Number(col: col, row: row, value: value, numberType: numberType)
                            numbers[col,row] = number
                            set.insert(number)
                        case 6:
                            numberType = NumberType.Result
                            value = self.values[2, row]!
                            let number = Number(col: col, row: row, value: value, numberType: numberType)
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
            //print("in create equations, \(numEquations), opNum: \(opNum)")
            for num in 0..<numEquations {
                switch levelNum{
                case -1:
                   
                    //perform finding random values for equation 1
                    //generate 2 random numbers, set each in value1,2, do addition and put into values array
                    value1 = Int(arc4random_uniform(4)) // can change number passed to random fxn to change difficulty
                    value2 = Int(arc4random_uniform(4))
                    
                    result = value1 + value2
    
                        values[0, currentRowsFilled] = value1
                        values[1, currentRowsFilled] = value2
                        values[2, currentRowsFilled] = result
                    
                    currentRowsFilled = currentRowsFilled + 1
                    
                    print("current rows filled: \(currentRowsFilled)", terminator: "")
                case -2:
                    //subtraction
                    value1 = Int(arc4random_uniform(4))
                    value2 = Int(arc4random_uniform(4))
                    
                    //make result positive value
                    if value2 > value1 {
                        //swap values
                        let temp1 = value1
                        let temp2 = value2
                        
                        value1 = temp2
                        value2 = temp1
                        result = value1 - value2
                        
                        self.values[0, currentRowsFilled] = value1
                        self.values[1, currentRowsFilled] = value2
                        self.values[2, currentRowsFilled] = result
                        
                        currentRowsFilled = currentRowsFilled + 1
                        
                    }
                    
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
                
                //add call to shuffle equation values within their columns
                
            }
        }
    func dropDownExisting() -> [[Number]] {
        var columns = [[Number]]()
        
        //loop through rows from bottom to top
        for col in 0..<NumCol {
            
            var array = [Number]()
            for row in 0..<NumRow {
                //hole if nil at this position and position above is not nil
                print(" col: \(col), row: \(row)", terminator: "")
                if col == 0 || col == 4 || col == 6  {
                    if numbers[col,row] == nil && row+1 < NumRow && containsNumber(col,row: row+1){
                        
                        for lookup in (row + 1)..<NumRow {
                            if let number = numbers[col, lookup] {
                                numbers[col, lookup] = nil
                                numbers[col, row] = number
                                number.row = row
                            
                                //add number to array, need them in order for animation purposes (when dropping down, higher numbers have longer delays)
                                array.append(number)
                                print("appended to array", terminator: "")
                        
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
        let value1 = Int(arc4random_uniform(4)) // can change number passed to random fxn to change difficulty
        let value2 = Int(arc4random_uniform(4))
        
        let result = value1 + value2
        
        
        for col in 0..<NumCol {
            //only generate numbers for valid columns
            if col != 1 && col != 2 && col != 3 && col != 5 {
                switch col {
                case 0:
                    numberType = NumberType.Operand
                    let number = Number(col: col, row: row, value: value1, numberType: numberType)
                    numbers[col,row] = number
                    newSet.insert(number)
                case 4:
                    numberType = NumberType.Operand
                    let number = Number(col: col, row: row, value: value2, numberType: numberType)
                    numbers[col,currentRowsFilled] = number
                    newSet.insert(number)
                case 6:
                    numberType = NumberType.Result
                    let number = Number(col: col, row: row, value: result, numberType: numberType)
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
            print("true", terminator: "")
            
            let result = numsToCheck[3].value
            let value2 = numsToCheck[2].value
            let op = numsToCheck[1].value
            let value1 = numsToCheck[0].value
            print("op value: \(op)", terminator: "")
            switch op {
            case -1:
                if value1+value2 == result {
                    print("is valid true", terminator: "")
                    return true
                    
                } else {
                    print("is valid false", terminator: "")
                    return false
                }
            case -2:
                if value2-value1 == result {
                    return true
                } else {
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
    
    func removeNumbers(numbersToRemove: Array<Number>) {
        for num in numbersToRemove {
            if num.numberType != NumberType.Operator {  //don't remove operator from grid
               numbers[num.col, num.row] = nil
                print("number removed from grid", terminator: "")            }
            
        }
    }
    
    }

