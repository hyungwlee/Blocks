//
//  TTVerticalBlock.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import Foundation
import SpriteKit


class BVerticalBlock: BBoxNode {

    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize) // No `color` argument in `super.init`
        configureVerticalBlock(fillColor: UIColor.orange) // Set default color
    }

    // Initializer that allows a custom color
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize) // No `color` argument in `super.init`
        configureVerticalBlock(fillColor: color) // Use the provided color
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // Helper function to configure the vertical block
    private func configureVerticalBlock(fillColor: UIColor) {
        // Define the size for the vertical block (3x height)
        let verticalSize = CGSize(width: layoutInfo.boxSize.width, height: layoutInfo.boxSize.height * 3)

        // Create and set the path for the box representing the vertical block
        let verticalPath = UIBezierPath(rect: CGRect(
            origin: CGPoint(x: -layoutInfo.boxSize.width / 2, y: -layoutInfo.boxSize.height * 1.5),
            size: verticalSize)
        )
        
        // Set the box path and color
        box.path = verticalPath.cgPath
        box.fillColor = fillColor // Use the provided color
        box.lineWidth = 2.0       // Adjust line width if desired

        // No need to addChild(box) since it's already done in BBoxNode
    }
}




