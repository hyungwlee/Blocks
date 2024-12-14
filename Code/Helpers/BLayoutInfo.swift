//
//  TTLayoutInfo.swift
//  Blocks
//
//  Created by Jevon Williams on 10/24/24.
//

import Foundation
import CoreGraphics // Ensure you import CoreGraphics for CGSize
import UIKit


struct BLayoutInfo {
    let screenSize: CGSize
    let boxSize: CGSize
    var initialScale: CGFloat // Base scale factor

    // Computed property for dynamic tile size based on screen width and scale factor
    var tileSize: CGFloat {
        return (screenSize.width - 40) / CGFloat(gridSize) * initialScale
    }

    // Static cell size for grid elements, adjusted by scale factor
    var cellSize: CGFloat {
        return boxSize.width * initialScale
    }


    init(screenSize: CGSize, boxSize: CGSize = CGSize(width: 100, height: 100), initialScale: CGFloat = 0.6) {
        self.screenSize = screenSize
        self.boxSize = boxSize
        self.initialScale = initialScale
        // Adjust initialScale based on device type and screen size
            if UIDevice.current.userInterfaceIdiom == .phone {
                   if screenSize.width <= 375 { // Adjust for iPhone SE (3rd generation)
                       self.initialScale = 0.5
                   } else {
                       self.initialScale = initialScale // Use the default initialScale for other iPhones
                   }
               }


    }

    // Number of boxes that fit within the screen width, adjusted by scale factor
    var boxesInWidth: Int {
        return Int((screenSize.width / boxSize.width) * initialScale)
    }

    // Number of boxes that fit within the screen height, adjusted by scale factor
    var boxesInHeight: Int {
        return Int((screenSize.height / boxSize.height) * initialScale)
    }

    // Calculates the position for a box at a specific row and column, adjusting by scale factor
    func positionForBox(atRow row: Int, column: Int) -> CGPoint {
        let x = CGFloat(column) * boxSize.width * initialScale + (boxSize.width / 2) * initialScale
        let y = CGFloat(row) * boxSize.height * initialScale + (boxSize.height / 2) * initialScale
        return CGPoint(x: x, y: y)
    }

    // Additional properties for flexible layout:
    
    // Adjust the grid origin to center the grid on the screen

    var gridSize: Int {
        let maxRows = Int(screenSize.height / cellSize)
        let maxCols = Int(screenSize.width / cellSize)
        return min(maxRows, maxCols)
    }

    var gridOrigin: CGPoint {
        let x = (screenSize.width - CGFloat(gridSize) * cellSize) / 2.0
        let y = (screenSize.height - CGFloat(gridSize) * cellSize) / 2.0
        return CGPoint(x: x, y: y)
    }


}
