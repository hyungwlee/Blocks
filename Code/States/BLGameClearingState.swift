//
//  BGameClearingState.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import SpriteKit
import GameplayKit

class BLGameClearingState: GKState {
    weak var scene: BLGameScene?
    weak var context: BLGameContext?

    init(scene: BLGameScene, context: BLGameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }

    override func didEnter(from previousState: GKState?) {
        print("Entered Clearing State")
        clearCompletedLines()
        // Transition back to Idle state after clearing
        stateMachine?.enter(BLGameIdleState.self)
    }

    private func clearCompletedLines() {
        guard let scene = scene else { return }
        var grid = scene.grid
        var rowsToClear: Set<Int> = []

        // Identify completed rows
        for row in 0..<grid.count {
            if grid[row].allSatisfy({ $0 != nil }) {
                rowsToClear.insert(row)
            }
        }

        // Clear the rows and update the grid
        for row in rowsToClear {
            for col in 0..<grid[row].count {
                grid[row][col]?.removeFromParent() // Remove block from the scene
                grid[row][col] = nil // Reset grid entry
            }
        }

        // Update score or any other game state as needed
        if !rowsToClear.isEmpty {
            let clearedRowsCount = rowsToClear.count
            scene.score += clearedRowsCount // Update score based on cleared rows
            print("Cleared rows: \(rowsToClear), Score: \(scene.score)")

            // Optionally add some visual effects for clearing
            addClearEffect(rows: Array(rowsToClear))
        }
    }

    private func addClearEffect(rows: [Int]) {
        // Example visual effect: show animation or sound for cleared lines
        for row in rows {
            let lineEffect = SKLabelNode(text: "Line Cleared!")
            lineEffect.fontSize = 24
            lineEffect.fontColor = .yellow
            lineEffect.position = CGPoint(x: scene?.size.width ?? 0 / 2, y: CGFloat(row) * scene!.tileSize)
            lineEffect.zPosition = 10
            scene?.addChild(lineEffect)

            // Animate the effect
            let fadeOut = SKAction.fadeOut(withDuration: 1.0)
            lineEffect.run(fadeOut) {
                lineEffect.removeFromParent() // Clean up after animation
            }
        }
    }
}

