//
//  BRightLBlock2x2.swift
//  Blocks
//
//  Created by Jevon Williams on 10/30/24.
//
import SpriteKit


class BRightFacingLBlockNode: BBoxNode {
 // Initializer with layoutInfo, tileSize, and optional color
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .purple) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        configureLShapeBlock(tileSize: tileSize, fillColor: color)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // Configure the L shape by positioning blocks accordingly
    private func configureLShapeBlock(tileSize: CGFloat, fillColor: UIColor) {
        // Ensure the layout box size is valid
        guard layoutInfo.boxSize != .zero else {
            print("Error: Layout box size is zero. Ensure layoutInfo is set up correctly.")
            return
        }

        // Define positions for the L shape, where (0, 0) is the bottom left of the L
        let positions = [
            CGPoint(x: 0, y: 0),                  // Bottom-left block
            CGPoint(x: tileSize, y: 0),           // Bottom-right block
            CGPoint(x: tileSize, y: tileSize),    // Top-right block
        ]
        
        // Create and position each block in the L shape
        for position in positions {
            let block = BSingleBlockT(layoutInfo: layoutInfo, tileSize: tileSize, color: fillColor)
            block.position = position
            block.isUserInteractionEnabled = false // Prevent user interaction with individual blocks
            addChild(block)
        }
    }

    // Override grid dimensions for the L-shape block
    override var gridHeight: Int { 2 } // Two cells tall
    override var gridWidth: Int { 2 }  // Two cells wide
}


