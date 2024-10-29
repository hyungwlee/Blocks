//
//  TTDoubleBlock.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import SpriteKit
import UIKit


class BDoubleBlock: BBoxNode {
    // Initializer with layoutInfo and tileSize
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize)

        // Define the path for a double-width horizontal block
        let doubleBlockWidth = tileSize * 2
        let doubleBlockHeight = tileSize

        // Create the rectangle path for the double block shape
        let doubleBlockPath = UIBezierPath(rect: CGRect(
            origin: CGPoint(x: -doubleBlockWidth / 2, y: -doubleBlockHeight / 2),
            size: CGSize(width: doubleBlockWidth, height: doubleBlockHeight))
        )

        // Set the path for `box` to represent the double block
        box.path = doubleBlockPath.cgPath
        box.fillColor = UIColor.cyan // Explicitly use UIColor.cyan
        box.lineWidth = 2.0 // Adjust line width if needed

        // Add the configured box to the node
        addChild(box)
    }

    // Additional initializer to allow a custom color
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize)

        // Define the path for a double-width horizontal block
        let doubleBlockWidth = tileSize * 2
        let doubleBlockHeight = tileSize

        // Create the rectangle path for the double block shape
        let doubleBlockPath = UIBezierPath(rect: CGRect(
            origin: CGPoint(x: -doubleBlockWidth / 2, y: -doubleBlockHeight / 2),
            size: CGSize(width: doubleBlockWidth, height: doubleBlockHeight))
        )

        // Set the path for `box` to represent the double block
        box.path = doubleBlockPath.cgPath
        box.fillColor = color // Use the provided color
        box.lineWidth = 2.0 // Adjust line width if needed

        // Add the configured box to the node
        addChild(box)
    }

    // Required initializer for NSCoder
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}







