//
//  TTBoxNode.swift
//  Blocks
//
//  Created by Jevon Williams on 10/24/24.
//

import SpriteKit


class BBoxNode: SKNode {
    var box: SKShapeNode
    var isBeingDragged: Bool = false
    var tileSize: CGFloat
    var color: UIColor // Added color property

    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .red) {
        self.tileSize = tileSize
        self.color = color // Initialize color property
        box = SKShapeNode(rect: .init(origin: .zero, size: layoutInfo.boxSize), cornerRadius: 8.0)
        box.fillColor = color
        super.init()
        addChild(box)
        isUserInteractionEnabled = true // Enable user interactions
    }

    required init?(coder aDecoder: NSCoder) {
        let layoutInfo = BLayoutInfo(screenSize: CGSize(width: 640, height: 480))
        self.tileSize = 40.0
        self.color = .red // Initialize color property
        box = SKShapeNode(rect: .init(origin: .zero, size: layoutInfo.boxSize), cornerRadius: 8.0)
        box.fillColor = self.color
        super.init(coder: aDecoder)
        addChild(box)
        isUserInteractionEnabled = true // Enable user interactions
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let touchLocation = touch.location(in: self)

    // Check if the touch is within the box
    if box.contains(touchLocation) {
        isBeingDragged = true
        print("Dragging started")
    }
}

override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard isBeingDragged, let touch = touches.first else { return }
    let touchLocation = touch.location(in: self.parent!)

    // Update the position of the node based on the touch location
    updatePosition(to: touchLocation)
}

override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    isBeingDragged = false
    print("Dragging ended")
}

    func updatePosition(to position: CGPoint) {
    self.position = CGPoint(x: position.x - box.frame.width / 2, y: position.y - box.frame.height / 2)
}


    func occupiedCells() -> [(Int, Int)] {
        let boxWidthInCells = Int(box.frame.size.width / tileSize)
        let boxHeightInCells = Int(box.frame.size.height / tileSize)

        var occupied: [(Int, Int)] = []
        let topLeftRow = Int((position.y + box.frame.size.height / 2) / tileSize)
        let topLeftCol = Int((position.x - box.frame.size.width / 2) / tileSize)

        for row in 0..<boxHeightInCells {
            for col in 0..<boxWidthInCells {
                occupied.append((topLeftRow + row, topLeftCol + col))
            }
        }
        return occupied
    }
}

