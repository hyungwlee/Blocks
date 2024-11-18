//
//  BT5Block.swift
//  Blocks
//
//  Created by Jevon Williams on 11/18/24.
//

import Foundation
import SpriteKit

class BTShapedBlock: BBoxNode {
    // List of possible asset names for the block
    private let availableAssets = [
        "T-Block-1", "T-Block-2", "T-Block", // Example assets
        "Group 16309-1", "Group 16309", "Group 16310", "Group 16312-1", "Group 16313", "Group 16314-1", "Group 16316", "Group 16363-1", "Dead"
    ]
    
    // Dictionary mapping asset names to colors
    private let assetColors: [String: UIColor] = [
        "T-Block-1": .red,   // Example color for T-Block-1
        "T-Block-2": .green, // Example color for T-Block-2
        "T-Block": .blue,    // Example color for T-Block
        "Group 16309-1": .yellow,
        "Group 16309": .orange,
        "Group 16310": .purple,
        "Group 16312-1": .cyan,
        "Group 16313": .magenta,
        "Group 16314-1": .brown,
        "Group 16316": .blue,
        "Group 16363-1": .yellow,
        "Dead": .green
    ]
    
    // Now directly selecting a specific asset (e.g., "T-Block-1")
    private let selectedAsset = "Dead"  // Choose the asset you want
    
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .blue) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        
        // Define the T-shape with relative positions
        let shapeCells = [
            (row: -1, col: 0),  // Top block
            (row: 0, col: -1),  // Left block
            (row: 0, col: 0),   // Center block
            (row: 0, col: 1),   // Right block
            (row: 1, col: 0)    // Bottom block
        ]
        
        // Assign the selected asset and its color
        let blockColor = assetColors[selectedAsset] ?? .blue  // Default color if not found
        
        // Define assets for each part of the T-shaped block
        let assets = shapeCells.map { position in
            (name: selectedAsset, position: position)
        }
        
        // Set the color of the block to match the selected asset
        self.color = blockColor
        
        // Initialize the T-shape with assets
        setupShape(shapeCells, assets: assets)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
