//
//  BLShapeNode5Block.swift
//  Blocks
//
//  Created by Prabhdeep Brar on 11/3/24.
//

import SpriteKit

class BLShapeNode5Block: BBoxNode {
    
    // List of possible asset names for the block
    private let availableAssets = [
        "Laughing-1", "Laughing-2", "Laughing", // Example assets
        "Group 16309-1", "Group 16309", "Group 16310", "Group 16312-1", "Group 16313", "Group 16314-1",
    ]
    
    // Dictionary mapping asset names to colors
    private let assetColors: [String: UIColor] = [
        "Laughing-1": .red,   // Example color for Laughing-1
        "Laughing-2": .green, // Example color for Laughing-2
        "Laughing": .blue,    // Example color for Laughing
        "Group 16309-1": .yellow,
        "Group 16309": .orange,
        "Group 16310": .purple,
        "Group 16312-1": .cyan,
        "Group 16313": .magenta,
        "Group 16314-1": .brown
    ]
    
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .purple) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        
        // Define the shape of the 5-block L-shaped block
        let shapeCells = [
            (row: 0, col: 0),
            (row: 1, col: 0),
            (row: 2, col: 0),
            (row: 2, col: 1),
            (row: 2, col: 2)
        ]
        
        // Randomly select an asset from the available assets
        let randomAsset = availableAssets.randomElement() ?? "Laughing-1" // Default if no random selection
        
        // Lookup color for the selected asset
        let blockColor = assetColors[randomAsset] ?? .purple // Default color if not found
        
        // Set the block's color to match the selected asset
        self.color = blockColor
        
        // Define assets at specific positions (only the first position is used as an example here)
        let assets = [
            (name: randomAsset, position: (row: 0, col: 0)),
            (name: randomAsset, position: (row: 1, col: 0)),
            (name: randomAsset, position: (row: 2, col: 0)),
            (name: randomAsset, position: (row: 2, col: 1)),
            (name: randomAsset, position: (row: 2, col: 2))
        ]
        
        // Pass the selected asset and the shape to setupShape
        setupShape(shapeCells, assets: assets)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

