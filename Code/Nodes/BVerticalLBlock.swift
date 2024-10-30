//
//  TTVerticalLBlock.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import Foundation
import SpriteKit

import SpriteKit

class BVerticalLBlock: BBoxNode {

    // Required initializer with layoutInfo, tileSize, and default color
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .purple) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize)
        configureLShapeBlock(fillColor: color) // Use the provided or default color
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func configureLShapeBlock(fillColor: UIColor) {
        // Ensure the layout box size is valid
        guard layoutInfo.boxSize != .zero else {
            print("Error: Layout box size is zero. Ensure layoutInfo is set up correctly.")
            return
        }

        // Create the individual blocks that form the L shape using BSingleBlockT
        let block1 = BSingleBlockT(layoutInfo: layoutInfo, tileSize: layoutInfo.boxSize.width, color: fillColor) // Top left block
        let block2 = BSingleBlockT(layoutInfo: layoutInfo, tileSize: layoutInfo.boxSize.width, color: fillColor) // Middle left block
        let block3 = BSingleBlockT(layoutInfo: layoutInfo, tileSize: layoutInfo.boxSize.width, color: fillColor) // Bottom left block
        let block4 = BSingleBlockT(layoutInfo: layoutInfo, tileSize: layoutInfo.boxSize.width, color: fillColor) // Bottom middle block
        let block5 = BSingleBlockT(layoutInfo: layoutInfo, tileSize: layoutInfo.boxSize.width, color: fillColor) // Bottom right block

        // Positioning the blocks to form the L shape
        block1.position = CGPoint(x: 0, y: layoutInfo.boxSize.height * 2) // Top left block
        block2.position = CGPoint(x: 0, y: layoutInfo.boxSize.height)     // Middle left block
        block3.position = CGPoint(x: 0, y: 0)                             // Bottom left block
        block4.position = CGPoint(x: layoutInfo.boxSize.width, y: 0)     // Bottom middle block
        block5.position = CGPoint(x: layoutInfo.boxSize.width * 2, y: 0) // Bottom right block

        // Add blocks to the parent node
        addChild(block1)
        addChild(block2)
        addChild(block3)
        addChild(block4)
        addChild(block5)

        // Ensure all parts are treated as a single unit
        for block in [block1, block2, block3, block4, block5] {
            block.isUserInteractionEnabled = false // Prevent user interaction with individual blocks
        }
    }

    // Override grid dimensions for this block type
    override var gridHeight: Int { 3 } // Three cells tall
    override var gridWidth: Int { 3 }  // Three cells wide
}

















