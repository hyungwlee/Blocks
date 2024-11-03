//
//  RotatedLShapeNode2x2.swift
//  Blocks
//
//  Created by Jevon Williams on 11/3/24.
//

import Foundation
import SpriteKit

class BRotatedLShapeNode2x2: BBoxNode {
    override var gridHeight: Int { return 2 }
    override var gridWidth: Int { return 2 }

    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .red) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)

        // Define the two rounded rectangles to form the rotated "L" shape
        let topRect = UIBezierPath(
            roundedRect: CGRect(x: 0, y: tileSize, width: tileSize, height: tileSize),
            cornerRadius: 8
        )
        let sideRect = UIBezierPath(
            roundedRect: CGRect(x: tileSize, y: 0, width: tileSize, height: tileSize * 2),
            cornerRadius: 8
        )
        
        // Create shape nodes for each part of the rotated "L" shape
        let topBox = SKShapeNode(path: topRect.cgPath)
        topBox.fillColor = color
        addChild(topBox)

        let sideBox = SKShapeNode(path: sideRect.cgPath)
        sideBox.fillColor = color
        addChild(sideBox)
    }

    required init?(coder aDecoder: NSCoder) {
        let layoutInfo = BLayoutInfo(screenSize: CGSize(width: 640, height: 480))
        let tileSize: CGFloat = 40.0
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: .red)

        let topRect = UIBezierPath(
            roundedRect: CGRect(x: 0, y: tileSize, width: tileSize, height: tileSize),
            cornerRadius: 8
        )
        let sideRect = UIBezierPath(
            roundedRect: CGRect(x: tileSize, y: 0, width: tileSize, height: tileSize * 2),
            cornerRadius: 8
        )

        let topBox = SKShapeNode(path: topRect.cgPath)
        topBox.fillColor = .red
        addChild(topBox)

        let sideBox = SKShapeNode(path: sideRect.cgPath)
        sideBox.fillColor = .red
        addChild(sideBox)
    }
}

