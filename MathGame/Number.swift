//
//  Number.swift
//  MathGame
//
//  Created by Megan Corbett 
//  Copyright © 2015 Megan Corbett. All rights reserved.
//

import Foundation
import SpriteKit

enum NumberType: Int {
    case unknown = 0, Operand, Result, AddOperator, SubOperator, MultOperator, DivOperator
    
}

class Number: CustomStringConvertible, Hashable {
    
    var col: Int //col, row to keep track of position in grid
    var row: Int
    
    var value: Int
    let numberType: NumberType
    var sprite: SKSpriteNode?
    
    var spriteName: String
    
    var highlightedSpriteName: String
    
    init(col: Int, row: Int, value: Int, numberType: NumberType) {
        self.col = col
        self.row = row
        self.value = value
        
        self.numberType = numberType
        
        switch numberType.rawValue {
        case 1:
            spriteName = "\(value)"
        case 2:
            spriteName = "\(value)Result"
        case 3:
            spriteName = "AddOp"
        case 4:
            //spriteName = "SubOp"
            spriteName = "AddOp"
        case 5:
            spriteName = "MultOp"
        case 6:
            spriteName = "DivOp"
        default:
            spriteName = "null"
        }
        
        /*if numberType.rawValue == 1 {
            spriteName = "\(value)"
        } else if numberType.rawValue == 2 {
            spriteName = "\(value)Result"
        } else if numberType.rawValue == 3 {
            spriteName = "AddOp"
        } else if numberType.rawValue == 4 {
            spriteName = "SubOp"
        } else if numberType.rawValue == 5 {
            spriteName = "MultOp"
        } else if numberType.rawValue == 6 {
            spriteName = "DivOp"
        } else {
            spriteName = "null"
        }*/
        
        highlightedSpriteName = spriteName + "-Highlighted"
      
    }
    var description: String {
        return "type: \(numberType) location: (\(col), \(row), value: \(value), spriteName: \(spriteName)"
    }
    
    var hashValue: Int {
        return row*10+col //return unique hash value for number object
    }
    
}

func ==(lhs: Number, rhs: Number) -> Bool {
    return lhs.col == rhs.col && lhs.row == rhs.row
}


