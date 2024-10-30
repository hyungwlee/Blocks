//
//  BHorizontalBlock1x4Node.swift
//  Blocks
//
//  Created by Jevon Williams on 10/29/24.
//

import Foundation
import SpriteKit


class BHorizontalBlock1x4Node: BBoxNode {

    // Required initializer with layoutInfo, tileSize, and default color
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .cyan) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        
        // Remove any background shape (box) if it exists
        box.removeFromParent()
        
        configureHorizontalBlock(tileSize: tileSize, fillColor: color)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // Helper function to configure the horizontal block using single blocks
    private func configureHorizontalBlock(tileSize: CGFloat, fillColor: UIColor) {
        // Ensure the layout box size is valid
        guard layoutInfo.boxSize != .zero else {
            print("Error: Layout box size is zero. Ensure layoutInfo is set up correctly.")
            return
        }

        // Create four blocks positioned horizontally
        for i in 0..<4 {
            let block = BSingleBlockT(layoutInfo: layoutInfo, tileSize: tileSize, color: fillColor)
            block.position = CGPoint(x: CGFloat(Double(i) - 1.5) * tileSize, y: 0) // Space them horizontally
            block.isUserInteractionEnabled = false // Prevent user interaction with individual blocks
            addChild(block)
        }
    }

    // Override grid dimensions for the 1x4 horizontal block
    override var gridHeight: Int { 1 } // One cell tall
    override var gridWidth: Int { 4 }  // Four cells wide
}



