//
//  TTHorizontalBlock.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import Foundation
import SpriteKit


class BHorizontalBlock: BBoxNode {
    // Required initializer with layoutInfo and tileSize
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize) // Call the superclass initializer
        
        // Update the path of the existing box shape to represent a horizontal block
        box.path = UIBezierPath(rect: CGRect(origin: .zero, size: CGSize(width: tileSize * 3, height: tileSize))).cgPath
        box.fillColor = .green // Set the default color for the box
        
        // Add the box to the node
        addChild(box)
    }

    // Initializer that allows custom color
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize) // Call the superclass initializer
        
        // Update the path of the existing box shape to represent a horizontal block
        box.path = UIBezierPath(rect: CGRect(origin: .zero, size: CGSize(width: tileSize * 3, height: tileSize))).cgPath
        box.fillColor = color // Set the custom color for the box
        
        // Add the box to the node
        addChild(box)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder) // Ensure 'override' is used here
    }
}





