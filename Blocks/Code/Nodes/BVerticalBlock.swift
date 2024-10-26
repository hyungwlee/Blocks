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
        // Call the superclass initializer with a default color
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: .orange) // Set the default color for the block
        
        // Create the SKShapeNode for the vertical block
        let verticalSize = CGSize(width: layoutInfo.boxSize.width, height: layoutInfo.boxSize.height * 3)

        // Update the box path to create a vertical block
        box.path = UIBezierPath(rect: CGRect(origin: .zero, size: verticalSize)).cgPath // Set the path for the box
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder) // Ensure 'override' is used here
    }
    
    // Provide the required initializer from the superclass
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color) // Call the superclass initializer
    }
}


