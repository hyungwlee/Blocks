//
//  BSquareNode3x3.swift
//  Blocks
//
//  Created by Jevon Williams on 10/29/24.
//

import SpriteKit


import SpriteKit

class BSquareBlockNode3x3: BBoxNode {
    
    // Required initializer with layoutInfo, tileSize, and optional color
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .cyan) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        configureSquareBlock(tileSize: tileSize, fillColor: color)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // Configures the 3x3 square block by placing single blocks in a 3x3 grid
    private func configureSquareBlock(tileSize: CGFloat, fillColor: UIColor) {
        // Ensure the layout box size is valid
        guard layoutInfo.boxSize != .zero else {
            print("Error: Layout box size is zero. Ensure layoutInfo is set up correctly.")
            return
        }

        // Create a 3x3 grid of blocks
        for row in 0..<3 {
            for col in 0..<3 {
                let block = BSingleBlockT(layoutInfo: layoutInfo, tileSize: tileSize, color: fillColor)
                block.position = CGPoint(x: CGFloat(col - 1) * tileSize, y: CGFloat(1 - row) * tileSize) // Center grid on node
                block.isUserInteractionEnabled = false // Prevent user interaction with individual blocks
                addChild(block)
            }
        }
    }

    // Override grid dimensions for the 3x3 square block
    override var gridHeight: Int { 3 } // Three cells tall
    override var gridWidth: Int { 3 }  // Three cells wide
}

