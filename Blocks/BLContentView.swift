//
//  ContentView.swift
//  Blocks
//
//  Created by Prabhdeep Brar on 10/18/24.
//

import SwiftUI
import SpriteKit

struct BLContentView: View {
    let screenSize: CGSize = UIScreen.main.bounds.size
    var layoutInfo: BLLayoutInfo {
        BLLayoutInfo(screenSize: screenSize)
    }
    
    let gameContext: BLGameContext

    init(dependencies: Dependencies, gameMode: GameModeType) {
        self.gameContext = BLGameContext(dependencies: dependencies, gameMode: gameMode)
    }

    var body: some View {
        SpriteView(scene: BLGameScene(context: gameContext, dependencies: gameContext.dependencies, gameMode: gameContext.gameMode, size: screenSize)) // Pass dependencies and gameMode
            .ignoresSafeArea()
    }
}

#Preview {
    BLContentView(dependencies: Dependencies(), gameMode: .single)
        .ignoresSafeArea()
}

