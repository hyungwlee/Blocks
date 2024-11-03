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
        BLShapeNode2x2.self,
        BRotatedLShapeNode2x2.self,
        BVerticalBlockNode1x3.self,
        BHorizontalBlockNode1x3.self,
        BVerticalBlockNode1x4.self,
        BHorizontalBlockNode1x4.self,
    ]

    override func didMove(to view: SKView) {
        backgroundColor = .black
        createGrid()
        addScoreLabel()
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
        for r in 0..<block.gridHeight {
            for c in 0..<block.gridWidth {
                let gridRow = row + r
                let gridCol = col + c

                if gridRow < 0 || gridRow >= gridSize || gridCol < 0 || gridCol >= gridSize {
                    return false
                }

                if grid[gridRow][gridCol] != nil {
                    return false
                }
            }
        }
        return true
    }

    func placeBlock(_ block: BBoxNode, at gridPosition: (row: Int, col: Int)) {
    let row = gridPosition.row
    let col = gridPosition.col

    if isPlacementValid(for: block, at: row, col: col) {
        var occupiedCells = 0
        for r in 0..<block.gridHeight {
            for c in 0..<block.gridWidth {
                let gridRow = row + r
                let gridCol = col + c

                let cellNode = SKShapeNode(rectOf: CGSize(width: tileSize, height: tileSize))
                cellNode.fillColor = block.color
                cellNode.strokeColor = .darkGray
                cellNode.lineWidth = 2.0

                let gridOrigin = CGPoint(
                    x: (size.width - CGFloat(gridSize) * tileSize) / 2,
                    y: (size.height - CGFloat(gridSize) * tileSize) / 2
                )
                let cellPosition = CGPoint(
                    x: gridOrigin.x + CGFloat(gridCol) * tileSize + tileSize / 2,
                    y: gridOrigin.y + CGFloat(gridRow) * tileSize + tileSize / 2
                )
                cellNode.position = cellPosition

                addChild(cellNode)
                setCellOccupied(row: gridRow, col: gridCol, with: cellNode)
                occupiedCells += 1  // Count each cell occupied
            }
        }

        // Update the score based on occupied cells
        score += occupiedCells
        updateScoreLabel()

        if let index = boxNodes.firstIndex(of: block) {
            boxNodes.remove(at: index)
        }

        block.removeFromParent()

        checkForCompletedLines()

        if boxNodes.isEmpty {
            spawnNewBlocks()
        } else if !checkForPossibleMoves(for: boxNodes) {
            showGameOverScreen()
        }
    } else {
        block.position = block.initialPosition
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)
        let nodeTapped = self.nodes(at: location).first

        if isGameOver {
            if nodeTapped?.name == "restartLabel" {
                restartGame()
            }
            return
        }

        currentlyDraggedNode = self.nodes(at: location).first(where: { node in
            guard let boxNode = node as? BBoxNode else { return false }
            return boxNodes.contains(boxNode)
        }) as? BBoxNode

        currentlyDraggedNode?.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentlyDraggedNode?.touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentlyDraggedNode?.touchesEnded(touches, with: event)
        currentlyDraggedNode = nil
    }
}
