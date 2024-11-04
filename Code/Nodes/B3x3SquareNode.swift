//
//  BThreeByThreeBlockNode.swift
//  Blocks
//
//  Created by Jevon Williams on 11/3/24.
//

import SpriteKit

class BThreeByThreeBlockNode: BBoxNode {
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .blue) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        // Define the shape of the 3x3 square block
        var shapeCells: [(row: Int, col: Int)] = []
        for row in 0..<3 {
            for col in 0..<3 {
                shapeCells.append((row: row, col: col))
            }
        }
        setupShape(shapeCells)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
