//
//  BGameScene.swift
//  Blocks
//
//  Created by Jevon Williams on 10/24/24.
//

import SpriteKit

class BGameScene: SKScene {
    let gridSize = 10
    let tileSize: CGFloat = 40
    var score = 0
    var grid: [[SKShapeNode?]] = []
    var boxNodes: [BBoxNode] = []
    var currentlyDraggedNode: BBoxNode?
    var gameContext: BGameContext
    var isGameOver: Bool = false
    
    var dependencies: Dependencies
    var gameMode: GameModeType
    
    init(context: BGameContext, dependencies: Dependencies, gameMode: GameModeType, size: CGSize) {
        self.gameContext = context
        self.dependencies = dependencies
        self.gameMode = gameMode
        self.grid = Array(repeating: Array(repeating: nil, count: gridSize), count: gridSize)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        let defaultDependencies = Dependencies()
        self.dependencies = defaultDependencies
        self.gameMode = .single
        self.gameContext = BGameContext(dependencies: dependencies, gameMode: gameMode)
        self.grid = Array(repeating: Array(repeating: nil, count: gridSize), count: gridSize)
        super.init(coder: aDecoder)
    }
    
    // MARK: - Node Management
    func addBlockNode(_ blockNode: SKShapeNode, to parentNode: SKNode) {
        if blockNode.parent == nil {
            parentNode.addChild(blockNode)
        } else {
            print("Block node already has a parent.")
        }
    }
    
    func safeAddBlock(_ block: BBoxNode) {
        if block.parent != nil {
            block.removeFromParent()
        }
        addChild(block)
    }
    func createPowerupPlaceholders() {
        let placeholderSize = CGSize(width: 50, height: 50)
        let spacing: CGFloat = 20
        let totalWidth = placeholderSize.width * 4 + spacing * 3
        let startX = (size.width - totalWidth) / 2 + placeholderSize.width / 2
        let yPosition = size.height - 150 // Adjust as needed, below the score label

        for i in 0..<4 {
            let placeholder = SKShapeNode(rectOf: placeholderSize, cornerRadius: 8)
            placeholder.strokeColor = .white
            placeholder.lineWidth = 2.0
            placeholder.fillColor = .clear // Set fill color to clear or any color you prefer

            let xPosition = startX + CGFloat(i) * (placeholderSize.width + spacing)
            placeholder.position = CGPoint(x: xPosition, y: yPosition)
            placeholder.name = "powerupPlaceholder\(i)"
            addChild(placeholder)
        }
    }

    // MARK: - Grid Management
    func isCellOccupied(row: Int, col: Int) -> Bool {
        guard row >= 0, row < gridSize, col >= 0, col < gridSize else {
            return true
        }
        return grid[row][col] != nil
    }
    
    func setCellOccupied(row: Int, col: Int, with cellNode: SKShapeNode) {
        guard row >= 0, row < gridSize, col >= 0, col < gridSize else {
            return
        }
        grid[row][col] = cellNode
    }
    
