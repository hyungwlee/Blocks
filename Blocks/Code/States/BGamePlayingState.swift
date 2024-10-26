//
//  BGamePlayingState.swift
//  Blocks
//
//  Created by Jevon Williams on 10/26/24.
//

import Foundation
import SpriteKit
import GameplayKit

class BGamePlayingState: GKState {
    weak var scene: BGameScene?
    weak var context: BGameContext?

    init(scene: BGameScene, context: BGameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is TTGamePausedState.Type || stateClass is BGameIdleState.Type
    }

    override func didEnter(from previousState: GKState?) {
        print("Game started")
        // Add code to start the game logic, initialize variables, etc.
    }

    // Handle touch began event
    func handleTouchBegan(_ touch: UITouch) {
        let touchLocation = touch.location(in: scene!)
        print("Touch began at: \(touchLocation)")
        // Additional logic can be added here to handle touch began
    }

    // Handle touch ended event
    func handleTouchEnded(_ touch: UITouch, with node: BBoxNode?) {
        let touchLocation = touch.location(in: scene!)
        print("Touch ended at: \(touchLocation) with node: \(String(describing: node))")
        
        guard let draggedNode = node else { return }

        // Here, implement logic to determine if the draggedNode can be placed on the grid.
        // For example, check if the node's position aligns with any grid cell.

        // Placeholder for placement logic
        if let gridCell = getGridCell(for: draggedNode) {
            print("Placing node at: \(gridCell)")
            // Code to place the node on the grid
        } else {
            print("Invalid placement for node.")
        }
    }
    
    // Example method to get the grid cell based on the node's position
    private func getGridCell(for node: BBoxNode) -> (Int, Int)? {
        // Implement logic to convert node's position to grid coordinates
        let nodePosition = node.position
        let gridX = Int(nodePosition.x / scene!.tileSize)
        let gridY = Int(nodePosition.y / scene!.tileSize)
        
        if gridX >= 0 && gridX < scene!.gridSize && gridY >= 0 && gridY < scene!.gridSize {
            return (gridX, gridY)
        }
        return nil
    }
}
