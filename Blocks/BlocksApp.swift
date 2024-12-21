//
//  BlocksApp.swift
//  Blocks
//
//  Created by Prabhdeep Brar on 10/18/24.
//

import SwiftUI
import AVFoundation


@main
struct BlocksApp: App {
    var body: some Scene {
        WindowGroup {
            // Provide actual dependencies and game mode
            BLContentView(dependencies: Dependencies(), gameMode: .single) // Use the desired game mode
        }
    }
}
