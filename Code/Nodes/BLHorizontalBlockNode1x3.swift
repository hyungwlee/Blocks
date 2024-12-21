//
//  BHorizontalBlockNode1x3.swift
//  Blocks
//
//  Created by Jevon Williams on 11/3/24.
//

import SpriteKit

class BLHorizontalBlockNode1x3: BLBoxNode {
    
    // Now directly selecting a specific asset (e.g., "Laughing-1")
    private let selectedAsset = "bl_Relief"  // Choose the asset you want
    
    required init(layoutInfo: BLLayoutInfo, tileSize: CGFloat, color: UIColor = .green) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        
        // Define the shape of the 3x1 horizontal block
        let shapeCells = [
            (row: 0, col: 0),
            (row: 0, col: 1),
            (row: 0, col: 2)
        ]
        
        
        // Define assets at specific positions (using the selected asset)
        let assets = [
            (name: selectedAsset, position: (row: 0, col: 0)),
            (name: selectedAsset, position: (row: 0, col: 1)),
            (name: selectedAsset, position: (row: 0, col: 2))
        ]
        
        setupShape(shapeCells, assets: assets) // Pass the selected asset and its color
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
