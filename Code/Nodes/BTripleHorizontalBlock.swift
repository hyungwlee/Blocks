//
//  TTHorizontalBlock.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import Foundation
import SpriteKit


class BHorizontalBlock1x3Node: BBoxNode {
    
    // Required initializer with layoutInfo, tileSize, and default color
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: .purple)
        createHorizontalBlock(fillColor: .purple) // Use default color
    }

    // Initializer that allows a custom color
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        createHorizontalBlock(fillColor: color) // Use provided color
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // Helper function to create the 1x3 horizontal block
    private func createHorizontalBlock(fillColor: UIColor) {
        // Ensure the layout box size is valid
        guard layoutInfo.boxSize != .zero else {
            print("Error: Layout box size is zero. Ensure layoutInfo is set up correctly.")
            return
        }

        // Define the size for each square block
        let blockWidth = layoutInfo.boxSize.width
        let blockHeight = layoutInfo.boxSize.height
        
        // Create three individual square blocks to form the horizontal block
        for i in 0..<3 {
            let block = BSingleBlockT(layoutInfo: layoutInfo, tileSize: blockWidth, color: fillColor)
            block.position = CGPoint(x: CGFloat(i) * blockWidth - blockWidth, y: 0) // Position them horizontally
            block.isUserInteractionEnabled = false // Prevent interaction with individual blocks
            addChild(block) // Add each block to the parent node
        }
    }

    // Override grid dimensions for the 1x3 horizontal block
    override var gridHeight: Int { 1 } // One cell tall
    override var gridWidth: Int { 3 }  // Three cells wide
}








