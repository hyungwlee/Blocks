//
//  BLShapeNode.swift
//  Blocks
//
//  Created by Jevon Williams on 11/3/24.
//

import Foundation
import SpriteKit

class BLShapeNode2x2: BBoxNode {
    override var gridHeight: Int { return 2 }
    override var gridWidth: Int { return 2 }

    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .red) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)

        // Define the two rounded rectangles that form the "L" shape
        let bottomRect = UIBezierPath(
            roundedRect: CGRect(x: 0, y: 0, width: tileSize, height: tileSize),
            cornerRadius: 8
        )
        let sideRect = UIBezierPath(
            roundedRect: CGRect(x: 0, y: tileSize, width: tileSize, height: tileSize),
            cornerRadius: 8
        )
        
        // Create shape nodes for each part of the "L" shape
        let bottomBox = SKShapeNode(path: bottomRect.cgPath)
        bottomBox.fillColor = color
        addChild(bottomBox)

        let sideBox = SKShapeNode(path: sideRect.cgPath)
        sideBox.fillColor = color
        addChild(sideBox)
    }

    required init?(coder aDecoder: NSCoder) {
        let layoutInfo = BLayoutInfo(screenSize: CGSize(width: 640, height: 480))
        let tileSize: CGFloat = 40.0
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: .red)

        let bottomRect = UIBezierPath(
            roundedRect: CGRect(x: 0, y: 0, width: tileSize, height: tileSize),
            cornerRadius: 8
        )
        let sideRect = UIBezierPath(
            roundedRect: CGRect(x: 0, y: tileSize, width: tileSize, height: tileSize),
            cornerRadius: 8
        )

        let bottomBox = SKShapeNode(path: bottomRect.cgPath)
        bottomBox.fillColor = .red
        addChild(bottomBox)

        let sideBox = SKShapeNode(path: sideRect.cgPath)
        sideBox.fillColor = .red
        addChild(sideBox)
    }
}

