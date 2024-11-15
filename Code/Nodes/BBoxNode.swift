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
    func setupShape(_ shape: [(row: Int, col: Int)], assets: [(name: String, position: (row: Int, col: Int))]) {
        self.shape = shape
        self.assets = assets
        createVisualRepresentation()
    }
    
    func createVisualRepresentation() {
        // Remove any existing child nodes
        removeAllChildren()
        
        // For each cell in 'shape', add the asset at the correct position
        for (index, cell) in shape.enumerated() {
            // Get the asset name and position
            let assetInfo = assets[index]
            let assetName = assetInfo.name
            
            // Create the asset sprite node
            let assetNode = SKSpriteNode(imageNamed: assetName)
            assetNode.size = CGSize(width: tileSize, height: tileSize) // Adjust as necessary
            assetNode.name = assetName  // Assign a unique name to the asset
            
            // Calculate the position based on the cell's coordinates
            let xPos = CGFloat(cell.col) * tileSize + tileSize / 2
            let yPos = CGFloat(cell.row) * tileSize + tileSize / 2
            assetNode.position = CGPoint(x: xPos, y: yPos)
            
            // Set zPosition to ensure the asset is visible
            assetNode.zPosition = 1
            
            // Add the asset node as a child to this BBoxNode
            addChild(assetNode)
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
    
    func updatePosition(to position: CGPoint) {
        // Update the position of the block itself
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
    
    func rotateBlock() {
        // Rotate the block's shape 90 degrees clockwise
        shape = shape.map { (row: $0.col, col: -$0.row) }
        // Update assets positions accordingly
        assets = assets.map { (name: $0.name, position: (row: $0.position.col, col: -$0.position.row)) }
        createVisualRepresentation()
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
