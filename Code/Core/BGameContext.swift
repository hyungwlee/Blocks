//
//  TTGameContext.swift
//  Blocks
//
//  Created by Jevon Williams on 10/24/24.
//

import Combine
import GameplayKit

class BGameContext: GameContext {
    var nextState: GameState?
    var gameScene: BGameScene? {
        scene as? BGameScene
    }
    let gameMode: GameModeType
    let gameInfo: BGameInfo
    var layoutInfo: BLayoutInfo = .init(screenSize: .zero)
    var placingState: Bool = false 

    private(set) var stateMachine: GKStateMachine?
    var currentState: GKState? {
        stateMachine?.currentState
    }

    // MARK: - Initialization
    init(dependencies: Dependencies, gameMode: GameModeType) {
        self.gameInfo = BGameInfo()
        self.gameMode = gameMode
        super.init(dependencies: dependencies)
        configureStates()
    }

    // MARK: - Configure State Machine
    private func configureStates() {
        guard let gameScene else { return }
        print("Configuring states for game context")

        // Define the states available in this game context
        let states: [GKState] = [
            BGameIdleState(scene: gameScene, context: self),
            BGamePlayingState(scene: gameScene, context: self),
            BGamePlacingState(scene: gameScene, context: self) // Ensure placing state is included
        ]
        
        // Initialize the state machine with the array of states
        stateMachine = GKStateMachine(states: states)

        // Enter the initial state
        stateMachine?.enter(BGameIdleState.self)
    }

    // MARK: - State Management Methods
    func enterState(_ stateClass: AnyClass) {
        // Validates the transition before attempting it
        guard stateMachine?.canEnterState(stateClass) == true else {
            print("Cannot enter state: \(stateClass)")
            return
        }
        stateMachine?.enter(stateClass)
        // Update placing state based on the state
        placingState = (stateClass == BGamePlacingState.self)
    }

    // Example method to transition to the placing state
    func startPlacing() {
        enterState(BGamePlacingState.self)
    }

    // Example method to transition to the playing state
    func startGame() {
        enterState(BGamePlayingState.self)
    }
}


