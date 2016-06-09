//
//  Equation.swift
//  MathGame
//
//  Created by Megan Corbett on 12/15/15.
//  Copyright © 2015 Megan Corbett. All rights reserved.
//

import Foundation


class Equation {
    
    enum OperationType: Int {
        case unknown = 0, add, subtract, multiply, divide
        
    }
    
    var value1: Int
    var value2: Int
    var result: Int
    
    init(opType: OperationType) {
        //perform finding random values for equation 1
        //generate 2 random numbers, set each in value1,2; then use operator to determine result value
        value1 = Int(arc4random_uniform(10))
        value2 = Int(arc4random_uniform(10))
        let opNum: Int = opType.rawValue-1
        switch opNum{
        case 1:
            result = value1 + value2
        case 2:
            if value1 > value2 {
                result = value1 - value2
            }
            else{
                result = value2 - value1
            }
        default:
            value1 = -1
            value2 = -1
            
            result = -1
        }
        
    }
}