//
//  BRotatedLShape2x2.swift
//  Blocks
//
//  Created by Jevon Williams on 11/11/24.
//

import Foundation
import SpriteKit

class BLRotatedLShapeNode2x2: BLBoxNode {
    
    private let selectedAsset = "bl_Straight"  // Choose the asset you want
    
    required init(layoutInfo: BLLayoutInfo, tileSize: CGFloat, color: UIColor = .orange) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        
        // Define the shape cells for a 180-degree rotation of the L-shape
        let shapeCells = [
            (row: 0, col: 1),
            (row: 1, col: 1),
            (row: 1, col: 0)
        ]
        
        
        // Define assets at specific positions for the rotated shape
        let assets = [
            (name: selectedAsset, position: (row: 0, col: 1)),
            (name: selectedAsset, position: (row: 1, col: 1)),
            (name: selectedAsset, position: (row: 1, col: 0))
        ]
        
        // Pass the modified shape and assets to setupShape
        setupShape(shapeCells, assets: assets)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
