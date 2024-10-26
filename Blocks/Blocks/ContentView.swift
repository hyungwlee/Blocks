//
//  ContentView.swift
//  Blocks
//
//  Created by Jevon Williams on 10/24/24.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    let screenSize: CGSize = UIScreen.main.bounds.size
    var layoutInfo: BLayoutInfo {
        BLayoutInfo(screenSize: screenSize)
    }
    
    let gameContext: GameContext
    
    init(dependencies: Dependencies, gameMode: GameModeType) {
        self.gameContext = BGameContext(dependencies: dependencies, gameMode: gameMode)
    }

    var body: some View {
        SpriteView(scene: BGameScene(context: gameContext as! BGameContext, size: screenSize))
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView(dependencies: Dependencies(), gameMode: .single)
        .ignoresSafeArea()
}
