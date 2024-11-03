//
//  BHorizontalBlockNode1x4.swift
//  Blocks
//
//  Created by Jevon Williams on 11/3/24.
//

import Foundation
import SpriteKit

class BHorizontalBlockNode1x4: BBoxNode {
    override var gridHeight: Int { return 1 } // Height of the horizontal block
    override var gridWidth: Int { return 4 }  // Width of the horizontal block

    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .green) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)

        // Create the horizontal block path
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0)) // Starting point (left)
        path.addLine(to: CGPoint(x: tileSize * 4, y: 0)) // Horizontal line right
        path.addLine(to: CGPoint(x: tileSize * 4, y: tileSize)) // Down to the right corner
        path.addLine(to: CGPoint(x: 0, y: tileSize)) // Down to the left corner
        path.close() // Close the path

        box = SKShapeNode(path: path.cgPath) // Create shape node from the path
        box.fillColor = color
        addChild(box)
    }

    required init?(coder aDecoder: NSCoder) {
        // Call the superclass's designated initializer
        let layoutInfo = BLayoutInfo(screenSize: CGSize(width: 640, height: 480)) // Default layout info
        let tileSize: CGFloat = 40.0 // Default tile size
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: .green) // Call the super initializer

        // Create the horizontal block path
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0)) // Starting point (left)
        path.addLine(to: CGPoint(x: tileSize * 4, y: 0)) // Horizontal line right
        path.addLine(to: CGPoint(x: tileSize * 4, y: tileSize)) // Down to the right corner
        path.addLine(to: CGPoint(x: 0, y: tileSize)) // Down to the left corner
        path.close() // Close the path

        box = SKShapeNode(path: path.cgPath) // Create shape node from the path
        addChild(box)
    }
}
