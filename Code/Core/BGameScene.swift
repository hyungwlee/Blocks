//
//  TTGameScene.swift
//  Blocks
//
//  Created by Jevon Williams on 10/24/24.
//
import SpriteKit



class BGameScene: SKScene {
    let gridSize = 10
    let tileSize: CGFloat = 40
    var score = 0
    var grid: [[BBoxNode?]] = []
    var boxNodes: [BBoxNode] = []
    var currentlyDraggedNode: BBoxNode?
    var gameContext: BGameContext

    // Add new properties for dependencies and game mode
    var dependencies: Dependencies // Replace with actual type
    var gameMode: GameModeType // Using the enum defined above

    init(context: BGameContext, dependencies: Dependencies, gameMode: GameModeType, size: CGSize) {
        self.gameContext = context // Initialize your context here
        self.dependencies = dependencies // Initialize dependencies
        self.gameMode = gameMode // Initialize game mode
        self.grid = Array(repeating: Array(repeating: nil, count: gridSize), count: gridSize) // Initialize with nil
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        // Initialize dependencies and game mode with default values or handle as necessary
        let defaultDependencies = Dependencies() // Ensure you have a way to create a default instance
        self.dependencies = defaultDependencies // Set a default dependencies
        self.gameMode = .single // Default game mode; change if needed

        // Create a BGameContext using the dependencies and game mode
        self.gameContext = BGameContext(dependencies: dependencies, gameMode: gameMode)

        // Initialize the grid
        self.grid = Array(repeating: Array(repeating: nil, count: gridSize), count: gridSize) // Initialize with nil
        super.init(coder: aDecoder)
    }

    // MARK: - Node Management

    func addBlockNode(_ blockNode: SKShapeNode, to parentNode: SKNode) {
        // Check if blockNode already has a parent before adding
        if blockNode.parent == nil {
            parentNode.addChild(blockNode)
        } else {
            print("Block node already has a parent and will not be added again.")
        }
    }

    func safeAddBlock(_ block: BBoxNode) {
        // Remove the block from its parent if it already has one
        if block.parent != nil {
            block.removeFromParent()
        }
        addChild(block) // Now safely add it to the scene
    }

    // MARK: - Grid Management

    func isCellOccupied(row: Int, col: Int) -> Bool {
        guard row >= 0, row < gridSize, col >= 0, col < gridSize else {
            return true // Out of bounds are considered occupied
        }
        return grid[row][col] != nil // Check if the grid cell is occupied
    }

    func setCellOccupied(row: Int, col: Int, with block: BBoxNode) {
        guard row >= 0, row < gridSize, col >= 0, col < gridSize else {
            return // Ignore out of bounds
        }
        grid[row][col] = block // Mark the cell as occupied with an instance of a block
    }

    private var availableBlockTypes: [BBoxNode.Type] = [
        BSingleBlock.self,
        BHorizontalBlock1x4Node.self,
        BVerticalBlock.self,
        BSquareBlock.self,
        BBlockTNode.self,
        BHorizontalBlock1x3Node.self,
       BVDoubleBlock.self,
       BVerticalLBlock.self,
        BHDoubleBlock.self,
       BVerticalBlock1x4Node.self,
        BSquareBlockNode3x3.self,
        BRightFacingLBlockNode.self,
    ]

    override func didMove(to view: SKView) {
        backgroundColor = .black
        createGrid()
        addScoreLabel()
        spawnNewBlocks()
    }
    
