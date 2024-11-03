//
//  BVerticalBlockNode1x3.swift
//  Blocks
//
//  Created by Jevon Williams on 11/3/24.
//

import Foundation
import SpriteKit

class BVerticalBlockNode1x3: BBoxNode {
    override var gridHeight: Int { return 3 } // Height of the vertical block
    override var gridWidth: Int { return 1 }  // Width of the vertical block

    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .blue) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)

        // Create the vertical block path with rounded corners
        let path = UIBezierPath(
            roundedRect: CGRect(x: 0, y: 0, width: tileSize, height: tileSize * 3),
            cornerRadius: 8
        )

        box = SKShapeNode(path: path.cgPath) // Create shape node from the path
        box.fillColor = color
        addChild(box)
    }

    required init?(coder aDecoder: NSCoder) {
        // Call the superclass's designated initializer
        let layoutInfo = BLayoutInfo(screenSize: CGSize(width: 640, height: 480)) // Default layout info
        let tileSize: CGFloat = 40.0 // Default tile size
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: .blue) // Call the super initializer

        // Create the vertical block path with rounded corners
        let path = UIBezierPath(
            roundedRect: CGRect(x: 0, y: 0, width: tileSize, height: tileSize * 3),
            cornerRadius: 8
        )

        box = SKShapeNode(path: path.cgPath) // Create shape node from the path
        box.fillColor = color
        addChild(box)
    }
}

