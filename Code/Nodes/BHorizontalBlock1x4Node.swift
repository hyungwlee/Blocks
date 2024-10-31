//
//  BHorizontalBlock1x4Node.swift
//  Blocks
//
//  Created by Jevon Williams on 10/29/24.
//

import Foundation
import SpriteKit


class BHorizontalBlock1x4Node: BBoxNode {
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .cyan) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        box.removeFromParent()
        configureHorizontalBlock(tileSize: tileSize, fillColor: color)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func configureHorizontalBlock(tileSize: CGFloat, fillColor: UIColor) {
        guard layoutInfo.boxSize != .zero else {
            print("Error: Layout box size is zero. Ensure layoutInfo is set up correctly.")
            return
        }

        // Position blocks starting from x = 0 with positive offsets
        for i in 0..<4 {
            let block = BSingleBlockT(layoutInfo: layoutInfo, tileSize: tileSize, color: fillColor)
            block.position = CGPoint(x: CGFloat(i) * tileSize, y: 0)
            block.isUserInteractionEnabled = false
            addChild(block)
        }
    }

    // Correct grid dimensions
    override var gridHeight: Int { 1 }
    override var gridWidth: Int { 4 }
}
