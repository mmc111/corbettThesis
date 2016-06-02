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
        
        let opNum: Int = opType.rawValue-1
        switch opNum{
        case 1:
            //perform finding random values for equation 1
            //generate 2 random numbers, set each in value1,2, do addition and
            value1 = Int(arc4random_uniform(10))
            value2 = Int(arc4random_uniform(10))
            
            result = value1 + value2
        default:
            value1 = -1
            value2 = -1
            
            result = -1
        }
        
    }
}