//
//  TTBoxNode.swift
//  Blocks
//
//  Created by Jevon Williams on 10/24/24.
//

import SpriteKit

struct GridCoordinate: Hashable {
    var row: Int
    var col: Int
}

class BBoxNode: SKNode {
    var box: SKShapeNode
    var isBeingDragged: Bool = false
    var tileSize: CGFloat
    var initialPosition: CGPoint // Stores initial position for snapping back
    var layoutInfo: BLayoutInfo // Added layoutInfo as a property

    var gridHeight: Int {
        return Int(box.frame.size.height / tileSize)
    }
    
    var gridWidth: Int {
        return Int(box.frame.size.width / tileSize)
    }

    // Initializer with layoutInfo and tileSize
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat) {
        self.tileSize = tileSize
        self.layoutInfo = layoutInfo // Initialize layoutInfo
        self.initialPosition = layoutInfo.positionForBox(atRow: 0, column: 0) // Assuming starting position
        
        box = SKShapeNode(rect: .init(origin: .zero, size: layoutInfo.boxSize), cornerRadius: 8.0)
        box.fillColor = BBoxNode.randomColor() // Set a random color for the box
        super.init()
        
        addChild(box)
        position = initialPosition
        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        // Create a default layoutInfo if necessary
        let layoutInfo = BLayoutInfo(screenSize: CGSize(width: 640, height: 480))
        self.tileSize = 40.0
        self.layoutInfo = layoutInfo // Initialize layoutInfo
        self.initialPosition = layoutInfo.positionForBox(atRow: 0, column: 0) // Default initial position
        
        box = SKShapeNode(rect: .init(origin: .zero, size: layoutInfo.boxSize), cornerRadius: 8.0)
        box.fillColor = BBoxNode.randomColor()
        super.init(coder: aDecoder)
        
        addChild(box)
        isUserInteractionEnabled = true
    }

    // Touch handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)

        if box.contains(touchLocation) {
            isBeingDragged = true
            print("Dragging started")
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isBeingDragged, let touch = touches.first else { return }
        let touchLocation = touch.location(in: self.parent!)
        updatePosition(to: touchLocation)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isBeingDragged = false
        print("Dragging ended")

        if let snappedPosition = closestGridPosition() {
            self.position = snappedPosition
            
            if let scene = self.parent as? BGameScene {
                let occupiedCells = occupiedCellsForPlacement(row: Int(snappedPosition.y / tileSize), col: Int(snappedPosition.x / tileSize))
                if scene.isPlacementValid(for: self, at: Int(snappedPosition.y / tileSize), col: Int(snappedPosition.x / tileSize)) {
                    scene.placeBlock(self, occupiedCells: occupiedCells)
                } else {
                    self.position = initialPosition // Snap back to the initial position
                }
            }
            isUserInteractionEnabled = false
        } else {
            self.position = initialPosition
        }
    }

    // Update the position of the box based on touch location
    func updatePosition(to position: CGPoint) {
        self.position = CGPoint(x: position.x - box.frame.width / 2, y: position.y - box.frame.height / 2)
    }

    // Find the closest grid position for snapping
    func closestGridPosition() -> CGPoint? {
        guard let scene = self.parent as? BGameScene else { return nil }
        let gridOrigin = CGPoint(x: (scene.size.width - CGFloat(10) * tileSize) / 2,
                                 y: (scene.size.height - CGFloat(10) * tileSize) / 2)

        let gridX = round((position.x - gridOrigin.x) / tileSize) * tileSize
        let gridY = round((position.y - gridOrigin.y) / tileSize) * tileSize
        return CGPoint(x: gridOrigin.x + gridX, y: gridOrigin.y + gridY)
    }

    // Calculate occupied cells for placement
    func occupiedCellsForPlacement(row: Int, col: Int) -> [GridCoordinate] {
        var occupied: [GridCoordinate] = []
        for r in 0..<gridHeight {
            for c in 0..<gridWidth {
                occupied.append(GridCoordinate(row: row + r, col: col + c))
            }
        }
        return occupied
    }

    // Generate a random color
    private static func randomColor() -> UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}



