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
    var initialScale: CGFloat

    // Calculate tile size based on the available screen width and grid padding
    var tileSize: CGFloat {
        let gridPadding: CGFloat = 20.0 // Padding for smaller screens
        return (screenSize.width - gridPadding * 2) / CGFloat(gridSize)
    }

    // Calculate the cell size based on the box size and initial scale factor
    var cellSize: CGFloat {
        return boxSize.width * initialScale
    }

    // Determine how many boxes can fit in the width of the screen
    var boxesInWidth: Int {
        return Int((screenSize.width - 20) / (boxSize.width * initialScale))
    }

    // Determine how many boxes can fit in the height of the screen
    var boxesInHeight: Int {
        return Int((screenSize.height - 20) / (boxSize.height * initialScale))
    }

    // Calculate the grid size based on the screen size and box size with initial scaling
    var gridSize: Int {
        let availableHeight = screenSize.height - 150 // Increase padding to ensure space for score
        let availableWidth = screenSize.width - 20

        let cols = Int(availableWidth / (boxSize.width * initialScale))
        let rows = Int(availableHeight / (boxSize.height * initialScale))

        let gridSizeCalculated = min(cols, rows)

        // For smaller screens, reduce the maximum grid size
        return max(min(gridSizeCalculated, 10), 4)
    }

  var gridOrigin: CGPoint {
    let totalGridWidth = CGFloat(gridSize) * cellSize
    let totalGridHeight = CGFloat(gridSize) * cellSize

    // Center horizontally
    let gridOriginX = (screenSize.width - totalGridWidth) / 2

    // Adjust vertical positioning based on screen size
    var topMargin: CGFloat
    var bottomMargin: CGFloat
    var additionalOffset: CGFloat
    
    // Adjust for different screen sizes
    if screenSize.height <= 667 {  // SE (smaller screen)
        topMargin = screenSize.height * 0.10 // 10% for SE
        bottomMargin = screenSize.height * 0.20 // 20% for SE
        additionalOffset = 70 // Shift grid down on SE
    } else if screenSize.height <= 844 {  // Pro (6.1-inch)
        topMargin = screenSize.height * 0.10 // 10% for Pro
        bottomMargin = screenSize.height * 0.15 // 15% for Pro
        additionalOffset = 20 // Smaller offset for Pro
    } else {  // Pro Max (6.7-inch)
        topMargin = screenSize.height * 0.08 // 8% for Pro Max
        bottomMargin = screenSize.height * 0.15 // 12% for Pro Max
        additionalOffset = 20 // Smaller offset for Pro Max
    }

    // Calculate the vertical grid origin
    let gridOriginY = (screenSize.height - totalGridHeight - topMargin - bottomMargin) / 2 + topMargin + additionalOffset

    // Ensure the grid origin doesn't go too high
    return CGPoint(x: max(gridOriginX, 0), y: max(gridOriginY, topMargin)) // Ensure grid doesn't go too high
}


    // Initializer adjusts initialScale based on the device size
    init(screenSize: CGSize, boxSize: CGSize = CGSize(width: 100, height: 100)) {
        self.screenSize = screenSize
        self.boxSize = boxSize

        // Set initial scale based on device screen size
        if screenSize.width <= 375 && screenSize.height <= 667 {
            self.initialScale = 0.45 // Slightly smaller scale for iPhone SE
        } else if screenSize.width <= 414 {
            self.initialScale = 0.5
        } else {
            self.initialScale = 0.6
        }
    }
}




