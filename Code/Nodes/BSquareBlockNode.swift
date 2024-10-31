//
//  TTSquareBlockNode.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import Foundation
import SpriteKit


class BSquareBlock: BBoxNode {
    
    private var blocks: [[BSingleBlockT]] = [] // 2D array to hold the individual blocks

    // Required initializer with layoutInfo and tileSize
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize)
        box.removeFromParent() // Remove any existing background shape (box)
        createSquareBlock(fillColor: UIColor.systemPink) // Set default color
    }
    
    // Additional initializer to allow a custom color
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize)
        box.removeFromParent() // Remove any existing background shape (box)
        createSquareBlock(fillColor: color) // Use the provided color
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // Helper function to create the square block using individual blocks
    private func createSquareBlock(fillColor: UIColor) {
        for row in 0..<2 {
            for column in 0..<2 {
                let block = BSingleBlockT(layoutInfo: layoutInfo, tileSize: tileSize, color: fillColor)
                block.position = CGPoint(
                    x: CGFloat(column) * tileSize,
                    y: CGFloat(row) * tileSize
                )
                block.isUserInteractionEnabled = false
                addChild(block)
            }
        }
    }


    // Override grid dimensions for the 2x2 square block
    override var gridHeight: Int { 2 } // Two cells tall
    override var gridWidth: Int { 2 }  // Two cells wide
}
















