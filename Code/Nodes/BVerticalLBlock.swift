//
//  TTVerticalLBlock.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import Foundation
import SpriteKit


class BVerticalLBlock: BBoxNode {

    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize)
        configureLShapeBlock(fillColor: UIColor.purple)
    }

    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize)
        configureLShapeBlock(fillColor: color)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func configureLShapeBlock(fillColor: UIColor) {
        let path = UIBezierPath()
        // Define the path for the vertical L shape
        path.move(to: CGPoint(x: 0, y: layoutInfo.boxSize.height * 2))
        path.addLine(to: CGPoint(x: layoutInfo.boxSize.width * 2, y: layoutInfo.boxSize.height * 2))
        path.addLine(to: CGPoint(x: layoutInfo.boxSize.width * 2, y: layoutInfo.boxSize.height))
        path.addLine(to: CGPoint(x: layoutInfo.boxSize.width, y: layoutInfo.boxSize.height))
        path.addLine(to: CGPoint(x: layoutInfo.boxSize.width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.close()

        // Set the path and color for the box
        box.path = path.cgPath
        box.fillColor = fillColor
        box.lineWidth = 2.0

        // Ensure the box has no parent before adding
        if box.parent != nil {
            box.removeFromParent()
        }
        
        addChild(box) // Add the box to the node
    }
}














