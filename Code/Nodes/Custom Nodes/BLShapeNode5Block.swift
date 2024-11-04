//
//  BLShapeNode5Block.swift
//  Blocks
//
//  Created by Prabhdeep Brar on 11/3/24.
//

import SpriteKit

class BLShapeNode5Block: BBoxNode {
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .purple) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        // Define the shape of the 5-block L-shaped block
        let shapeCells = [
            (row: 0, col: 0),
            (row: 1, col: 0),
            (row: 2, col: 0),
            (row: 2, col: 1),
            (row: 2, col: 2)
        ]

        setupShape(shapeCells)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