    // Function handling block positioning - now uses addBlockNode for safety
    func positionBlock(_ block: SKShapeNode, at position: CGPoint) {
        block.position = position
        addBlockNode(block, to: self) // Updated to call addBlockNode with parent check
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

    func spawnNewBlocks() {
            guard canSpawnBlocks() else {
                print("Game Over!")
                return
            }

            // Remove old blocks from the scene
            boxNodes.forEach { $0.removeFromParent() }
            boxNodes.removeAll()

            let spacing: CGFloat = 10
            let newBlocks = generateRandomShapes(count: 3)

            // Calculate total width of blocks including spacing
            var totalBlocksWidth: CGFloat = 0
            for block in newBlocks {
                let blockWidth = CGFloat(block.gridWidth) * tileSize
                totalBlocksWidth += blockWidth
            }
            let totalSpacing = spacing * CGFloat(newBlocks.count - 1)
            let totalWidth = totalBlocksWidth + totalSpacing

            // Calculate starting X position to center blocks
            let startXPosition = (size.width - totalWidth) / 2.0
            let blockYPosition = size.height * 0.1 // Adjusted to move blocks higher and ensure proper placement

            var currentXPosition = startXPosition

            for newBlock in newBlocks {
                let blockWidth = CGFloat(newBlock.gridWidth) * tileSize

                newBlock.position = CGPoint(x: currentXPosition, y: blockYPosition)
                newBlock.initialPosition = newBlock.position
                newBlock.gameScene = self  // Set the reference to the game scene
                safeAddBlock(newBlock)
                boxNodes.append(newBlock)
                print("Added new block at position: \(newBlock.position)")

                currentXPosition += blockWidth + spacing
            }
        }


    func isPlacementValid(for block: BBoxNode, at row: Int, col: Int) -> Bool {
        for r in 0..<block.gridHeight {
            for c in 0..<block.gridWidth {
                let gridRow = row + r
                let gridCol = col + c

                // Check bounds
                if gridRow < 0 || gridRow >= gridSize || gridCol < 0 || gridCol >= gridSize {
                    return false
                }

                // Check if the cell is occupied
                if grid[gridRow][gridCol] != nil {
                    return false
                }
            }
        }
        return true
    }



    func checkForCompletedLines() {
        // Implement logic to check and clear completed rows or columns
    }


    func placeBlock(_ block: BBoxNode, at gridPosition: (row: Int, col: Int)) {
        let row = gridPosition.row
        let col = gridPosition.col

        // Check if the placement is valid
        if isPlacementValid(for: block, at: row, col: col) {
            // Snap the block to the grid
            let tileSize = self.tileSize
            let gridOrigin = CGPoint(
                x: (size.width - CGFloat(gridSize) * tileSize) / 2,
                y: (size.height - CGFloat(gridSize) * tileSize) / 2
            )
            let snappedPosition = CGPoint(
                x: gridOrigin.x + CGFloat(col) * tileSize,
                y: gridOrigin.y + CGFloat(row) * tileSize
            )
            block.position = snappedPosition

            // Update the grid
            for r in 0..<block.gridHeight {
                for c in 0..<block.gridWidth {
                    let gridRow = row + r
                    let gridCol = col + c
                    setCellOccupied(row: gridRow, col: gridCol, with: block)
                }
            }

            // Increase score based on the number of cells occupied by the block
            let occupiedCells = block.gridHeight * block.gridWidth
            score += occupiedCells
            updateScoreLabel()

            // Remove the block from draggable blocks
            if let index = boxNodes.firstIndex(of: block) {
                boxNodes.remove(at: index)
            }

            // Prevent the block from being moved again
            block.isUserInteractionEnabled = false

            // Optionally, check for completed lines and update the score
            checkForCompletedLines()

            // Spawn new blocks if necessary
            if boxNodes.isEmpty {
                spawnNewBlocks()
            }
        } else {
            // If invalid placement, move the block back to its initial position
            block.position = block.initialPosition
        }
    }

    func updateScoreLabel() {
        if let scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode {
            scoreLabel.text = "Score: \(score)"
        }
    }



    // Touch handling methods

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        currentlyDraggedNode = self.nodes(at: location).first(where: { node in
            guard let boxNode = node as? BBoxNode else { return false }
            return boxNodes.contains(boxNode)
        }) as? BBoxNode

        currentlyDraggedNode?.touchesBegan(touches, with: event)
    }



    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentlyDraggedNode?.touchesEnded(touches, with: event)
        currentlyDraggedNode = nil
    }

    
    // Placement logic


    func getOccupiedCells(for node: BBoxNode, at position: (row: Int, col: Int)) -> [(row: Int, col: Int)] {
        var occupiedCells: [(Int, Int)] = []

        for r in 0..<node.gridHeight {
            for c in 0..<node.gridWidth {
                occupiedCells.append((position.row + r, position.col + c))
            }
        }
        return occupiedCells
    }

    func placeBlock(_ block: BBoxNode, occupiedCells: [(row: Int, col: Int)]) {
        // Update the grid with the block's occupied cells
        for (row, col) in occupiedCells {
            setCellOccupied(row: row, col: col, with: block)
        }
        block.removeFromParent() // Remove block from the parent node before adding it to the grid
        addChild(block) // Add to the grid node
        spawnNewBlocks() // Trigger spawning of new blocks
    }

    func canSpawnBlocks() -> Bool {
        // Implement your logic to determine if new blocks can be spawned
        return true // Placeholder
    }
}










