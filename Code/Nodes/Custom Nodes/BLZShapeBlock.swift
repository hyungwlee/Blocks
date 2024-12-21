// BZShapedBlock.swift

import Foundation
import SpriteKit

class BLZShapedBlock: BLBoxNode {
   
    // Selected asset for the block
    private let selectedAsset = "bl_Mad"
    
    required init(layoutInfo: BLLayoutInfo, tileSize: CGFloat, color: UIColor = .blue) {
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
