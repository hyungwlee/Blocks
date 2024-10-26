//
//  TTGamePlacingState.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import Foundation
import SpriteKit
import GameplayKit


class BGamePlacingState: GKState {
    weak var scene: BGameScene?
    weak var context: BGameContext?
    
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
        
        // Create an instance of the random block type
        let blockInstance = randomBlockType.init(
            layoutInfo: BLayoutInfo(screenSize: scene.size, boxSize: CGSize(width: scene.tileSize, height: scene.tileSize)), 
            tileSize: scene.tileSize
        )

        // Generate a random shape for the created block instance
        let generatedShapes = context?.gameScene?.generateRandomShapes(for: blockInstance) ?? []
        let shape: [(Int, Int)] = generatedShapes.isEmpty ? [(0, 0)] : [generatedShapes.first!]
        
        // Snap the block to the closest valid grid position
        let snappedGridPosition = snapToGridPosition(for: gridPosition, with: shape)
        
        // Place the block if the snapped position is valid
        placeBlock(shape: shape, at: snappedGridPosition)
    }
    
    private func snapToGridPosition(for gridPosition: (row: Int, col: Int), with shape: [(Int, Int)]) -> (row: Int, col: Int) {
        // Check if the current grid position is valid first
        if isValidPlacement(for: shape, at: gridPosition) {
            return gridPosition
        }
        
        // Try moving in all directions to find a valid position
        for deltaRow in -1...1 {
            for deltaCol in -1...1 {
                let newRow = gridPosition.row + deltaRow
                let newCol = gridPosition.col + deltaCol
                
                let newGridPosition = (newRow, newCol)
                if isValidPlacement(for: shape, at: newGridPosition) {
                    print("Snapped grid position: \(newGridPosition)") // Debugging log
                    return newGridPosition
                }
            }
        }
        
        // If no valid position was found, return the original position
        print("No valid position found, returning original grid position: \(gridPosition)") // Debugging log
        return gridPosition
    }

    private func placeBlock(shape: [(Int, Int)], at gridPosition: (row: Int, col: Int)) {
        let (row, col) = gridPosition
        if isValidPlacement(for: shape, at: gridPosition) {
            // Mark cells as occupied
            for (dx, dy) in shape {
                let newRow = row + dy
                let newCol = col + dx
                scene?.grid[newRow][newCol]?.color = .darkGray // Mark the cell as occupied
                print("Marked cell at (\(newRow), \(newCol)) as occupied") // Debugging log
            }
            print("Placed block at (\(row), \(col))")
            stateMachine?.enter(BGameClearingState.self)
        } else {
            print("Invalid placement for shape at (\(row), \(col))")
        }
    }

    private func isValidPlacement(for shape: [(Int, Int)], at gridPosition: (row: Int, col: Int)) -> Bool {
        for (dx, dy) in shape {
            let newRow = gridPosition.row + dy
            let newCol = gridPosition.col + dx
            
            // Check if the position is out of bounds
            if newRow < 0 || newRow >= scene?.grid.count ?? 0 || newCol < 0 || newCol >= scene?.grid[newRow].count ?? 0 {
                print("Placement out of bounds at (\(newRow), \(newCol))")
                return false // Out of bounds
            }

            // Check if the grid cell is occupied
            if scene?.grid[newRow][newCol]?.color != .lightGray {
                print("Cell at (\(newRow), \(newCol)) is occupied (color: \(String(describing: scene?.grid[newRow][newCol]?.color)))")
                return false // Cell is already occupied
            }
        }
        print("Placement valid for shape at (\(gridPosition.row), \(gridPosition.col))")
        return true // Valid placement
    }
}
