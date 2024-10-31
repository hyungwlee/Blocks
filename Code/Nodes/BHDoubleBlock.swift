//
//  BHDoubleBlock.swift
//  Blocks
//
//  Created by Jevon Williams on 10/29/24.
//

import SpriteKit
import UIKit

class BHDoubleBlock: BBoxNode {
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .green) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize)
        box.removeFromParent() // Remove any existing background shape (box)
        configureDoubleBlock(fillColor: color) // Use the provided or default color
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        box.removeFromParent() // Remove any existing background shape (box)
    }

    private func configureDoubleBlock(fillColor: UIColor) {
        // Ensure the layout box size is valid
        guard layoutInfo.boxSize != .zero else {
            print("Error: Layout box size is zero. Ensure layoutInfo is set up correctly.")
            return
        }

        // Create the left block at position (0, 0)
        let leftBlock = BSingleBlockT(layoutInfo: layoutInfo, tileSize: tileSize, color: fillColor)
        leftBlock.position = CGPoint(x: 0, y: 0)

        // Create the right block at position (tileSize, 0)
        let rightBlock = BSingleBlockT(layoutInfo: layoutInfo, tileSize: tileSize, color: fillColor)
        rightBlock.position = CGPoint(x: tileSize, y: 0)

        // Add the blocks to the parent node
        addChild(leftBlock)
        addChild(rightBlock)

        // Ensure all parts are treated as a single unit
        for block in [leftBlock, rightBlock] {
            block.isUserInteractionEnabled = false // Prevent user interaction with individual blocks
        }
    }

    // Override grid dimensions for this block type
    override var gridHeight: Int { 1 } // One cell tall
    override var gridWidth: Int { 2 } // Two cells wide
}
