//
//  BHorizontalBlockNode.swift
//  Blocks
//
//  Created by Jevon Williams on 11/3/24.
//

import Foundation
import SpriteKit

class BHorizontalBlockNode1x2: BBoxNode {
    override var gridHeight: Int { return 1 }
    override var gridWidth: Int { return 2 }

    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .red) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        box = SKShapeNode(rect: .init(origin: .zero, size: CGSize(width: tileSize * 2, height: tileSize)), cornerRadius: 8.0)
        box.fillColor = color
        addChild(box)
    }

    required init?(coder aDecoder: NSCoder) {
        // Call the superclass's designated initializer
        let layoutInfo = BLayoutInfo(screenSize: CGSize(width: 640, height: 480)) // Default layout info
        let tileSize: CGFloat = 40.0 // Default tile size
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: .red) // Call the super initializer

        // Set the box's size and properties for the horizontal block
        box = SKShapeNode(rect: .init(origin: .zero, size: CGSize(width: tileSize * 2, height: tileSize)), cornerRadius: 8.0)
        addChild(box)
    }
}
