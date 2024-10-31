//
//  TTDoubleBlock.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import SpriteKit
import UIKit



class BVDoubleBlock: BBoxNode {
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .green) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize)
        box.removeFromParent() // Remove any existing background shape (box)
        configureDoubleBlock(fillColor: color)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        box.removeFromParent()
    }

    private func configureDoubleBlock(fillColor: UIColor) {
        guard layoutInfo.boxSize != .zero else {
            print("Error: Layout box size is zero. Ensure layoutInfo is set up correctly.")
            return
        }

        // Bottom block at (0, 0)
        let bottomBlock = BSingleBlockT(layoutInfo: layoutInfo, tileSize: tileSize, color: fillColor)
        bottomBlock.position = CGPoint(x: 0, y: 0)
        addChild(bottomBlock)

        // Top block at (0, tileSize)
        let topBlock = BSingleBlockT(layoutInfo: layoutInfo, tileSize: tileSize, color: fillColor)
        topBlock.position = CGPoint(x: 0, y: tileSize)
        addChild(topBlock)

        // Disable interaction with individual blocks
        for block in [bottomBlock, topBlock] {
            block.isUserInteractionEnabled = false
        }
    }

    // Correct grid dimensions
    override var gridHeight: Int { 2 }
    override var gridWidth: Int { 1 }
}
