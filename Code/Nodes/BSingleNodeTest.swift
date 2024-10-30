//
//  BSingleNodeTest.swift
//  Blocks
//
//  Created by Jevon Williams on 10/30/24.
//

import Foundation

import SpriteKit

class BSingleBlockT: BBoxNode {
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .blue) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)

        // Create a square block using the layoutInfo for size
        box = SKShapeNode(rect: .init(origin: .zero, size: layoutInfo.boxSize), cornerRadius: 8.0)
        box.fillColor = color // Use the provided color
        addChild(box) // Add the box as a child to this node
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
