//
//  BGameIdleState.swift
//  Blocks
//
//  Created by Jevon Williams on 10/24/24.
//

import SpriteKit
import GameplayKit

class BLGameIdleState: GKState {
    weak var scene: BLGameScene?
    weak var context: GameContext?

    init(scene: BLGameScene, context: GameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // Allow transitions to placing and clearing states
        return stateClass == BLGamePlacingState.self || stateClass == BLGameClearingState.self
    }

    override func didEnter(from previousState: GKState?) {
        print("Entered Idle State")
        // Optional: Reset or configure any scene elements if needed
    }

    func handleTouch(_ touch: UITouch) {
        updateBoxPosition(for: touch)
    }

    func handleTouchMoved(_ touch: UITouch) {
        updateBoxPosition(for: touch)
    }

    func handleTouchEnded(_ touch: UITouch) {
        print("Touch ended at location: \(touch.location(in: scene!))")
        // Transition to the Placing state when the touch ends
        stateMachine?.enter(BLGamePlacingState.self)
    }

    private func updateBoxPosition(for touch: UITouch) {
        guard let scene = scene else { return }

        let touchLocation = touch.location(in: scene)

        // Use the currentlyDraggedNode from the scene
        if let draggedBoxNode = scene.currentlyDraggedNode {
            draggedBoxNode.updatePosition(to: touchLocation)
            print("Box positioned at \(draggedBoxNode.position)")
        } else {
            print("No box node is being dragged.")
        }
    }
}
