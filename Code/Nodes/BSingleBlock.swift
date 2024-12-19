//
//  TTSingleBlock.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import SpriteKit

class BSingleBlock: BBoxNode {
    private let availableAssets = [
        "Laughing-1", "Laughing-2", "Laughing", 
        "Group 16309-1", "Group 16309", "Group 16310", 
        "Group 16312-1", "Group 16313", "Group 16314-1", 
        "Group 16316", "Group 16363-1"
    ]
    
    
    private let selectedAsset = "Laughing-1"  // Choose the asset you want
    
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .clear) {
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

