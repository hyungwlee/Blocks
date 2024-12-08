// BTShapedBlock.swift

import Foundation
import SpriteKit

class BTShapedBlock: BBoxNode {
    // List of possible asset names for the block
    private let availableAssets = [
        "T-Block-1", "T-Block-2", "T-Block", // Example assets
        "Group 16309-1", "Group 16309", "Group 16310", "Group 16312-1",
        "Group 16313", "Group 16314-1", "Group 16316", "Group 16363-1", "Dead 1"
    ]
    
    
    // Selected asset for the block
    private let selectedAsset = "Dead 1"
    
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .blue) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        
        // Adjusted T-shape with non-negative coordinates
        let shapeCells = [
            (row: 0, col: 1),  // Top block (centered)
            (row: 1, col: 0),  // Left block
            (row: 1, col: 1),  // Center block
            (row: 1, col: 2)   // Right block
        ]
        
     
        
        // Define assets for each part of the T-shaped block
        let assets = shapeCells.map { position in
            (name: selectedAsset, position: position)
        }
        
      
        
        // Initialize the T-shape with assets
        setupShape(shapeCells, assets: assets)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
