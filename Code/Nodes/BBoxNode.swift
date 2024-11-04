//
//  BBoxNode.swift
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
    var tileSize: CGFloat
    var color: UIColor
    var layoutInfo: BLayoutInfo
    weak var gameScene: BGameScene?
    var initialPosition: CGPoint = .zero

    // New property to define the shape of the block
    var shape: [(row: Int, col: Int)] = []

    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .red) {
        self.layoutInfo = layoutInfo
        self.tileSize = tileSize
        self.color = color
        super.init()
        isUserInteractionEnabled = false // Disable touch handling in BBoxNode
    }

    required init?(coder aDecoder: NSCoder) {
        // Implement if using storyboard or XIBs
        fatalError("init(coder:) has not been implemented")
    }

    // Method to set up the shape and create the visual representation
    func setupShape(_ shape: [(row: Int, col: Int)]) {
        self.shape = shape
        createVisualRepresentation()
    }

    func createVisualRepresentation() {
        // Remove any existing child nodes
        removeAllChildren()

        // For each cell in 'shape', create an SKShapeNode
        for cell in shape {
            let cellNode = SKShapeNode(rectOf: CGSize(width: tileSize, height: tileSize), cornerRadius: 4)
            cellNode.fillColor = color
            cellNode.strokeColor = .darkGray
            cellNode.lineWidth = 2.0

            // Position the cellNode based on its position in the shape
            let xPos = CGFloat(cell.col) * tileSize + tileSize / 2
            let yPos = CGFloat(cell.row) * tileSize + tileSize / 2
            cellNode.position = CGPoint(x: xPos, y: yPos)
            cellNode.isUserInteractionEnabled = false // Ensure child nodes don't receive touches

            addChild(cellNode)
        }
    }

    var gridHeight: Int {
        let rows = shape.map { $0.row }
        return (rows.max() ?? 0) + 1
    }

    var gridWidth: Int {
        let cols = shape.map { $0.col }
        return (cols.max() ?? 0) + 1
    }

    // Remove touch handling from BBoxNode
    // All touch events are handled in BGameScene

    func updatePosition(to position: CGPoint) {
        self.position = CGPoint(x: position.x - self.frame.width / 2, y: position.y - self.frame.height / 2)
    }

    func gridPosition() -> (row: Int, col: Int) {
        guard let gameScene = gameScene else { return (0, 0) }
        let tileSize = gameScene.tileSize
        let gridOrigin = CGPoint(x: (gameScene.size.width - CGFloat(gameScene.gridSize) * tileSize) / 2,
                                 y: (gameScene.size.height - CGFloat(gameScene.gridSize) * tileSize) / 2)
        let adjustedPosition = CGPoint(x: self.position.x - gridOrigin.x,
                                       y: self.position.y - gridOrigin.y)
        let col = Int((adjustedPosition.x + tileSize / 2) / tileSize)
        let row = Int((adjustedPosition.y + tileSize / 2) / tileSize)
        return (row, col)
    }

    func occupiedCells() -> [GridCoordinate] {
        var occupied: [GridCoordinate] = []
        let gridPosition = self.gridPosition()
        let baseRow = gridPosition.row
        let baseCol = gridPosition.col

        for cell in shape {
            let gridRow = baseRow + cell.row
            let gridCol = baseCol + cell.col
            occupied.append(GridCoordinate(row: gridRow, col: gridCol))
        }
        return occupied
    }
}
