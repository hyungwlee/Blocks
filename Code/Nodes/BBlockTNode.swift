//
//  TTBlockTNode.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import Foundation
import SpriteKit



class BBlockTNode: BBoxNode {
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .cyan) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        configureTBlock(tileSize: tileSize, fillColor: color)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func configureTBlock(tileSize: CGFloat, fillColor: UIColor) {
        // Ensure the layout box size is valid
        guard layoutInfo.boxSize != .zero else {
            print("Error: Layout box size is zero. Ensure layoutInfo is set up correctly.")
            return
        }

        // Create the horizontal part of the T using three blocks
        let horizontalBlock1 = BSingleBlockT(layoutInfo: layoutInfo, tileSize: tileSize, color: fillColor)
        horizontalBlock1.position = CGPoint(x: 0, y: 0) // Center the horizontal block
        addChild(horizontalBlock1)

        let horizontalBlock2 = BSingleBlockT(layoutInfo: layoutInfo, tileSize: tileSize, color: fillColor)
        horizontalBlock2.position = CGPoint(x: tileSize, y: 0) // Right of the first block
        addChild(horizontalBlock2)

        let horizontalBlock3 = BSingleBlockT(layoutInfo: layoutInfo, tileSize: tileSize, color: fillColor)
        horizontalBlock3.position = CGPoint(x: -tileSize, y: 0) // Left of the first block
        addChild(horizontalBlock3)

        // Create the vertical part of the T using one block
        let verticalBlock = BSingleBlockT(layoutInfo: layoutInfo, tileSize: tileSize, color: fillColor)
        verticalBlock.position = CGPoint(x: 0, y: -tileSize) // Below the horizontal block
        addChild(verticalBlock)

        // Ensure all parts are treated as a single unit
        for block in [horizontalBlock1, horizontalBlock2, horizontalBlock3, verticalBlock] {
            block.isUserInteractionEnabled = false // Prevent user interaction with individual blocks
        }
    }

    // Override grid dimensions for the T-shape
    override var gridHeight: Int { 2 } // Two cells tall
    override var gridWidth: Int { 3 }  // Three cells wide
}






