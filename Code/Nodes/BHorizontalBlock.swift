//
//  TTHorizontalBlock.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import Foundation
import SpriteKit

class BHorizontalBlock: BBoxNode {
    // Required initializer with layoutInfo, tileSize, and color
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .green) {
        // Call the superclass initializer
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        
        // Update the path of the existing box shape to represent a horizontal block
        box.path = UIBezierPath(rect: .init(origin: .zero, size: CGSize(width: tileSize * 3, height: tileSize))).cgPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder) // Ensure 'override' is used here
    }
}


