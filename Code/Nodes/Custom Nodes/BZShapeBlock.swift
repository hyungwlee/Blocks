// BZShapedBlock.swift

import Foundation
import SpriteKit

class BZShapedBlock: BBoxNode {
    // List of possible asset names for the block
    private let availableAssets = [
        "Z-Block-1", "Z-Block-2", "Z-Block", // Example assets
        "Group 16309-1", "Group 16309", "Group 16310", "Group 16312-1",
        "Group 16313", "Group 16314-1", "Group 16316", "Group 16363-1", "Group 16316-1","Group 16316-1 "
    ]
    
   
    // Selected asset for the block
    private let selectedAsset = "Group 16316-1 "
    
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .blue) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        
        // Adjusted Z-shape with non-negative coordinates
        let shapeCells = [
            (row: 0, col: 2),  // Top-right block
            (row: 0, col: 1),  // Top-left block
            (row: 1, col: 1),  // Bottom-left block
            (row: 1, col: 0)   // Bottom-right block
        ]
        
        // Define assets for each part of the Z-shaped block
        let assets = shapeCells.map { position in
            (name: selectedAsset, position: position)
        }
        
        
        // Initialize the Z-shape with assets
        setupShape(shapeCells, assets: assets)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
