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
        "Group 16309-1", "Group 16309", "Group 16310", "Group 16312-1","Group 16313","Group 16314-1",
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
    
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .red) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        
        // Define the shape of the 1x2 vertical block
        let shapeCells = [
            (row: 0, col: 0),
            (row: 1, col: 0)
        ]
        
        // Randomly select an asset from the available assets
        let randomAsset = availableAssets.randomElement() ?? "Laughing-1" // Default if no random selection
        
        // Lookup color for the selected asset
        let blockColor = assetColors[randomAsset] ?? .red // Default color if not found
        
        // Set the block's color to match the selected asset
        self.color = blockColor
        
        // Define assets at specific positions (here, the same asset is placed in each of the 1x2 cells)
        let assets = [
            (name: randomAsset, position: (row: 0, col: 0)),
            (name: randomAsset, position: (row: 1, col: 0))
        ]
        
        setupShape(shapeCells, assets: assets) // Pass the randomly selected asset and its color
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

