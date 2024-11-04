//
//  BHorizontalBlockNode1x2.swift
//  Blocks
//
//  Created by Jevon Williams on 11/3/24.
//

import SpriteKit

class BHorizontalBlockNode1x2: BBoxNode {
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .red) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        // Define the shape of the 2x1 horizontal block
        let shapeCells = [
            (row: 0, col: 0),
            (row: 0, col: 1)
        ]
        setupShape(shapeCells)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
