//
//  BSquareBlock2x2.swift
//  Blocks
//
//  Created by Jevon Williams on 11/2/24.
//

import SpriteKit

class BLSquareBlock2x2: BLBoxNode {
    
    
    
    // Now directly selecting a specific asset (e.g., "Laughing-1")
    private let selectedAsset = "bl_Laughing-2"  // Choose the asset you want
    
    required init(layoutInfo: BLLayoutInfo, tileSize: CGFloat, color: UIColor = .clear) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        
        // Define the shape of the 2x2 square block
        let shapeCells = [
            (row: 0, col: 0),
            (row: 0, col: 1),
            (row: 1, col: 0),
            (row: 1, col: 1)
        ]
        
        // Define assets at specific positions without setting grid cell colors
        let assets = [
            (name: selectedAsset, position: (row: 0, col: 0)),
            (name: selectedAsset, position: (row: 0, col: 1)),
            (name: selectedAsset, position: (row: 1, col: 0)),
            (name: selectedAsset, position: (row: 1, col: 1))
        ]
        
        setupShape(shapeCells, assets: assets) // Pass the selected asset and positions
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


