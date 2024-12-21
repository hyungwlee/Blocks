//
//  TTSingleBlock.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import SpriteKit

class BLSingleBlock: BLBoxNode {
    
    
    private let selectedAsset = "bl_Laughing-1"  // Choose the asset you want
    
    required init(layoutInfo: BLLayoutInfo, tileSize: CGFloat, color: UIColor = .clear) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        
        let shapeCells = [(row: 0, col: 0)]  // Define single block shape
        
        let assets = [(name: selectedAsset, position: (row: 0, col: 0))]
        
        

        
        // Set up the block's shape and assets without modifying the grid cells' color
        setupShape(shapeCells, assets: assets)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

