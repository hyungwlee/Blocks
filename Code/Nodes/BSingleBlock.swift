//
//  TTSingleBlock.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import Foundation
import SpriteKit


class BSingleBlock: BBoxNode {
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize)

        // Set the main block's path to a horizontal rectangle
        box.path = UIBezierPath(rect: .init(origin: .zero, size: CGSize(width: tileSize * 3, height: tileSize))).cgPath

        // Create a smaller box to represent the 'T' shape
        let smallBox = SKShapeNode(rect: .init(origin: CGPoint(x: tileSize, y: 0), size: CGSize(width: tileSize, height: tileSize)), cornerRadius: 8.0)
        smallBox.fillColor = .cyan
        addChild(smallBox)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
