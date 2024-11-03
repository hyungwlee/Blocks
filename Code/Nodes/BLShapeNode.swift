//
//  BLShapeNode.swift
//  Blocks
//
//  Created by Jevon Williams on 11/3/24.
//

import Foundation
import SpriteKit

class BLShapeNode2x2: BBoxNode {
    override var gridHeight: Int { return 2 } // Height of the L shape
    override var gridWidth: Int { return 2 }  // Width of the L shape

    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .red) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)

        // Create the L-shaped path
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0)) // Starting point (bottom-left)
        path.addLine(to: CGPoint(x: tileSize, y: 0)) // Bottom line
        path.addLine(to: CGPoint(x: tileSize, y: tileSize)) // Right line up
        path.addLine(to: CGPoint(x: tileSize * 2, y: tileSize)) // Right line to top-right
        path.addLine(to: CGPoint(x: tileSize * 2, y: tileSize * 2)) // Right line down to bottom-right
        path.addLine(to: CGPoint(x: 0, y: tileSize * 2)) // Left line down to bottom-left
        path.close() // Close the path

        box = SKShapeNode(path: path.cgPath) // Create shape node from the path
        box.fillColor = color
        addChild(box)
    }

    required init?(coder aDecoder: NSCoder) {
        // Call the superclass's designated initializer
        let layoutInfo = BLayoutInfo(screenSize: CGSize(width: 640, height: 480)) // Default layout info
        let tileSize: CGFloat = 40.0 // Default tile size
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: .red) // Call the super initializer

        // Create the L-shaped path
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0)) // Starting point (bottom-left)
        path.addLine(to: CGPoint(x: tileSize, y: 0)) // Bottom line
        path.addLine(to: CGPoint(x: tileSize, y: tileSize)) // Right line up
        path.addLine(to: CGPoint(x: tileSize * 2, y: tileSize)) // Right line to top-right
        path.addLine(to: CGPoint(x: tileSize * 2, y: tileSize * 2)) // Right line down to bottom-right
        path.addLine(to: CGPoint(x: 0, y: tileSize * 2)) // Left line down to bottom-left
        path.close() // Close the path

        box = SKShapeNode(path: path.cgPath) // Create shape node from the path
        addChild(box)
    }
}
