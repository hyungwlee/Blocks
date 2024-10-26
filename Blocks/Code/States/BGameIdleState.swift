//
//  TTGameIdleState.swift
//  Blocks
//
//  Created by Jevon Williams on 10/24/24.
//

import SpriteKit
import GameplayKit

class BGameIdleState: GKState {
    weak var scene: BGameScene?
    weak var context: BGameContext?
    

    init(scene: BGameScene, context: BGameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // Allow transitions to placing and clearing states
        return stateClass == BGamePlacingState.self || stateClass == BGameClearingState.self
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
        stateMachine?.enter(BGamePlacingState.self)
    }
    
   private func updateBoxPosition(for touch: UITouch) {
    guard let scene = scene, let context = context else { return }
    
    let touchLocation = touch.location(in: scene)
    let newBoxPos = CGPoint(x: touchLocation.x - context.layoutInfo.boxSize.width / 2.0,
                            y: touchLocation.y - context.layoutInfo.boxSize.height / 2.0)

    // Find the currently dragged box node
    if let draggedBoxNode = scene.boxNodes.first(where: { $0.isBeingDragged }) { // Adjust this line according to your dragging logic
        draggedBoxNode.position = newBoxPos
        print("Box positioned at \(newBoxPos)")
    } else {
        print("No box node is being dragged.")
    }
}

}

