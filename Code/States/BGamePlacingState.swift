//
//  BGamePlacingState.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import Foundation
import SpriteKit
import GameplayKit

class BGamePlacingState: GKState {
    weak var scene: BGameScene?
    weak var context: BGameContext?
    
    init(scene: BGameScene, context: BGameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        print("Entered Placing State")
    }
    
    // Since touch handling is managed in BGameScene, we might not need these methods here.
    // However, if you plan to handle touches in this state, you can implement them accordingly.
}
