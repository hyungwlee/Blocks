//
//  BZShapeBlock.swift
//  Blocks
//
//  Created by Jevon Williams on 11/18/24.
//

import Foundation
import SpriteKit

class BZShapedBlock: BBoxNode {
    // List of possible asset names for the block
    private let availableAssets = [
        "Z-Block-1", "Z-Block-2", "Z-Block", // Example assets
        "Group 16309-1", "Group 16309", "Group 16310", "Group 16312-1", "Group 16313", "Group 16314-1", "Group 16316", "Group 16363-1","Group 16316-1"
    ]
    
    // Dictionary mapping asset names to colors
    private let assetColors: [String: UIColor] = [
        "Z-Block-1": .red,   // Example color for Z-Block-1
        "Z-Block-2": .green, // Example color for Z-Block-2
        "Z-Block": .blue,    // Example color for Z-Block
        "Group 16309-1": .yellow,
        "Group 16309": .orange,
        "Group 16310": .purple,
        "Group 16312-1": .cyan,
        "Group 16313": .magenta,
        "Group 16314-1": .brown,
        "Group 16316": .blue,
        "Group 16363-1": .yellow,
        "Group 16316-1": .red
    ]
    
    // Now directly selecting a specific asset (e.g., "Z-Block-1")
    private let selectedAsset = "Group 16316-1"  // Choose the asset you want
    
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .blue) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        
        // Define the Z-shape with relative positions
        let shapeCells = [
            (row: 0, col: 1),  // Top-right block
            (row: 0, col: 0),  // Top-left block
            (row: 1, col: 0),  // Bottom-left block
            (row: 1, col: -1)  // Bottom-right block
        ]
        
        // Assign the selected asset and its color
        let blockColor = assetColors[selectedAsset] ?? .blue  // Default color if not found
        
        // Define assets for each part of the Z-shaped block
        let assets = shapeCells.map { position in
            (name: selectedAsset, position: position)
        }
        
        // Set the color of the block to match the selected asset
        self.color = blockColor
        
        // Initialize the Z-shape with assets
        setupShape(shapeCells, assets: assets)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
