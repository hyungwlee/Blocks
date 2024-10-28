//
//  TTBlockLNode.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import Foundation
import SpriteKit

class BHorizontalBlockLNode: BBoxNode {
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .purple) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)

        // Create a path for the L shape
        let path = UIBezierPath()

        // Draw the L shape facing the other way
        path.move(to: CGPoint(x: 0, y: 0)) // Start at the bottom left corner
        path.addLine(to: CGPoint(x: -layoutInfo.boxSize.width * 2, y: 0)) // Move to the bottom left corner
        path.addLine(to: CGPoint(x: -layoutInfo.boxSize.width * 2, y: layoutInfo.boxSize.height)) // Move up to the middle left
        path.addLine(to: CGPoint(x: -layoutInfo.boxSize.width, y: layoutInfo.boxSize.height)) // Move right to the middle
        path.addLine(to: CGPoint(x: -layoutInfo.boxSize.width, y: layoutInfo.boxSize.height * 2)) // Move up to the top middle
        path.addLine(to: CGPoint(x: 0, y: layoutInfo.boxSize.height * 2)) // Move right to the top right corner
        path.close() // Close the path to form the L shape

        // Create the shape node with the path
        let lShapeNode = SKShapeNode(path: path.cgPath)
        lShapeNode.fillColor = color // Use the provided color

        // Remove any additional nodes or shapes that may have been added previously
        self.removeAllChildren() // Ensure no unwanted children are present
        addChild(lShapeNode) // Add only the L shape node
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}




