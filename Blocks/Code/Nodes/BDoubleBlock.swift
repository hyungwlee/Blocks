//
//  TTDoubleBlock.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import Foundation
import SpriteKit

class BDoubleBlock: BBoxNode {
    // Required initializer with layoutInfo, tileSize, and color
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .orange) {
        // Call the superclass initializer
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        
        // Update the path of the existing box shape to represent a double block
        box.path = UIBezierPath(rect: CGRect(origin: .zero, size: CGSize(width: tileSize * 2, height: tileSize))).cgPath
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
