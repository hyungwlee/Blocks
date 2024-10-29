//
//  TTSquareBlockNode.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import Foundation
import SpriteKit

class BSquareBlock: BBoxNode {

    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize) // No `color` argument in `super.init`
        configureSquareBlock(fillColor: UIColor.systemPink) // Set default color
    }
    
    // Additional initializer to allow a custom color
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize) // No `color` argument in `super.init`
        configureSquareBlock(fillColor: color) // Use the provided color
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // Helper function to configure the square block
    private func configureSquareBlock(fillColor: UIColor) {
        // Define the size for a 2x2 square block
        let squareWidth = layoutInfo.boxSize.width * 2
        let squareHeight = layoutInfo.boxSize.height * 2
        
        // Create a centered square path
        let squarePath = UIBezierPath(rect: CGRect(
            origin: CGPoint(x: -squareWidth / 2, y: -squareHeight / 2),
            size: CGSize(width: squareWidth, height: squareHeight))
        )
        
        // Set the box path and color
        box.path = squarePath.cgPath
        box.fillColor = fillColor   // Use the provided color
        box.lineWidth = 2.0         // Adjust line width if needed

        // Add the configured box to the node
        addChild(box)
    }
}












