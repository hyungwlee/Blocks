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
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: .purple) // Pass default color
        
        // Create a path for the vertical L shape
        let path = UIBezierPath()

        // Draw the vertical L shape
        path.move(to: CGPoint(x: 0, y: layoutInfo.boxSize.height * 2)) // Start at the top left
        path.addLine(to: CGPoint(x: layoutInfo.boxSize.width * 2, y: layoutInfo.boxSize.height * 2)) // Move to the top right
        path.addLine(to: CGPoint(x: layoutInfo.boxSize.width * 2, y: layoutInfo.boxSize.height)) // Move down to the right middle
        path.addLine(to: CGPoint(x: layoutInfo.boxSize.width, y: layoutInfo.boxSize.height)) // Move left to the middle
        path.addLine(to: CGPoint(x: layoutInfo.boxSize.width, y: 0)) // Move down to the bottom middle
        path.addLine(to: CGPoint(x: 0, y: 0)) // Move left to the bottom left
        path.close() // Close the path to form the vertical L shape

        // Set the path for the box shape node
        box.path = path.cgPath // Set the path for the box
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder) // Ensure 'override' is used here
    }
    
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color) // Call the superclass initializer
    }
}












