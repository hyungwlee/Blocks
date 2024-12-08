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
    
    // Property to define the shape of the block
    var shape: [(row: Int, col: Int)] = []
    var assets: [(name: String, position: (row: Int, col: Int))] = [] // Assets associated with the block
    
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .clear) {
        self.layoutInfo = layoutInfo
        self.tileSize = tileSize
        self.color = color
        
        super.init()
        isUserInteractionEnabled = false // Disable touch handling in BBoxNode
        self.zPosition = 1  // Set zPosition for block nodes
    }
    
    required init?(coder aDecoder: NSCoder) {
        // Implement if using storyboard or XIBs
        fatalError("init(coder:) has not been implemented")
    }
    
    // Method to set up the shape and create the visual representation
    func setupShape(_ shape: [(row: Int, col: Int)], assets: [(name: String, position: (row: Int, col: Int))]) {
        self.shape = shape
        self.assets = assets
        createVisualRepresentation()
    }

    
    func createVisualRepresentation() {
            removeAllChildren()

            // First, add all sprite nodes
            for (index, cell) in shape.enumerated() {
                let assetInfo = assets[index]
                let assetName = assetInfo.name
                
                let xPos = CGFloat(cell.col) * tileSize + tileSize / 2
                let yPos = CGFloat(cell.row) * tileSize + tileSize / 2
                
                let spriteNode = SKSpriteNode(imageNamed: assetName)
                spriteNode.size = CGSize(width: tileSize, height: tileSize)
                spriteNode.zPosition = 1
                spriteNode.alpha = 1.0
                spriteNode.position = CGPoint(x: xPos, y: yPos)
                
                addChild(spriteNode)
            }

            // Now create the outline
            let cellSet = Set(shape.map { GridCoordinate(row: $0.row, col: $0.col) })
            let path = CGMutablePath()

            for cell in shape {
                let (cellX, cellY) = (CGFloat(cell.col)*tileSize, CGFloat(cell.row)*tileSize)
                
                // Each cell is a square: (cellX, cellY) is bottom-left corner
                // Top edge: from (cellX, cellY+tileSize) to (cellX+tileSize, cellY+tileSize)
                // Bottom edge: from (cellX, cellY) to (cellX+tileSize, cellY)
                // Left edge: from (cellX, cellY) to (cellX, cellY+tileSize)
                // Right edge: from (cellX+tileSize, cellY) to (cellX+tileSize, cellY+tileSize)

                let upNeighbor = GridCoordinate(row: cell.row+1, col: cell.col)
                if !cellSet.contains(upNeighbor) {
                    // Add top edge
                    path.move(to: CGPoint(x: cellX, y: cellY+tileSize))
                    path.addLine(to: CGPoint(x: cellX+tileSize, y: cellY+tileSize))
                }

                let downNeighbor = GridCoordinate(row: cell.row-1, col: cell.col)
                if !cellSet.contains(downNeighbor) {
                    // Add bottom edge
                    path.move(to: CGPoint(x: cellX, y: cellY))
                    path.addLine(to: CGPoint(x: cellX+tileSize, y: cellY))
                }

                let leftNeighbor = GridCoordinate(row: cell.row, col: cell.col-1)
                if !cellSet.contains(leftNeighbor) {
                    // Add left edge
                    path.move(to: CGPoint(x: cellX, y: cellY))
                    path.addLine(to: CGPoint(x: cellX, y: cellY+tileSize))
                }

                let rightNeighbor = GridCoordinate(row: cell.row, col: cell.col+1)
                if !cellSet.contains(rightNeighbor) {
                    // Add right edge
                    path.move(to: CGPoint(x: cellX+tileSize, y: cellY))
                    path.addLine(to: CGPoint(x: cellX+tileSize, y: cellY+tileSize))
                }
            }

            let outlineNode = SKShapeNode(path: path)
            outlineNode.strokeColor = .white
            outlineNode.lineWidth = 2.0
            outlineNode.fillColor = .clear
            outlineNode.zPosition = 2
            outlineNode.lineJoin = .round
            outlineNode.lineCap = .round

            addChild(outlineNode)
        }






    
    var gridHeight: Int {
        let rows = shape.map { $0.row }
        return (rows.max() ?? 0) + 1
    }
    
    var gridWidth: Int {
        let cols = shape.map { $0.col }
        return (cols.max() ?? 0) + 1
    }
    
    func updatePosition(to position: CGPoint) {
        // Update the position of the block itself
        self.position = CGPoint(x: position.x - self.frame.width / 2, y: position.y - self.frame.height / 2)
    }
    
    func gridPosition() -> (row: Int, col: Int) {
        guard let gameScene = gameScene else { return (0, 0) }
        let tileSize = gameScene.tileSize
        let gridOrigin = gameScene.getGridOrigin()
        let adjustedPosition = CGPoint(x: self.position.x - gridOrigin.x,
                                       y: self.position.y - gridOrigin.y)
        let col = Int((adjustedPosition.x + tileSize / 2) / tileSize)
        let row = Int((adjustedPosition.y + tileSize / 2) / tileSize)
        return (row, col)
    }

    
    func rotateBlock() {
        // Rotate the block's shape 90 degrees clockwise
        shape = shape.map { (row: $0.col, col: -$0.row) }
        // Update assets positions accordingly
        assets = assets.map { (name: $0.name, position: (row: $0.position.col, col: -$0.position.row)) }
        createVisualRepresentation()
    }
    func occupiedCellsWithAssets() -> [(gridCoordinate: GridCoordinate, assetName: String)] {
        var occupied: [(gridCoordinate: GridCoordinate, assetName: String)] = []
        let gridPosition = self.gridPosition()
        let baseRow = gridPosition.row
        let baseCol = gridPosition.col

        for (index, cell) in shape.enumerated() {
            let gridRow = baseRow + cell.row
            let gridCol = baseCol + cell.col
            let gridCoordinate = GridCoordinate(row: gridRow, col: gridCol)
            let assetName = assets[index].name
            occupied.append((gridCoordinate: gridCoordinate, assetName: assetName))
        }
        return occupied
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

