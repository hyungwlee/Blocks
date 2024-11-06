//
//  BHorizontalBlockNode1x3.swift
//  Blocks
//
//  Created by Jevon Williams on 11/3/24.
//

import SpriteKit

class BHorizontalBlockNode1x3: BBoxNode {
    
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
    
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .green) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        
        // Define the shape of the 3x1 horizontal block
        let shapeCells = [
            (row: 0, col: 0),
            (row: 0, col: 1),
            (row: 0, col: 2)
        ]
        
        // Randomly select an asset from the available assets
        let randomAsset = availableAssets.randomElement() ?? "Laughing-1" // Default if no random selection
        
        // Lookup color for the selected asset
        let blockColor = assetColors[randomAsset] ?? .green // Default color if not found
        
        // Set the block's color to match the selected asset
        self.color = blockColor
        
        // Define assets at specific positions (here, the same asset is placed in all 3x1 cells)
        let assets = [
            (name: randomAsset, position: (row: 0, col: 0)),
            (name: randomAsset, position: (row: 0, col: 1)),
            (name: randomAsset, position: (row: 0, col: 2))
        ]
        
        setupShape(shapeCells, assets: assets) // Pass the randomly selected asset and its color
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

