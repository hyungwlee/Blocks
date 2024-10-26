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
    var currentShapes: [BBoxNode: [(Int, Int)]] = [:]
    var context: BGameContext?

    private var availableBlockTypes: [BBoxNode.Type] = [
        BSingleBlock.self,
        BHorizontalBlock.self,
        BVerticalBlock.self,
        BSquareBlock.self,
        BHorizontalBlockLNode.self,
        BBlockTNode.self,
        BDoubleBlock.self,
        BVerticalLBlock.self
    ]

    init(context: BGameContext, size: CGSize) {
        self.context = context
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didMove(to view: SKView) {
        self.isUserInteractionEnabled = true
        backgroundColor = .lightGray
        createGrid()
        addScoreLabel()
        spawnNewBlocks()
    }

    func addScoreLabel() {
        let scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = .white
        scoreLabel.fontName = "Helvetica-Bold"
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 100)
        scoreLabel.name = "scoreLabel"

        let labelBackground = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.5), size: CGSize(width: 200, height: 60))
        labelBackground.position = scoreLabel.position
        labelBackground.zPosition = -1
        addChild(labelBackground)
        addChild(scoreLabel)
    }

  func spawnNewBlocks() {
    guard canSpawnBlocks() else {
        print("Cannot spawn blocks, game over!")
        return
    }

    let numberOfBlocksToSpawn = 3
    
    // Calculate the position just below the grid
    let blockYPosition = (CGFloat(gridSize) * tileSize) / 2 - tileSize - 10 // This ensures blocks are visible below the grid
    let spacing: CGFloat = 10
    let totalWidth = (tileSize * CGFloat(numberOfBlocksToSpawn)) + (spacing * CGFloat(numberOfBlocksToSpawn - 1))
    let startXPosition = (size.width - totalWidth) / 2

    for i in 0..<numberOfBlocksToSpawn {
        var randomIndex: Int
        repeat {
            randomIndex = Int.random(in: 0..<availableBlockTypes.count)
        } while boxNodes.contains { type(of: $0) == availableBlockTypes[randomIndex] }

        let blockType = availableBlockTypes[randomIndex]

        let randomBlock = blockType.init(layoutInfo: BLayoutInfo(screenSize: size, boxSize: CGSize(width: tileSize, height: tileSize)), tileSize: tileSize)

        randomBlock.position = CGPoint(
            x: startXPosition + (CGFloat(i) * (tileSize + spacing)),
            y: blockYPosition // Adjust this position if necessary
        )

        let shapes = generateRandomShapes(for: randomBlock)
        currentShapes[randomBlock] = shapes

        for shape in shapes {
            let (dx, dy) = shape
            let cellNode = SKSpriteNode(color: .red, size: CGSize(width: tileSize, height: tileSize))
            cellNode.position = CGPoint(
                x: CGFloat(dx) * tileSize,
                y: CGFloat(dy) * tileSize
            )
            randomBlock.addChild(cellNode)
        }

        addChild(randomBlock)
        boxNodes.append(randomBlock)
    }
}


    func createGrid() {
        grid = Array(repeating: Array(repeating: nil, count: gridSize), count: gridSize)

        // Calculate grid dimensions
        let gridWidth = CGFloat(gridSize) * tileSize
        let gridHeight = CGFloat(gridSize) * tileSize

        // Center grid on screen, considering safe areas
        let gridOrigin = CGPoint(x: (size.width - gridWidth) / 2, y: (size.height - gridHeight) / 2)

        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cellNode = SKSpriteNode(color: .lightGray, size: CGSize(width: tileSize, height: tileSize))
                cellNode.position = CGPoint(x: gridOrigin.x + CGFloat(col) * tileSize + tileSize / 2, y: gridOrigin.y + CGFloat(row) * tileSize + tileSize / 2)
                addChild(cellNode)
                grid[row][col] = nil // Keep grid entries as nil initially

                // Draw grid lines
                let lineNode = SKShapeNode(rectOf: CGSize(width: tileSize, height: tileSize))
                lineNode.position = cellNode.position
                lineNode.strokeColor = .black
                lineNode.lineWidth = 1
                addChild(lineNode)
            }
        }
    }

    func canSpawnBlocks() -> Bool {
        // Implement logic to check if blocks can be spawned
        return true // Placeholder
    }

    func generateRandomShapes(for block: BBoxNode) -> [(Int, Int)] {
        // Implement the logic to generate random shapes for the block
        return [] // Placeholder
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)

        currentlyDraggedNode = self.atPoint(touchLocation) as? BBoxNode

        if let placingState = context?.currentState as? BGamePlayingState {
            placingState.handleTouchBegan(touch)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let draggedNode = currentlyDraggedNode else { return }
        let touchLocation = touch.location(in: self)
        draggedNode.position = touchLocation
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let draggedNode = currentlyDraggedNode else { return }

        // Snap to the grid
        let gridX = round(draggedNode.position.x / tileSize)
        let gridY = round(draggedNode.position.y / tileSize)

        draggedNode.position = CGPoint(x: gridX * tileSize, y: gridY * tileSize)

        // Check if the block can be placed
        let (canPlace, occupiedCells) = canPlaceBlock(draggedNode)
        if canPlace {
            placeBlock(draggedNode, occupiedCells: occupiedCells)
            checkForClearedLines() // Check for cleared lines after placing the block
        } else {
            // Optionally snap back to original position or some logic if placement fails
            print("Cannot place block at the current position.")
        }

        // Notify the context of the touch ended
        if let placingState = context?.currentState as? BGamePlayingState {
            placingState.handleTouchEnded(touch, with: draggedNode)
        }

        currentlyDraggedNode = nil
    }

    // Check if the block can be placed
    func canPlaceBlock(_ block: BBoxNode) -> (Bool, [(Int, Int)]) {
        guard let shapes = currentShapes[block] else { return (false, []) }

        var occupiedCells: [(Int, Int)] = []

        for (dx, dy) in shapes {
            let gridX = Int((block.position.x + CGFloat(dx) * tileSize) / tileSize)
            let gridY = Int((block.position.y + CGFloat(dy) * tileSize) / tileSize)

            // Check boundaries
            if gridX < 0 || gridX >= gridSize || gridY < 0 || gridY >= gridSize {
                return (false, [])
            }

            if grid[gridY][gridX] != nil {
                return (false, [])
            }

            occupiedCells.append((gridX, gridY))
        }

        return (true, occupiedCells)
    }

    // Place the block on the grid
    func placeBlock(_ block: BBoxNode, occupiedCells: [(Int, Int)]) {
        // Set the block in the grid array
        for (gridX, gridY) in occupiedCells {
            grid[gridY][gridX] = block
        }

        // Set the block's position to its final snapped spot
        let cellOriginX = CGFloat(occupiedCells.first!.0) * tileSize + tileSize / 2
        let cellOriginY = CGFloat(occupiedCells.first!.1) * tileSize + tileSize / 2
        block.position = CGPoint(x: cellOriginX, y: cellOriginY)

        // Add the block to the scene if it's not already added
        if !children.contains(where: { $0 === block }) {
            addChild(block)
        }
    }

    // Check for cleared lines
    func checkForClearedLines() {
        for row in 0..<gridSize {
            if grid[row].allSatisfy({ $0 != nil }) {
                // Clear the row
                for col in 0..<gridSize {
                    grid[row][col]?.removeFromParent()
                    grid[row][col] = nil
                }
                score += 1 // Update score or perform any additional actions
            }
        }

        for col in 0..<gridSize {
            let columnBlocks = (0..<gridSize).compactMap { grid[$0][col] }
            if columnBlocks.count == gridSize {
                // Clear the column
                for row in 0..<gridSize {
                    grid[row][col]?.removeFromParent()
                    grid[row][col] = nil
                }
                score += 1 // Update score or perform any additional actions
            }
        }
    }
}





