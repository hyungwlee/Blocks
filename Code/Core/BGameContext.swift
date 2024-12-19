//
//  TTGameContext.swift
//  Blocks
//
//  Created by Jevon Williams on 10/24/24.
//

import Combine
import GameplayKit
import UIKit

class BGameContext: GameContext {
    var nextState: GameState?
    
    var gameScene: BGameScene? {
        scene as? BGameScene
    }
    
    let gameMode: GameModeType
    let gameInfo: BGameInfo
    var layoutInfo: BLayoutInfo
    var placingState: Bool = false

    private(set) var stateMachine: GKStateMachine?
    var currentState: GKState? {
        stateMachine?.currentState
    }

    // MARK: - Initialization
    init(dependencies: Dependencies, gameMode: GameModeType) {
        self.gameInfo = BGameInfo()
        self.gameMode = gameMode
        let screenSize = UIScreen.main.bounds.size
        self.layoutInfo = BLayoutInfo(screenSize: screenSize)
        super.init(dependencies: dependencies)
        configureStates()
    }

    // MARK: - Configure State Machine
    private func configureStates() {
        guard let gameScene = gameScene else { return }
        print("Configuring states for game context")

        let states: [GKState] = [
            BGameIdleState(scene: gameScene, context: self),
            BGamePlayingState(scene: gameScene, context: self),
            BGamePlacingState(scene: gameScene, context: self)
        ]

        stateMachine = GKStateMachine(states: states)
        stateMachine?.enter(BGameIdleState.self)
    }

    // MARK: - Layout Configuration
 



    // MARK: - State Management Methods
    func startPlacing() {
        enterState(BGamePlacingState.self)
    }

    func startGame() {
        enterState(BGamePlayingState.self)
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
        placingState = (stateClass == BGamePlacingState.self)
        print("Entered state: \(stateClass)")
    }
}
