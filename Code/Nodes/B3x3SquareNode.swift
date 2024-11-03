//
//  B3x3SquareNode.swift
//  Blocks
//
//  Created by Jevon Williams on 11/3/24.
//
import SpriteKit

class BThreeByThreeBlockNode: BBoxNode {
    // Override grid dimensions to define a 3x3 block
    override var gridHeight: Int { return 3 }
    override var gridWidth: Int { return 3 }
    
    private let cornerRadius: CGFloat = 16.0 // Adjust the corner radius as needed

    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .blue) {
        // Call super init with the specified size for the 3x3 block
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        
        // Set the shape size to be 3 tiles wide and 3 tiles tall
        let size = CGSize(width: tileSize * CGFloat(gridWidth), height: tileSize * CGFloat(gridHeight))
        box.path = UIBezierPath(roundedRect: .init(origin: .zero, size: size), cornerRadius: cornerRadius).cgPath
        box.fillColor = color
        box.position = CGPoint(x: 0, y: 0) // Center the box in its node
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Adjust the box size to be 3x3
        let size = CGSize(width: tileSize * CGFloat(gridWidth), height: tileSize * CGFloat(gridHeight))
        box.path = UIBezierPath(roundedRect: .init(origin: .zero, size: size), cornerRadius: cornerRadius).cgPath
        box.fillColor = color
    }

    // You can override any other methods if necessary to provide specific behavior for the 3x3 block
}

