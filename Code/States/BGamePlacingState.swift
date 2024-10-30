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
        BVerticalBlock.self,
        BSquareBlock.self,
        BHorizontalBlock1x3Node.self,
        BBlockTNode.self,
        BHDoubleBlock.self,
        BVerticalLBlock.self,
        BHorizontalBlock1x4Node.self,
        BVerticalBlock1x4Node.self,
        BSquareBlockNode3x3.self,
        BRightFacingLBlockNode.self,
    ]

    let randomBlockType = blockTypes.randomElement() ?? BSingleBlock.self

    // Create an instance of the random block type
    let blockInstance = randomBlockType.init(
        layoutInfo: BLayoutInfo(screenSize: scene.size, boxSize: CGSize(width: scene.tileSize, height: scene.tileSize)), 
        tileSize: scene.tileSize
    )

    // Generate random shapes for the created block instance
    guard let generatedShapes = context?.gameScene?.generateRandomShapes(count: 3) else {
        print("Failed to generate shapes for block type: \(randomBlockType)")
        return
    }

    // Ensure we have valid shapes
    guard !generatedShapes.isEmpty else {
        print("No valid shapes generated for block type: \(randomBlockType)")
        return
    }

    // Convert GridCoordinate to [(Int, Int)]
    let shape: [(Int, Int)] = generatedShapes.map { coordinate in
        // Ensure that 'coordinate' is of type GridCoordinate
        guard let gridCoordinate = coordinate as? GridCoordinate else {
            print("Generated shape is not a GridCoordinate")
            return (0, 0) // Provide a default value or handle the error appropriately
        }
        return (gridCoordinate.row, gridCoordinate.col) // Access row and col
    }

    // Snap the block to the closest valid grid position
    let snappedGridPosition = snapToGridPosition(for: gridPosition, with: shape)

    // Place the block if the snapped position is valid
    if isValidPlacement(for: shape, at: snappedGridPosition) {
        placeBlock(shape: shape, at: snappedGridPosition)
    } else {
        print("Snapped position \(snappedGridPosition) is invalid for shape \(shape)")
    }
}





    // Example function to generate random shapes
    func generateRandomShapes(count: Int) -> [GridCoordinate] {
        var shapes: [GridCoordinate] = []
        
        // Example logic to generate random shapes within grid bounds
        for _ in 0..<count {
            let randomRow = Int.random(in: 0..<10) // Assuming a 10-row grid
            let randomCol = Int.random(in: 0..<10) // Assuming a 10-column grid
            shapes.append(GridCoordinate(row: randomRow, col: randomCol))
        }
        
        return shapes
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
                let newRow = row + dy // Assuming dy is row offset
                let newCol = col + dx // Assuming dx is column offset
                
                // Check bounds and mark
                guard newRow >= 0, newRow < (scene?.grid.count ?? 0), newCol >= 0, newCol < (scene?.grid[newRow].count ?? 0) else {
                    print("Skipping out of bounds at (\(newRow), \(newCol))")
                    continue // Skip if out of bounds
                }

                // Mark the cell as occupied
                scene?.grid[newRow][newCol]?.color = .darkGray
                print("Marked cell at (\(newRow), \(newCol)) as occupied")
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






