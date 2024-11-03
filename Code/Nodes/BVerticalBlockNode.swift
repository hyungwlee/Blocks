//
//  BVerticalBlockNode.swift
//  Blocks
//
//  Created by Jevon Williams on 11/3/24.
//

import Foundation
import SpriteKit

class BVerticalBlockNode1x2: BBoxNode {
    override var gridHeight: Int { return 2 }
    override var gridWidth: Int { return 1 }

    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .red) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        box = SKShapeNode(rect: .init(origin: .zero, size: CGSize(width: tileSize, height: tileSize * 2)), cornerRadius: 8.0)
        box.fillColor = color
        addChild(box)
    }

    required init?(coder aDecoder: NSCoder) {
        // Call the superclass's designated initializer
        let layoutInfo = BLayoutInfo(screenSize: CGSize(width: 640, height: 480)) // Default layout info
        let tileSize: CGFloat = 40.0 // Default tile size
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: .red) // Call the super initializer

        // Set the box's size and properties for the vertical block
        box = SKShapeNode(rect: .init(origin: .zero, size: CGSize(width: tileSize, height: tileSize * 2)), cornerRadius: 8.0)
        addChild(box)
    }
}
