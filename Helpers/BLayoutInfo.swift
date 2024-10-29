//
//  TTLayoutInfo.swift
//  Blocks
//
//  Created by Jevon Williams on 10/24/24.
//

import Foundation
import CoreGraphics // Ensure you import CoreGraphics for CGSize

struct BLayoutInfo {
    let screenSize: CGSize
    let boxSize: CGSize

    init(screenSize: CGSize, boxSize: CGSize = CGSize(width: 100, height: 100)) {
        self.screenSize = screenSize
        self.boxSize = boxSize
    }

    var boxesInWidth: Int {
        return Int(screenSize.width / boxSize.width)
    }

    var boxesInHeight: Int {
        return Int(screenSize.height / boxSize.height)
    }

    func positionForBox(atRow row: Int, column: Int) -> CGPoint {
        // Adjust x and y calculations to center the boxes correctly
        let x = CGFloat(column) * boxSize.width + (boxSize.width / 2)
        let y = CGFloat(row) * boxSize.height + (boxSize.height / 2)
        return CGPoint(x: x, y: y)
    }
}

