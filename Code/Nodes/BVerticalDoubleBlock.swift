//
//  TTDoubleBlock.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import SpriteKit
import UIKit



class BVDoubleBlock: BBoxNode {

    // Required initializer with layoutInfo, tileSize, and default color
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .green) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize)
        box.removeFromParent() // Remove any existing background shape (box)
        setupBlock(fillColor: color)
    }

    required init?(coder aDecoder: NSCoder) {
        let layoutInfo = BLayoutInfo(screenSize: CGSize(width: 640, height: 480))
        let tileSize: CGFloat = 40.0
        let color: UIColor = .green
        super.init(layoutInfo: layoutInfo, tileSize: tileSize)
        box.removeFromParent() // Remove any existing background shape (box)
        setupBlock(fillColor: color)
    }

    private func setupBlock(fillColor: UIColor) {
        configureDoubleBlock(fillColor: fillColor)
    }

    private func configureDoubleBlock(fillColor: UIColor) {
        // Ensure the layout box size is valid
        guard layoutInfo.boxSize != .zero else {
            print("Error: Layout box size is zero. Ensure layoutInfo is set up correctly.")
            return
        }

        // Create the first block (bottom)
        let bottomBlock = BSingleBlockT(layoutInfo: layoutInfo, tileSize: layoutInfo.boxSize.height, color: fillColor)
        bottomBlock.position = CGPoint(x: 0, y: -layoutInfo.boxSize.height / 2) // Position it down
        addChild(bottomBlock)

        // Create the second block (top)
        let topBlock = BSingleBlockT(layoutInfo: layoutInfo, tileSize: layoutInfo.boxSize.height, color: fillColor)
        topBlock.position = CGPoint(x: 0, y: layoutInfo.boxSize.height / 2) // Position it up
        addChild(topBlock)

        // Ensure all parts are treated as a single unit
        for block in [bottomBlock, topBlock] {
            block.isUserInteractionEnabled = false // Prevent user interaction with individual blocks
        }
    }

    // Override grid dimensions for the double block
    override var gridHeight: Int { 2 } // Two cells tall
    override var gridWidth: Int { 1 }  // One cell wide
}






