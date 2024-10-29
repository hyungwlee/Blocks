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
        // Add code to start the game logic, initialize variables, etc.
    }
}
