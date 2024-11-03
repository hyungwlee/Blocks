//
//  BSquareBlock2x2.swift
//  Blocks
//
//  Created by Jevon Williams on 11/2/24.
//
import SpriteKit

class BSquareBlock2x2: BBoxNode {
    override var gridHeight: Int { return 2 }
    override var gridWidth: Int { return 2 }

    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .red) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        // Adjust box size for a 2x2 block
        box = SKShapeNode(rect: .init(origin: .zero, size: CGSize(width: tileSize * CGFloat(gridWidth), height: tileSize * CGFloat(gridHeight))), cornerRadius: 8.0)
        box.fillColor = color
        addChild(box)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Adjust box size for a 2x2 block
        box = SKShapeNode(rect: .init(origin: .zero, size: CGSize(width: tileSize * CGFloat(gridWidth), height: tileSize * CGFloat(gridHeight))), cornerRadius: 8.0)
        box.fillColor = color
        addChild(box)
    }
}
