//
//  TTGamePlacingState.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import Foundation
import SpriteKit
import GameplayKit


import SpriteKit
import GameplayKit

class BGamePlacingState: GKState {
    weak var scene: BGameScene?
    weak var context: BGameContext?
    var currentBlock: BBoxNode.Type? // Reference to the type of block being placed

    init(scene: BGameScene, context: BGameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }

    override func didEnter(from previousState: GKState?) {
        print("Entered Placing State")
    }

    private func getGridPosition(for touchLocation: CGPoint) -> (row: Int, col: Int) {
        let tileSize = scene?.tileSize ?? 40
        let row = Int(touchLocation.y / tileSize)
        let col = Int(touchLocation.x / tileSize)
        return (row, col)
    }

    func handleTouchEnded(_ touch: UITouch) {
        guard let scene = scene else { return }
        let touchLocation = touch.location(in: scene)
        let gridPosition = getGridPosition(for: touchLocation)

        // Randomly select a block type
        let blockTypes: [BBoxNode.Type] = [
            BSingleBlock.self,
            BHorizontalBlock.self,
            BVerticalBlock.self,
            BSquareBlock.self,
            BHorizontalBlockLNode.self,
            BBlockTNode.self,
            BDoubleBlock.self,
            BVerticalLBlock.self
        ]

        let randomBlockType = blockTypes.randomElement() ?? BSingleBlock.self

        // Create an instance of the random block type for occupied cells
        let blockInstance = randomBlockType.init(
            layoutInfo: BLayoutInfo(screenSize: scene.size, boxSize: CGSize(width: scene.tileSize, height: scene.tileSize)),
            tileSize: scene.tileSize
        )

        // Get the occupied cells for the block being placed
        let shape = blockInstance.occupiedCellsForPlacement(row: gridPosition.row, col: gridPosition.col)

        // Snap the block to the closest valid grid position
        let snappedGridPosition = snapToGridPosition(for: gridPosition, with: shape)

        // Place the block if the snapped position is valid
        placeBlock(shape: shape, at: snappedGridPosition, blockType: randomBlockType)
    }

    private func snapToGridPosition(for gridPosition: (row: Int, col: Int), with shape: [GridCoordinate]) -> (row: Int, col: Int) {
        // Check if the current grid position is valid first
        if isValidPlacement(for: shape, at: gridPosition) {
            return gridPosition
        }

        // Try moving in all directions to find a valid position
        for deltaRow in -1...1 {
            for deltaCol in -1...1 {
                let newRow = gridPosition.row + deltaRow
                let newCol = gridPosition.col + deltaCol

                if isValidPlacement(for: shape, at: (newRow, newCol)) {
                    return (newRow, newCol)
                }
            }
        }

        return gridPosition // Return the original if no new valid positions found
    }

    func isCellOccupied(row: Int, col: Int) -> Bool {
        guard let scene = scene else { return true }
        return scene.isCellOccupied(row: row, col: col)
    }

   // Set a specific cell in the grid as occupied by the currently dragged node
func setCellOccupied(row: Int, col: Int, with block: BBoxNode) {
    guard let scene = scene else { return }
    scene.setCellOccupied(row: row, col: col, with: block)
}


    private func isValidPlacement(for shape: [GridCoordinate], at position: (row: Int, col: Int)) -> Bool {
        for coordinate in shape {
            let occupiedRow = position.row + coordinate.row
            let occupiedCol = position.col + coordinate.col
            
            // Check bounds
            if occupiedRow < 0 || occupiedRow >= (scene?.gridSize ?? 10) || occupiedCol < 0 || occupiedCol >= (scene?.gridSize ?? 10) {
                return false // Out of bounds
            }

            // Check if occupied
            if isCellOccupied(row: occupiedRow, col: occupiedCol) {
                return false // Cell already occupied
            }
        }
        return true // Valid placement
    }

   private func placeBlock(shape: [GridCoordinate], at position: (row: Int, col: Int), blockType: BBoxNode.Type) {
    guard let scene = scene else { return }

    for coordinate in shape {
        let occupiedRow = position.row + coordinate.row
        let occupiedCol = position.col + coordinate.col
        
        // Create a new instance of the block for marking as occupied
        let blockInstance = blockType.init(
            layoutInfo: BLayoutInfo(screenSize: scene.size, boxSize: CGSize(width: scene.tileSize, height: scene.tileSize)), 
            tileSize: scene.tileSize
        )
        
        setCellOccupied(row: occupiedRow, col: occupiedCol, with: blockInstance) // Mark as occupied

        // Set the position of the block
        blockInstance.position = CGPoint(x: CGFloat(occupiedCol) * scene.tileSize, y: CGFloat(occupiedRow) * scene.tileSize)

        // Check if the block already has a parent
        if blockInstance.parent != nil {
            blockInstance.removeFromParent() // Remove it from its parent if it exists
        }

        // Add the block to the scene
        scene.addChild(blockInstance)
    }
    
    // Clean up and prepare for the next state
    context?.nextState = .none
}

}





