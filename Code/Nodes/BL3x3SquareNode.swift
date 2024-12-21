//
//  BThreeByThreeBlockNode.swift
//  Blocks
//
//  Created by Jevon Williams on 11/3/24.
//

import SpriteKit

class BLSquareBlock3x3: BLBoxNode {
    
    
    // Now directly selecting a specific asset (e.g., "Laughing-1")
    private let selectedAsset = "bl_Laughing"  // Choose the asset you want
    
    required init(layoutInfo: BLLayoutInfo, tileSize: CGFloat, color: UIColor = .clear) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        
        // Define the shape of the 3x3 square block
        var shapeCells: [(row: Int, col: Int)] = []
        for row in 0..<3 {
            for col in 0..<3 {
                shapeCells.append((row: row, col: col))
            }
        }
        
        // Define assets at specific positions (using the selected asset)
        var assets: [(name: String, position: (row: Int, col: Int))] = []
        for row in 0..<3 {
            for col in 0..<3 {
                assets.append((name: selectedAsset, position: (row: row, col: col)))
            }
        }
        
        // Set up the block's shape and assets without modifying grid cell colors
        setupShape(shapeCells, assets: assets)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


