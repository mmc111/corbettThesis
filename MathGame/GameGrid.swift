//
//  GameGrid.swift
//  MathGame
//
//  Created by Megan Corbett 
//  Copyright © 2015 Megan Corbett. All rights reserved.
//creates a 2d array to be used as a grid for storing objects used during game play

import Foundation

struct GameGrid<T> {
    let colCount: Int
    let rowCount: Int
    
    private var grid: Array<T?>
    
    init(colCount: Int, rowCount: Int) {
        self.colCount = colCount
        self.rowCount = rowCount
        
        grid = Array<T?>(count: colCount*rowCount, repeatedValue: nil)
    }
    
    //use subscript to index the array
    subscript(col: Int, row: Int) -> T? {
        get{
            return grid[row*colCount + col]
        }
        set {
            grid[row*colCount + col] = newValue
        }
    }
}