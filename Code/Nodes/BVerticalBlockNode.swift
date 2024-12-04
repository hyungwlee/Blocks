//
//  BVerticalBlockNode1x2.swift
//  Blocks
//
//  Created by Jevon Williams on 11/3/24.
//

import SpriteKit

class BVerticalBlockNode1x2: BBoxNode {
    
    // List of possible asset names for the block
  private let availableAssets = [
        "Laughing-1", "Laughing-2", "Laughing", // Example assets
        "Group 16309-1", "Group 16309", "Group 16310", "Group 16312-1", "Group 16313", "Group 16314-1", "Group 16316" ,"Group 16363-1"
    ]
    
  
    
    // Now directly selecting a specific asset (e.g., "Laughing-1")
    private let selectedAsset = "Group 16309-1"  // Choose the asset you want
    
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .red) {
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


