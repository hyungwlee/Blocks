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

        // Define the size for a 2x1 horizontal block
        let blockWidth = layoutInfo.boxSize.width
        let blockHeight = layoutInfo.boxSize.height

        // Create the left block
        let leftBlock = BSingleBlockT(layoutInfo: layoutInfo, tileSize: blockWidth, color: fillColor)
        leftBlock.position = CGPoint(x: -blockWidth / 2, y: 0) // Left of center

        // Create the right block
        let rightBlock = BSingleBlockT(layoutInfo: layoutInfo, tileSize: blockWidth, color: fillColor)
        rightBlock.position = CGPoint(x: blockWidth / 2, y: 0) // Right of center

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
    override var gridWidth: Int { 2 }  // Two cells wide
}



