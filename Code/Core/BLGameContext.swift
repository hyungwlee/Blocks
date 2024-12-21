//
//  TTGameContext.swift
//  Blocks
//
//  Created by Jevon Williams on 10/24/24.
//

import Combine
import GameplayKit
import UIKit

class BLGameContext: GameContext {
    var nextState: BLGameState?
    
    var gameScene: BLGameScene? {
        scene as? BLGameScene
    }
    
    let gameMode: GameModeType
    let gameInfo: BLGameInfo
    var layoutInfo: BLLayoutInfo
    var placingState: Bool = false

    private(set) var stateMachine: GKStateMachine?
    var currentState: GKState? {
        stateMachine?.currentState
    }

    // MARK: - Initialization
    init(dependencies: Dependencies, gameMode: GameModeType) {
        self.gameInfo = BLGameInfo()
        self.gameMode = gameMode
        let screenSize = UIScreen.main.bounds.size
        self.layoutInfo = BLLayoutInfo(screenSize: screenSize)
        super.init(dependencies: dependencies)
        configureStates()
    }

    // MARK: - Configure State Machine
    private func configureStates() {
        guard let gameScene = gameScene else { return }
        print("Configuring states for game context")

        let states: [GKState] = [
            BLGameIdleState(scene: gameScene, context: self),
            BLGamePlayingState(scene: gameScene, context: self),
            BLGamePlacingState(scene: gameScene, context: self)
        ]

        stateMachine = GKStateMachine(states: states)
        stateMachine?.enter(BLGameIdleState.self)
    }

    // MARK: - Layout Configuration
 



    // MARK: - State Management Methods
    func startPlacing() {
        enterState(BLGamePlacingState.self)
    }

    func startGame() {
        enterState(BLGamePlayingState.self)
    }

    func enterState(_ stateClass: AnyClass) {
        guard let stateMachine = stateMachine else {
            print("State machine is not initialized")
            return
        }

        guard stateMachine.canEnterState(stateClass) else {
            print("Cannot enter state: \(stateClass)")
            return
        }

        stateMachine.enter(stateClass)
        placingState = (stateClass == BLGamePlacingState.self)
        print("Entered state: \(stateClass)")
    }
}