    private var availableBlockTypes: [BBoxNode.Type] = [
        BSingleBlock.self,
        BSquareBlock2x2.self,
        BThreeByThreeBlockNode.self,
        BVerticalBlockNode1x2.self,
        BHorizontalBlockNode1x2.self,
        BLShapeNode5Block.self,
        BLShapeNode2x2.self, // Added the L-shaped block
        BVerticalBlockNode1x3.self,
        BHorizontalBlockNode1x3.self,
        BVerticalBlockNode1x4.self,
        BHorizontalBlockNode1x4.self,
    ]
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        createGrid()
        addScoreLabel()
        createPowerupPlaceholders() // Added this line for placeholders
        spawnNewBlocks()
    }

    
    func createGrid() {
        grid = Array(repeating: Array(repeating: nil, count: gridSize), count: gridSize)
        let gridOrigin = CGPoint(x: (size.width - CGFloat(gridSize) * tileSize) / 2,
                                 y: (size.height - CGFloat(gridSize) * tileSize) / 2)
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cellNode = SKShapeNode(rectOf: CGSize(width: tileSize, height: tileSize), cornerRadius: 4)
                cellNode.fillColor = .lightGray
                cellNode.strokeColor = .darkGray
                cellNode.lineWidth = 2.0
                
                cellNode.position = CGPoint(x: gridOrigin.x + CGFloat(col) * tileSize + tileSize / 2,
                                            y: gridOrigin.y + CGFloat(row) * tileSize + tileSize / 2)
                addChild(cellNode)
            }
        }
    }
    
    func addScoreLabel() {
        let scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = .white
        scoreLabel.fontName = "Helvetica-Bold"
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 100)
        scoreLabel.name = "scoreLabel"
        addChild(scoreLabel)
    }
    
    func checkForPossibleMoves(for blocks: [BBoxNode]) -> Bool {
        for block in blocks {
            for row in 0..<gridSize {
                for col in 0..<gridSize {
                    if isPlacementValid(for: block, at: row, col: col) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func spawnNewBlocks() {
        guard !isGameOver else {
            showGameOverScreen()
            return
        }
        
        boxNodes.forEach { $0.removeFromParent() }
        boxNodes.removeAll()
        
        let newBlocks = generateRandomShapes(count: 3)
        let spacing: CGFloat = 10
        var totalWidth: CGFloat = 0
        
        for block in newBlocks {
            let blockWidth = CGFloat(block.gridWidth) * tileSize
            totalWidth += blockWidth
        }
        let totalSpacing = spacing * CGFloat(newBlocks.count - 1)
        let startXPosition = (size.width - (totalWidth + totalSpacing)) / 2.0
        var currentXPosition = startXPosition
        let blockYPosition = size.height * 0.1
        
        for newBlock in newBlocks {
            let blockWidth = CGFloat(newBlock.gridWidth) * tileSize
            newBlock.position = CGPoint(x: currentXPosition, y: blockYPosition)
            newBlock.initialPosition = newBlock.position
            newBlock.gameScene = self
            safeAddBlock(newBlock)
            boxNodes.append(newBlock)
            currentXPosition += blockWidth + spacing
        }
        
        if !checkForPossibleMoves(for: newBlocks) {
            showGameOverScreen()
        }
    }
    
    func generateRandomShapes(count: Int) -> [BBoxNode] {
        var shapes: [BBoxNode] = []
        for _ in 0..<count {
            let blockType = availableBlockTypes.randomElement()!
            let newBlock = blockType.init(
                layoutInfo: BLayoutInfo(screenSize: size, boxSize: CGSize(width: tileSize, height: tileSize)),
                tileSize: tileSize
            )
            shapes.append(newBlock)
        }
        return shapes
    }
    
    func isPlacementValid(for block: BBoxNode, at row: Int, col: Int) -> Bool {
        for cell in block.shape {
            let gridRow = row + cell.row
            let gridCol = col + cell.col
            
            if gridRow < 0 || gridRow >= gridSize || gridCol < 0 || gridCol >= gridSize {
                return false
            }
            
            if grid[gridRow][gridCol] != nil {
                return false
            }
        }
        return true
    }
    
   func placeBlock(_ block: BBoxNode, at gridPosition: (row: Int, col: Int)) {
    let row = gridPosition.row
    let col = gridPosition.col
    
    if isPlacementValid(for: block, at: row, col: col) {
        var occupiedCells = 0
        for (index, cell) in block.shape.enumerated() {
            let gridRow = row + cell.row
            let gridCol = col + cell.col
            
            // Create a cell visual node (SKShapeNode)
            let cellNode = SKShapeNode(rectOf: CGSize(width: tileSize, height: tileSize))
            cellNode.fillColor = block.color  // Color for the block (optional)
            
            // Retrieve the asset for the specific cell
            let asset = block.assets[index].name  // Asset from the block's predefined assets
            
            // Add a texture (asset) to the cell node for more detailed visuals
            let assetTexture = SKTexture(imageNamed: asset)  // Load texture from the asset name
            let spriteNode = SKSpriteNode(texture: assetTexture)  // Create sprite node with texture
            spriteNode.size = CGSize(width: tileSize, height: tileSize)  // Set the size of the sprite
            
            // Add sprite as a child to the shape node
            cellNode.addChild(spriteNode)
            
            // Style the shape node (optional)
            cellNode.strokeColor = .darkGray
            cellNode.lineWidth = 2.0
            
            // Calculate the correct position on the grid
            let gridOrigin = CGPoint(
                x: (size.width - CGFloat(gridSize) * tileSize) / 2,
                y: (size.height - CGFloat(gridSize) * tileSize) / 2
            )
            let cellPosition = CGPoint(
                x: gridOrigin.x + CGFloat(gridCol) * tileSize + tileSize / 2,
                y: gridOrigin.y + CGFloat(gridRow) * tileSize + tileSize / 2
            )
            cellNode.position = cellPosition
            
            // Add the visual cell node directly to the scene
            addChild(cellNode)
            setCellOccupied(row: gridRow, col: gridCol, with: cellNode)
            occupiedCells += 1  // Count each occupied cell
        }
        
        // Update the score based on occupied cells
        score += occupiedCells
        updateScoreLabel()
        
        // Remove the block node from the scene (but keep the cells in the scene)
        if let index = boxNodes.firstIndex(of: block) {
            boxNodes.remove(at: index)
        }
        block.removeFromParent()  // This only removes the block, not its visual parts

        // Check if any lines are completed and clear them
        checkForCompletedLines()
        
        // Spawn new blocks or end the game if no moves are possible
        if boxNodes.isEmpty {
            spawnNewBlocks()
        } else if !checkForPossibleMoves(for: boxNodes) {
            showGameOverScreen()
        }
    } else {
        block.position = block.initialPosition  // Reset the block if placement is invalid
    }
}

    
    // MARK: - Line Clearing Logic
    func checkForCompletedLines() {
        for row in 0..<gridSize {
            if grid[row].allSatisfy({ $0 != nil }) {
                clearRow(row)
            }
        }
        
        for col in 0..<gridSize {
            var isCompleted = true
            for row in 0..<gridSize {
                if grid[row][col] == nil {
                    isCompleted = false
                    break
                }
            }
            if isCompleted {
                clearColumn(col)
            }
        }
    }
    
    func clearRow(_ row: Int) {
        for col in 0..<gridSize {
            if let cellNode = grid[row][col] {
                cellNode.removeFromParent()
                grid[row][col] = nil
                score += 1
            }
        }
        updateScoreLabel()
    }
    
    func clearColumn(_ col: Int) {
        for row in 0..<gridSize {
            if let cellNode = grid[row][col] {
                cellNode.removeFromParent()
                grid[row][col] = nil
                score += 1
            }
        }
        updateScoreLabel()
    }
    
    func showGameOverScreen() {
        isGameOver = true
        
        let overlay = SKShapeNode(rectOf: CGSize(width: size.width * 0.8, height: size.height * 0.3), cornerRadius: 10)
        overlay.fillColor = UIColor.black.withAlphaComponent(0.8)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(overlay)
        
        let gameOverLabel = SKLabelNode(text: "Game Over 😢")
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 40)
        gameOverLabel.zPosition = 1
        addChild(gameOverLabel)
        
        let finalScoreLabel = SKLabelNode(text: "Final Score: \(score)")
        finalScoreLabel.fontSize = 36
        finalScoreLabel.fontColor = .white
        finalScoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        finalScoreLabel.zPosition = 1
        addChild(finalScoreLabel)
        
        let restartLabel = SKLabelNode(text: "Tap to Restart")
        restartLabel.fontSize = 24
        restartLabel.fontColor = .yellow
        restartLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 40)
        restartLabel.name = "restartLabel"
        restartLabel.zPosition = 1
        addChild(restartLabel)
    }
    
    func restartGame() {
        score = 0
        updateScoreLabel()
        
        grid = Array(repeating: Array(repeating: nil, count: gridSize), count: gridSize)
        removeAllChildren()
        
        isGameOver = false
        createGrid()
        addScoreLabel()
        spawnNewBlocks()
    }
    
    func updateScoreLabel() {
        if let scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    // In touchesBegan, set the initial touch position
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let nodeTapped = atPoint(location)
        
        if isGameOver {
            if nodeTapped.name == "restartLabel" {
                restartGame()
            }
            return
        }
        
        // Find the BBoxNode from the touched node
        if let boxNode = nodeTapped as? BBoxNode, boxNodes.contains(boxNode) {
            currentlyDraggedNode = boxNode
        } else if let boxNode = nodeTapped.parent as? BBoxNode, boxNodes.contains(boxNode) {
            currentlyDraggedNode = boxNode
        } else if let boxNode = nodeTapped.parent?.parent as? BBoxNode, boxNodes.contains(boxNode) {
            currentlyDraggedNode = boxNode
        } else {
            currentlyDraggedNode = nil
        }
    }
    
    // In touchesMoved, update the position of currentlyDraggedNode
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let node = currentlyDraggedNode else { return }
        let touchLocation = touch.location(in: self)
        node.updatePosition(to: touchLocation)
    }
    
    // In touchesEnded, handle placement
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let node = currentlyDraggedNode else { return }
        let gridPos = node.gridPosition()
        node.gameScene?.placeBlock(node, at: gridPos)
        currentlyDraggedNode = nil
    }
}
