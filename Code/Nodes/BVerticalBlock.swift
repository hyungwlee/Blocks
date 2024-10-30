//
//  TTVerticalBlock.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import Foundation
import SpriteKit


class BVerticalBlock: BBoxNode {

    private var blocks: [BSingleBlockT] = [] // Array to hold the individual blocks

    // Required initializer with layoutInfo and tileSize
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize)
        createVerticalBlock(fillColor: UIColor.orange) // Set default color
    }

    // Initializer that allows a custom color
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize)
        createVerticalBlock(fillColor: color) // Use the provided color
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // Helper function to create the vertical block using single blocks
    private func createVerticalBlock(fillColor: UIColor) {
        // Clear any existing blocks
        for block in blocks {
            block.removeFromParent()
        }
        blocks.removeAll()

        // Create the individual blocks for the vertical block
        for i in 0..<3 {
            let block = BSingleBlockT(layoutInfo: layoutInfo, tileSize: tileSize, color: fillColor)
            block.position = CGPoint(
                x: 0, // Center horizontally
                y: CGFloat(i) * tileSize - tileSize // Position blocks vertically, centered on the parent node
            )
            block.isUserInteractionEnabled = false // Prevent interaction with individual blocks
            blocks.append(block)
            addChild(block) // Add each block to the parent node
        }
    }

    // Override grid dimensions for this block type
    override var gridHeight: Int { 3 } // Three cells tall
    override var gridWidth: Int { 1 }  // One cell wide
}






