//
//  BVerticalBlockNode1x4.swift
//  Blocks
//
//  Created by Jevon Williams on 11/3/24.
//

import Foundation
import SpriteKit
class BVerticalBlockNode1x4: BBoxNode {
    override var gridHeight: Int { return 4 } // Height of the vertical block
    override var gridWidth: Int { return 1 }  // Width of the vertical block

    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .blue) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)

        // Create the vertical block path
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0)) // Starting point (bottom)
        path.addLine(to: CGPoint(x: 0, y: tileSize * 4)) // Vertical line up
        path.addLine(to: CGPoint(x: tileSize, y: tileSize * 4)) // Right line up
        path.addLine(to: CGPoint(x: tileSize, y: 0)) // Right line down
        path.close() // Close the path

        box = SKShapeNode(path: path.cgPath) // Create shape node from the path
        box.fillColor = color
        addChild(box)
    }

    required init?(coder aDecoder: NSCoder) {
        // Call the superclass's designated initializer
        let layoutInfo = BLayoutInfo(screenSize: CGSize(width: 640, height: 480)) // Default layout info
        let tileSize: CGFloat = 40.0 // Default tile size
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: .blue) // Call the super initializer

        // Create the vertical block path
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0)) // Starting point (bottom)
        path.addLine(to: CGPoint(x: 0, y: tileSize * 4)) // Vertical line up
        path.addLine(to: CGPoint(x: tileSize, y: tileSize * 4)) // Right line up
        path.addLine(to: CGPoint(x: tileSize, y: 0)) // Right line down
        path.close() // Close the path

        box = SKShapeNode(path: path.cgPath) // Create shape node from the path
        addChild(box)
    }
}
