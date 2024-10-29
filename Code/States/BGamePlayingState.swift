//
//  BGamePlayingState.swift
//  Blocks
//
//  Created by Jevon Williams on 10/26/24.
//

import Foundation
import SpriteKit
import GameplayKit

enum GameStateType {
    case idle
    case placing
    case playing
    case paused
}

class BGamePlayingState: GKState {
    weak var scene: BGameScene?
    weak var context: BGameContext?

    init(scene: BGameScene, context: BGameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is BGameIdleState.Type
    }

    override func didEnter(from previousState: GKState?) {
        print("Game started")
          // Example of creating and adding a node with the parent check
        let block = SKShapeNode(rectOf: CGSize(width: 50, height: 50))
        block.fillColor = .green
        scene?.addBlockNode(block, to: scene!) 
    }
}
