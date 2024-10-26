//
//  BlocksApp.swift
//  Blocks
//
//  Created by Jevon Williams on 10/24/24.
//

import SwiftUI

@main
struct BlocksApp: App {
    var body: some Scene {
        WindowGroup {
            // Provide actual dependencies and game mode
            ContentView(dependencies: Dependencies(), gameMode: .single) // Use the desired game mode
        }
    }
}

