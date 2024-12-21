//
//  GameContext.swift
//  Test
//
//  Created by Hyung Lee on 10/20/24.
//

import Combine
import GameplayKit
import SwiftUI

protocol BLGameContextDelegate: AnyObject {
    var gameMode: BLGameModeType { get }
    var gameType: BLGameType { get }

    func exitGame()
    func transitionToScore(_ score: Int)
}

class BLGameContext {
    var shouldResetPlayback: Bool = false

    @Published var opacity: Double = 0.0
    @Published var isShowingSettings = false

    var subs = Set<AnyCancellable>()
    
    var scene: SKScene?

    private(set) var dependencies: BLDependencies
    
    var gameType: BLGameType? {
        delegate?.gameType
    }

    weak var delegate: BLGameContextDelegate?

    init(dependencies deps: BLDependencies) {
        dependencies = deps
    }
    
    func exit() {
    }
}

extension BLGameContext: ObservableObject {}
