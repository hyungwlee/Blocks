//
//  TTBlockLNode.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import Foundation
import SpriteKit


class BHorizontalBlockLNode: BBoxNode {
    // Required initializer with layoutInfo, tileSize, and default color
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize) // Call the superclass initializer
        createLShapeNode(fillColor: .purple) // Use default color
    }

    // Initializer that allows a custom color
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize) // Call the superclass initializer
        createLShapeNode(fillColor: color) // Use provided color
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder) // Ensure 'override' is used here
    }

    // Helper function to create the L shape node
    private func createLShapeNode(fillColor: UIColor) {
        // Create a path for the L shape
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0)) // Start at the bottom left corner
        path.addLine(to: CGPoint(x: -layoutInfo.boxSize.width * 2, y: 0)) // Use layoutInfo directly
        path.addLine(to: CGPoint(x: -layoutInfo.boxSize.width * 2, y: layoutInfo.boxSize.height)) // Use layoutInfo directly
        path.addLine(to: CGPoint(x: -layoutInfo.boxSize.width, y: layoutInfo.boxSize.height)) // Use layoutInfo directly
        path.addLine(to: CGPoint(x: -layoutInfo.boxSize.width, y: layoutInfo.boxSize.height * 2)) // Use layoutInfo directly
        path.addLine(to: CGPoint(x: 0, y: layoutInfo.boxSize.height * 2)) // Use layoutInfo directly
        path.close() // Close the path to form the L shape

        // Create the shape node with the path
        let lShapeNode = SKShapeNode(path: path.cgPath)
        lShapeNode.fillColor = fillColor // Set the color

        // Remove any additional nodes or shapes that may have been added previously
        self.removeAllChildren() // Ensure no unwanted children are present
        addChild(lShapeNode) // Add the L shape node
    }
}



