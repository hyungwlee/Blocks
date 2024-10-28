//
//  TTBlockTNode.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import Foundation
import SpriteKit

class BBlockTNode: BBoxNode {
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: .cyan)

        box.path = UIBezierPath(rect: .init(origin: .zero, size: CGSize(width: tileSize * 3, height: tileSize))).cgPath

        let smallBox = SKShapeNode(rect: .init(origin: CGPoint(x: tileSize, y: 0), size: CGSize(width: tileSize, height: tileSize)), cornerRadius: 8.0)
        smallBox.fillColor = .cyan
        addChild(smallBox)
    }

    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
