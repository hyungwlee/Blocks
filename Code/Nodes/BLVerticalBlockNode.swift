//
//  BVerticalBlockNode1x2.swift
//  Blocks
//
//  Created by Jevon Williams on 11/3/24.
//

import SpriteKit

class BLVerticalBlockNode1x2: BLBoxNode {

  
    
    // Now directly selecting a specific asset (e.g., "Laughing-1")
    private let selectedAsset = "bl_Happy"  // Choose the asset you want
    
    required init(layoutInfo: BLLayoutInfo, tileSize: CGFloat, color: UIColor = .red) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        
        // Define the shape of the 1x2 vertical block
        let shapeCells = [
            (row: 0, col: 0),
            (row: 1, col: 0)
        ]
        
        
        // Define assets at specific positions (using the selected asset)
        let assets = [
            (name: selectedAsset, position: (row: 0, col: 0)),
            (name: selectedAsset, position: (row: 1, col: 0))
        ]
        
        setupShape(shapeCells, assets: assets) // Pass the selected asset and its color
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

