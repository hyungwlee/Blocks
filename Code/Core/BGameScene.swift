//
//  BGameScene.swift
//  Blocks
//
//  Created by Jevon Williams on 10/24/24.
//

import SpriteKit
import AVFoundation

class BGameScene: SKScene {
    let gridSize = 8
    let tileSize: CGFloat = 40
    var score = 0
    var grid: [[SKShapeNode?]] = []
    var boxNodes: [BBoxNode] = []
    var currentlyDraggedNode: BBoxNode?
    var gameContext: BGameContext
    var isGameOver: Bool = false
    var placedBlocks: [PlacedBlock] = []

    // Power-up state variables
    var isDeletePowerupActive = false
    var isSwapPowerupActive = false
    var undoStack: [Move] = []  // Updated to store Move objects

    var highlightGrid: [[SKShapeNode?]] = []

    var dropSound: SKAudioNode?
    var backgroundMusic: SKAudioNode?
    var gameOverSound: SKAudioNode?
    var blockSelectionSound: SKAudioNode?
    var audioPlayer: AVAudioPlayer?

    var dependencies: Dependencies
    var gameMode: GameModeType

    let initialScale: CGFloat = 0.9  // Set the initial scale to 0.9

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
        let yPosition = size.height - 160 // Adjust as needed, below the score label

        for i in 0..<4 {
            let placeholder = SKShapeNode(rectOf: placeholderSize, cornerRadius: 8)
            placeholder.strokeColor = .white
            placeholder.lineWidth = 2.0
            placeholder.fillColor = .clear // Set fill color to clear or any color you prefer
            placeholder.name = "powerupPlaceholder\(i)"

            let xPosition = startX + CGFloat(i) * (placeholderSize.width + spacing)
            placeholder.position = CGPoint(x: xPosition, y: yPosition)
            addChild(placeholder)

            // Add the question icon initially
            let questionIcon = SKSpriteNode(imageNamed: "question.png")
            questionIcon.size = CGSize(width: 40, height: 40) // Adjust size as needed
            questionIcon.position = CGPoint.zero // Center within the placeholder
            questionIcon.name = "questionIcon\(i)"
            placeholder.addChild(questionIcon)
        }
    }

    func spawnPowerups() {
        // Spawn both delete and rotate power-ups
        spawnDeletePowerup()
        spawnSwapPowerup()
        spawnUndoPowerup()
        // spawnRotatePowerup()
    }

    func spawnDeletePowerup() {
        for i in 0..<4 {
            if let placeholder = childNode(withName: "powerupPlaceholder\(i)") as? SKShapeNode {
                // Check if the placeholder only contains the question icon
                if placeholder.children.count == 1, placeholder.children.first?.name?.contains("questionIcon") == true {
                    // Remove the question icon
                    placeholder.children.first?.removeFromParent()

                    // Create the delete power-up icon
                    let deletePowerup = SKSpriteNode(imageNamed: "delete.png")
                    deletePowerup.size = CGSize(width: 40, height: 40)
                    deletePowerup.position = CGPoint.zero
                    deletePowerup.name = "deletePowerup"

                    // Add a subtle glow or pulse effect
                    let pulseUp = SKAction.scale(to: 1.1, duration: 0.6)
                    let pulseDown = SKAction.scale(to: 1.0, duration: 0.6)
                    let pulseSequence = SKAction.sequence([pulseUp, pulseDown])
                    deletePowerup.run(SKAction.repeatForever(pulseSequence))

                    // Add the power-up icon as a child of the placeholder
                    placeholder.addChild(deletePowerup)
                    break
                }
            }
        }
    }

    func spawnSwapPowerup() {
        for i in 0..<4 {
            if let placeholder = childNode(withName: "powerupPlaceholder\(i)") as? SKShapeNode {
                // Check if the placeholder only contains the question icon
                if placeholder.children.count == 1, placeholder.children.first?.name?.contains("questionIcon") == true {
                    // Remove the question icon
                    placeholder.children.first?.removeFromParent()

                    // Create the swap power-up icon
                    let swapPowerup = SKSpriteNode(imageNamed: "swap.png")
                    swapPowerup.size = CGSize(width: 40, height: 40)
                    swapPowerup.position = CGPoint.zero
                    swapPowerup.name = "swapPowerup"

                    // Add a subtle glow or pulse effect
                    let pulseUp = SKAction.scale(to: 1.1, duration: 0.6)
                    let pulseDown = SKAction.scale(to: 1.0, duration: 0.6)
                    let pulseSequence = SKAction.sequence([pulseUp, pulseDown])
                    swapPowerup.run(SKAction.repeatForever(pulseSequence))

                    // Add the power-up icon as a child of the placeholder
                    placeholder.addChild(swapPowerup)
                    break
                }
            }
        }
    }

    func spawnUndoPowerup() {
        for i in 0..<4 {
            if let placeholder = childNode(withName: "powerupPlaceholder\(i)") as? SKShapeNode {
                // Check if the placeholder only contains the question icon
                if placeholder.children.count == 1, placeholder.children.first?.name?.contains("questionIcon") == true {
                    // Remove the question icon
                    placeholder.children.first?.removeFromParent()

                    // Create the undo power-up icon
                    let undoPowerup = SKSpriteNode(imageNamed: "undo.png")
                    undoPowerup.size = CGSize(width: 40, height: 40)
                    undoPowerup.position = CGPoint.zero
                    undoPowerup.name = "undoPowerup"

                    // Add a subtle glow or pulse effect
                    let pulseUp = SKAction.scale(to: 1.1, duration: 0.6)
                    let pulseDown = SKAction.scale(to: 1.0, duration: 0.6)
                    let pulseSequence = SKAction.sequence([pulseUp, pulseDown])
                    undoPowerup.run(SKAction.repeatForever(pulseSequence))

                    // Add the power-up icon as a child of the placeholder
                    placeholder.addChild(undoPowerup)
                    break
                }
            }
        }
    }

    func spawnRotatePowerup() {
        // Implement if you have a rotate power-up
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
        //BSingleBlock.self,
        //BSquareBlock2x2.self,
        //BSquareBlock3x3.self,
        //BVerticalBlockNode1x2.self,
        //BHorizontalBlockNode1x2.self,
        BLShapeNode2x2.self, // Added the L-shaped block
        //BVerticalBlockNode1x3.self,
        //BHorizontalBlockNode1x3.self,
        //BVerticalBlockNode1x4.self,
        //BHorizontalBlockNode1x4.self,
        BRotatedLShapeNode2x2.self,
        BLShapeNode5Block.self,
        BRotatedLShapeNode5Block.self,
        //BTShapedBlock.self,
        //BZShapedBlock.self
        
    ]

    func setupGridHighlights() {
        // Create a grid of highlight nodes with the same size as the main grid
        highlightGrid = Array(repeating: Array(repeating: nil, count: gridSize), count: gridSize)

        let gridOrigin = CGPoint(x: (size.width - CGFloat(gridSize) * tileSize) / 2,
                                 y: (size.height - CGFloat(gridSize) * tileSize) / 2)

        // Add highlight nodes for each grid cell
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let node = SKShapeNode(rectOf: CGSize(width: tileSize, height: tileSize))
                node.fillColor = .clear // Transparent by default
                node.strokeColor = .blue // Highlight border color
                node.alpha = 0.0 // Hidden initially
                node.position = CGPoint(x: gridOrigin.x + CGFloat(col) * tileSize + tileSize / 2,
                                        y: gridOrigin.y + CGFloat(row) * tileSize + tileSize / 2)
                highlightGrid[row][col] = node
                addChild(node)
            }
        }
    }

    func clearHighlights() {
        for row in highlightGrid {
            for node in row {
                node?.fillColor = .clear
                node?.alpha = 0.0
            }
        }
    }

    func highlightValidCells(for block: BBoxNode) {
        clearHighlights()

        let occupiedCells = block.occupiedCells()
        var isValidPlacement = true

        for cell in occupiedCells {
            // Check if cell is outside the grid or already occupied
            if cell.row < 0 || cell.row >= gridSize || cell.col < 0 || cell.col >= gridSize || grid[cell.row][cell.col] != nil {
                isValidPlacement = false
                break
            }
        }

        let highlightColor: UIColor = isValidPlacement ? .green : .red
        for cell in occupiedCells {
            if cell.row >= 0, cell.row < gridSize, cell.col >= 0, cell.col < gridSize {
                if let highlightNode = highlightGrid[cell.row][cell.col] {
                    highlightNode.fillColor = highlightColor
                    highlightNode.alpha = 0.5
                }
            }
        }
    }

override func didMove(to view: SKView) {
    // Set the background color to black
    backgroundColor = .black

    // Existing setup
    createGrid()
    addScoreLabel()
    createPowerupPlaceholders()
    spawnNewBlocks()
    setupGridHighlights()

    // Play background music
    if let url = Bundle.main.url(forResource: "New", withExtension: "mp3") {
        backgroundMusic = SKAudioNode(url: url)
        if let backgroundMusic = backgroundMusic {
            backgroundMusic.autoplayLooped = true
            addChild(backgroundMusic)
        }
    } else {
        print("Error: Background music file not found.")
    }
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

    // MARK: - Updated Score Label
    func addScoreLabel() {
        // Create a smaller and modern container node for the score
        let scoreContainer = SKShapeNode(rectOf: CGSize(width: 100, height: 50), cornerRadius: 25) // Slightly reduced size and corner radius
        scoreContainer.fillColor = .white
        scoreContainer.strokeColor = .clear
        scoreContainer.position = CGPoint(x: size.width / 2, y: size.height - 100) // Adjusted Y position slightly lower for balance
        scoreContainer.name = "scoreContainer"

        // Add a subtle shadow effect to the container for a modern look
        let shadowNode = SKShapeNode(rectOf: CGSize(width: 100, height: 50), cornerRadius: 25)
        shadowNode.fillColor = UIColor.black.withAlphaComponent(0.15)
        shadowNode.strokeColor = .clear
        shadowNode.position = CGPoint(x: scoreContainer.position.x + 2, y: scoreContainer.position.y - 2)
        shadowNode.zPosition = -1
        addChild(shadowNode)

        // Add the score label inside the container
        let scoreLabel = SKLabelNode(text: "\(score)")
        scoreLabel.fontSize = 24 // Reduced font size to match smaller container
        scoreLabel.fontColor = .black
        scoreLabel.fontName = "Helvetica-Bold"
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint.zero // Centered within the container
        scoreLabel.name = "scoreLabel"

        // Add the label to the container
        scoreContainer.addChild(scoreLabel)

        // Add the container to the scene
        addChild(scoreContainer)
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
        boxNodes = newBlocks
        layoutSpawnedBlocks() // Only call here after new blocks are added

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

    func layoutSpawnedBlocks() {
        let spacing: CGFloat = 10
        var totalWidth: CGFloat = 0

        // Adjust block width calculations to include initialScale
        for block in boxNodes {
            let blockWidth = CGFloat(block.gridWidth) * tileSize * initialScale
            totalWidth += blockWidth
        }
        let totalSpacing = spacing * CGFloat(boxNodes.count - 1)
        let startXPosition = (size.width - (totalWidth + totalSpacing)) / 2.0
        var currentXPosition = startXPosition
        let blockYPosition = size.height * 0.1

        for block in boxNodes {
            let blockWidth = CGFloat(block.gridWidth) * tileSize * initialScale
            block.position = CGPoint(x: currentXPosition, y: blockYPosition)
            block.initialPosition = block.position
            block.gameScene = self
            block.setScale(initialScale) // Set initial smaller scale
            safeAddBlock(block)
            currentXPosition += blockWidth + spacing
        }
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
            let previousScore = score  // Save the score before placing the block
            var addedCells: [(row: Int, col: Int, cellNode: SKShapeNode)] = []

            var occupiedCells = 0
            var cellNodes: [SKShapeNode] = []
            var gridPositions: [GridCoordinate] = []

            for (index, cell) in block.shape.enumerated() {
                let gridRow = row + cell.row
                let gridCol = col + cell.col

                let cellNode = SKShapeNode(rectOf: CGSize(width: tileSize, height: tileSize))
                cellNode.fillColor = block.color

                let asset = block.assets[index].name
                let assetTexture = SKTexture(imageNamed: asset)
                let spriteNode = SKSpriteNode(texture: assetTexture)
                spriteNode.size = CGSize(width: tileSize, height: tileSize)
                cellNode.addChild(spriteNode)
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
                occupiedCells += 1

                cellNodes.append(cellNode)
                gridPositions.append(GridCoordinate(row: gridRow, col: gridCol))

                // Collect added cells for undo
                addedCells.append((row: gridRow, col: gridCol, cellNode: cellNode))
            }

            let placedBlock = PlacedBlock(cellNodes: cellNodes, gridPositions: gridPositions)

            for cellNode in cellNodes {
                cellNode.userData = ["placedBlock": placedBlock]
            }

            placedBlocks.append(placedBlock)
            score += occupiedCells
            updateScoreLabel()

            if let index = boxNodes.firstIndex(of: block) {
                boxNodes.remove(at: index)
            }
            block.removeFromParent()

            // Check for completed lines and collect cleared lines
            let clearedLines = checkForCompletedLines()

            // Create a Move object and push it onto the undo stack
            let move = Move(placedBlock: placedBlock, blockNode: block, previousScore: previousScore, addedCells: addedCells, clearedLines: clearedLines)
            undoStack.append(move)

            if boxNodes.isEmpty {
                spawnNewBlocks()  // This will call layoutSpawnedBlocks
            } else if !checkForPossibleMoves(for: boxNodes) {
                showGameOverScreen()
            }

            run(SKAction.playSoundFileNamed("download.mp3", waitForCompletion: false))
        } else {
            block.position = block.initialPosition
            block.run(SKAction.scale(to: initialScale, duration: 0.1))
        }
    }

    // MARK: - Line Clearing Logic
    func checkForCompletedLines() -> [LineClear] {
        var lineClears: [LineClear] = []

        for row in 0..<gridSize {
            if grid[row].allSatisfy({ $0 != nil }) {
                let clearedCells = clearRow(row)
                let lineClear = LineClear(isRow: true, index: row, clearedCells: clearedCells)
                lineClears.append(lineClear)
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
                let clearedCells = clearColumn(col)
                let lineClear = LineClear(isRow: false, index: col, clearedCells: clearedCells)
                lineClears.append(lineClear)
            }
        }

        // If any line was cleared, spawn power-ups
        if !lineClears.isEmpty {
            spawnPowerups()
        }

        return lineClears
    }

    func clearRow(_ row: Int) -> [(row: Int, col: Int, cellNode: SKShapeNode)] {
        var clearedCells: [(row: Int, col: Int, cellNode: SKShapeNode)] = []
        for col in 0..<gridSize {
            if let cellNode = grid[row][col] {
                let fadeOutAction = SKAction.fadeOut(withDuration: 0.3)
                let scaleDownAction = SKAction.scale(to: 0.0, duration: 0.3)
                let removeAction = SKAction.run { cellNode.removeFromParent() }

                // Create a sequence of actions: fade out, scale down, then remove from parent
                let clearSequence = SKAction.sequence([fadeOutAction, scaleDownAction, removeAction])

                // Run the sequence
                cellNode.run(clearSequence)

                // Set the grid cell to nil after the animation
                grid[row][col] = nil

                // Collect cleared cell for undo
                clearedCells.append((row: row, col: col, cellNode: cellNode))
            }
        }

        updateScoreLabel()
        run(SKAction.playSoundFileNamed("Risingwav.mp3", waitForCompletion: false))

        return clearedCells
    }

    func clearColumn(_ col: Int) -> [(row: Int, col: Int, cellNode: SKShapeNode)] {
        var clearedCells: [(row: Int, col: Int, cellNode: SKShapeNode)] = []
        for row in 0..<gridSize {
            if let cellNode = grid[row][col] {
                let fadeOutAction = SKAction.fadeOut(withDuration: 0.3)
                let scaleDownAction = SKAction.scale(to: 0.0, duration: 0.3)
                let removeAction = SKAction.run { cellNode.removeFromParent() }

                // Create a sequence of actions: fade out, scale down, then remove from parent
                let clearSequence = SKAction.sequence([fadeOutAction, scaleDownAction, removeAction])

                // Run the sequence
                cellNode.run(clearSequence)

                // Set the grid cell to nil after the animation
                grid[row][col] = nil

                // Collect cleared cell for undo
                clearedCells.append((row: row, col: col, cellNode: cellNode))
            }
        }

        updateScoreLabel()
        run(SKAction.playSoundFileNamed("Risingwav.mp3", waitForCompletion: false))

        return clearedCells
    }

    func showGameOverScreen() {
        isGameOver = true

        // Play Game Over Sound
        if Bundle.main.url(forResource: "Muted", withExtension: "mp3") != nil {
            // Play sound using SKAction instead of SKAudioNode
            let playSoundAction = SKAction.playSoundFileNamed("Muted.mp3", waitForCompletion: false)
            self.run(playSoundAction)
        } else {
            print("Error: Game over sound file not found.")
        }

        // Stop and remove background music when the game ends
        backgroundMusic?.removeFromParent() // Completely remove the background music node
        backgroundMusic = nil // Set it to nil to make sure it gets reinitialized when restarting

        // Overlay to show game over screen
        let overlay = SKShapeNode(rectOf: CGSize(width: size.width * 0.8, height: size.height * 0.3), cornerRadius: 10)
        overlay.fillColor = UIColor.black.withAlphaComponent(0.8)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(overlay)

        // Game Over Label
        let gameOverLabel = SKLabelNode(text: "Game Over 😢")
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 40)
        gameOverLabel.zPosition = 1
        addChild(gameOverLabel)

        // Final Score Label
        let finalScoreLabel = SKLabelNode(text: "Final Score: \(score)")
        finalScoreLabel.fontSize = 36
        finalScoreLabel.fontColor = .white
        finalScoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        finalScoreLabel.zPosition = 1
        addChild(finalScoreLabel)

        // Restart Label
        let restartLabel = SKLabelNode(text: "Tap to Restart")
        restartLabel.fontSize = 24
        restartLabel.fontColor = .yellow
        restartLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 40)
        restartLabel.name = "restartLabel"
        restartLabel.zPosition = 1
        addChild(restartLabel)
    }

  func restartGame() {
    print("Restarting game...")
    score = 0
    updateScoreLabel()

    // Reset the grid and remove all children from the scene
    grid = Array(repeating: Array(repeating: nil, count: gridSize), count: gridSize)
    removeAllChildren()

    isGameOver = false
    placedBlocks.removeAll() // Clear the placed blocks
    undoStack.removeAll()    // Clear the undo stack

    // Set the background color to black
    backgroundColor = .black

    // Re-add other game elements
    createGrid()
    addScoreLabel()
    spawnNewBlocks()
    createPowerupPlaceholders()
    setupGridHighlights()

    // Remove existing background music if it exists
    backgroundMusic?.removeFromParent()
    backgroundMusic = nil

    // Restart background music
    if let url = Bundle.main.url(forResource: "New", withExtension: "mp3") {
        backgroundMusic = SKAudioNode(url: url)
        if let backgroundMusic = backgroundMusic {
            print("Background music found and will play.")
            backgroundMusic.autoplayLooped = true
            addChild(backgroundMusic)
        }
    } else {
        print("Error: Background music file not found.")
    }
}


    func placeholderIndex(for placeholder: SKShapeNode) -> Int? {
        for i in 0..<4 {
            if childNode(withName: "powerupPlaceholder\(i)") === placeholder {
                return i
            }
        }
        return nil
    }

    func resetPlaceholder(at index: Int) {
        if let placeholder = childNode(withName: "powerupPlaceholder\(index)") as? SKShapeNode {
            // Remove all children from the placeholder
            placeholder.removeAllChildren()

            // Add the question mark icon back
            let questionIcon = SKSpriteNode(imageNamed: "question.png")
            questionIcon.size = CGSize(width: 40, height: 40) // Adjust size as needed
            questionIcon.position = CGPoint.zero // Center within the placeholder
            questionIcon.name = "questionIcon\(index)"
            placeholder.addChild(questionIcon)
        }
    }

    func updateScoreLabel() {
        if let scoreContainer = childNode(withName: "scoreContainer") as? SKShapeNode,
           let scoreLabel = scoreContainer.childNode(withName: "scoreLabel") as? SKLabelNode {
            scoreLabel.text = "\(score)"
        }
    }


    // MARK: - Touch Handling

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

        // Check if the delete power-up icon is tapped
        if nodeTapped.name == "deletePowerup" {
            isDeletePowerupActive = true
            if let parentPlaceholder = nodeTapped.parent as? SKShapeNode {
                if let index = placeholderIndex(for: parentPlaceholder) {
                    resetPlaceholder(at: index)
                }
            }
            nodeTapped.removeFromParent()  // Remove the power-up icon after activation

            // Visual indication of activation: flash background
            let flashBackground = SKShapeNode(rectOf: size)
            flashBackground.fillColor = UIColor.white.withAlphaComponent(0.3)
            flashBackground.position = CGPoint(x: size.width / 2, y: size.height / 2)
            flashBackground.zPosition = -1
            addChild(flashBackground)

            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            flashBackground.run(SKAction.sequence([fadeOut, remove]))

            return
        }

        if nodeTapped.name == "swapPowerup" {
            isSwapPowerupActive = true
            if let parentPlaceholder = nodeTapped.parent as? SKShapeNode {
                if let index = placeholderIndex(for: parentPlaceholder) {
                    resetPlaceholder(at: index)
                }
            }
            nodeTapped.removeFromParent()  // Remove the power-up icon after activation

            // Visual indication of activation: flash background
            let flashBackground = SKShapeNode(rectOf: size)
            flashBackground.fillColor = UIColor.white.withAlphaComponent(0.3)
            flashBackground.position = CGPoint(x: size.width / 2, y: size.height / 2)
            flashBackground.zPosition = -1
            addChild(flashBackground)

            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            flashBackground.run(SKAction.sequence([fadeOut, remove]))

            return
        }

        if nodeTapped.name == "undoPowerup" {
            // Activate undo functionality
            undoLastMove()

            // Remove the undo power-up from the placeholder
            if let parentPlaceholder = nodeTapped.parent as? SKShapeNode {
                if let index = placeholderIndex(for: parentPlaceholder) {
                    resetPlaceholder(at: index)
                }
            }
            nodeTapped.removeFromParent() // Remove the undo power-up icon after activation

            // Optional: Visual indication of undo
            let flashBackground = SKShapeNode(rectOf: size)
            flashBackground.fillColor = UIColor.yellow.withAlphaComponent(0.3)
            flashBackground.position = CGPoint(x: size.width / 2, y: size.height / 2)
            flashBackground.zPosition = -1
            addChild(flashBackground)

            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            flashBackground.run(SKAction.sequence([fadeOut, remove]))

            return
        }

        // If delete power-up is active, delete the selected block (entire PlacedBlock)
        if isDeletePowerupActive {
            // Check if the tapped node is a cell node in the grid
            if let cellNode = nodeTapped as? SKShapeNode, let placedBlock = cellNode.userData?["placedBlock"] as? PlacedBlock {
                deletePlacedBlock(placedBlock, updateScore: false) // Pass false to prevent score increment
                isDeletePowerupActive = false
                performPowerupDeactivationEffect()
                return
            } else if let cellNode = nodeTapped.parent as? SKShapeNode, let placedBlock = cellNode.userData?["placedBlock"] as? PlacedBlock {
                deletePlacedBlock(placedBlock, updateScore: false)
                isDeletePowerupActive = false
                performPowerupDeactivationEffect()
                return
            }
        }

        if isSwapPowerupActive {
            // Check if the tapped node is a block in the spawning area (BBoxNode)
            if let blockNode = nodeTapped as? BBoxNode, boxNodes.contains(blockNode) {
                deleteBlock(blockNode)
                isSwapPowerupActive = false  // Deactivate the power-up after use
                performPowerupDeactivationEffect()
                return
            } else if let blockNode = nodeTapped.parent as? BBoxNode, boxNodes.contains(blockNode) {
                deleteBlock(blockNode)
                isSwapPowerupActive = false
                performPowerupDeactivationEffect()
                return
            }
        }

        // Existing code for handling block dragging or other actions
        if let boxNode = nodeTapped as? BBoxNode, boxNodes.contains(boxNode) {
            currentlyDraggedNode = boxNode
        } else if let boxNode = nodeTapped.parent as? BBoxNode, boxNodes.contains(boxNode) {
            currentlyDraggedNode = boxNode
        } else if let boxNode = nodeTapped.parent?.parent as? BBoxNode, boxNodes.contains(boxNode) {
            currentlyDraggedNode = boxNode
        } else {
            currentlyDraggedNode = nil
        }

        // Play block selection sound when a block is selected, only once
        if let node = currentlyDraggedNode {
            // Cancel rotate power-up if it was active
            // isRotatePowerupActive = false

            // Reset rotate power-up icon appearance
            if let rotatePowerupIcon = childNode(withName: "//rotatePowerup") as? SKSpriteNode {
                rotatePowerupIcon.colorBlendFactor = 0.0
            }

            if let url = Bundle.main.url(forResource: "Soft_Pop_or_Click", withExtension: "mp3") {
                do {
                    // Initialize the audio player with the sound file URL
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.prepareToPlay()
                    audioPlayer?.play() // Play the sound
                } catch {
                    print("Error: Unable to play sound - \(error)")
                }
            } else {
                print("Error: Audio file not found.")
            }

            // Increase the size of the block when it's selected for dragging
            node.run(SKAction.scale(to: 1.0, duration: 0.1))

            // Add an offset between the touch point and the block's position when dragging or just touched
            let touchLocation = touch.location(in: self)

            // Calculate offset to move the block away from the finger
            let offsetX = node.position.x - touchLocation.x + 50  // Adjust 50 as needed for distance
            let offsetY = node.position.y - touchLocation.y + 50  // Adjust 50 as needed for distance

            node.userData = ["offsetX": offsetX, "offsetY": offsetY]
        }
    }

    func performPowerupDeactivationEffect() {
        // Deactivation effect
        let deactivateFlash = SKShapeNode(rectOf: size)
        deactivateFlash.fillColor = UIColor.red.withAlphaComponent(0.3)
        deactivateFlash.position = CGPoint(x: size.width / 2, y: size.height / 2)
        deactivateFlash.zPosition = -1
        addChild(deactivateFlash)

        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        deactivateFlash.run(SKAction.sequence([fadeOut, remove]))
    }

    func performRotateEffect(on blockNode: BBoxNode) {
        let rotateAction = SKAction.rotate(byAngle: CGFloat.pi / 2, duration: 0.2)
        blockNode.run(rotateAction)
    }

    func isDeletePowerupAvailable() -> Bool {
        // Check if any delete power-up is still available in the placeholders
        for i in 0..<4 {
            if let placeholder = childNode(withName: "powerupPlaceholder\(i)") as? SKShapeNode {
                if placeholder.children.contains(where: { $0.name == "deletePowerup" }) {
                    return true
                }
            }
        }
        return false
    }

    func deletePlacedBlock(_ placedBlock: PlacedBlock, updateScore: Bool = true) {
        // Remove all the cell nodes from the scene and grid
        for cellNode in placedBlock.cellNodes {
            cellNode.removeFromParent()
            // Clear userData
            cellNode.userData = nil
        }
        for gridPos in placedBlock.gridPositions {
            grid[gridPos.row][gridPos.col] = nil
        }

        // Remove the placedBlock from the placedBlocks array
        if let index = placedBlocks.firstIndex(where: { $0 === placedBlock }) {
            placedBlocks.remove(at: index)
        }

        // Update score only if this deletion should impact the score (i.e., it's not from a delete power-up)
        if updateScore {
            score += placedBlock.cellNodes.count
            updateScoreLabel()
        }

        // Check for game-over condition after deletion if there are no available moves and no delete power-ups left
        if boxNodes.isEmpty || (!checkForPossibleMoves(for: boxNodes) && !isDeletePowerupAvailable()) {
            showGameOverScreen()
        }
    }

    func deleteBlock(_ blockNode: BBoxNode) {
        // Remove the block node from the scene
        blockNode.removeFromParent()

        // Remove from boxNodes array if present
        if let index = boxNodes.firstIndex(of: blockNode) {
            boxNodes.remove(at: index)
        }

        // Generate a new block to replace the deleted one
        let newBlock = generateRandomShapes(count: 1).first!
        newBlock.gameScene = self
        newBlock.setScale(initialScale)
        boxNodes.append(newBlock)
        safeAddBlock(newBlock)

        // Update the positions of the spawning blocks
        layoutSpawnedBlocks()

        // Check for game-over condition after deletion
        if boxNodes.isEmpty || (!checkForPossibleMoves(for: boxNodes) && !isDeletePowerupAvailable()) {
            showGameOverScreen()
        }
    }

    // Update the position of the dragged block as it follows the touch, with offset
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let node = currentlyDraggedNode else { return }

        let touchLocation = touch.location(in: self)

        // Scale up the block if not already scaled to 1.0
        if node.xScale < 1.0 {
            node.run(SKAction.scale(to: 1.0, duration: 0.1))
        }

        // Get the offset stored in the userData and apply it
        if let offsetX = node.userData?["offsetX"] as? CGFloat,
           let offsetY = node.userData?["offsetY"] as? CGFloat {

            let newPosition = CGPoint(x: touchLocation.x + offsetX, y: touchLocation.y + offsetY)

            // Update the position
            node.updatePosition(to: newPosition)
        }
        if let draggedNode = currentlyDraggedNode {
            highlightValidCells(for: draggedNode)
        }
    }

    func undoLastMove() {
        guard let move = undoStack.popLast() else { return }

        // Remove the added cells
        for (row, col, cellNode) in move.addedCells {
            grid[row][col] = nil
            cellNode.removeFromParent()
        }

        // Restore the cleared cells
        for lineClear in move.clearedLines {
            for (row, col, cellNode) in lineClear.clearedCells {
                grid[row][col] = cellNode

                // Add the cellNode back to the scene if needed
                if cellNode.parent == nil {
                    addChild(cellNode)
                }

                // Restore the cellNode's properties
                cellNode.alpha = 1.0
                cellNode.setScale(1.0)

                // Ensure the cellNode's placedBlock is in placedBlocks
                if let placedBlock = cellNode.userData?["placedBlock"] as? PlacedBlock {
                    if !placedBlocks.contains(where: { $0 === placedBlock }) {
                        placedBlocks.append(placedBlock)
                    }

                    // Ensure the cellNode is in placedBlock.cellNodes
                    if !placedBlock.cellNodes.contains(cellNode) {
                        placedBlock.cellNodes.append(cellNode)
                        placedBlock.gridPositions.append(GridCoordinate(row: row, col: col))
                    }
                }
            }
        }

        // Remove the placedBlock from placedBlocks
        if let index = placedBlocks.firstIndex(where: { $0 === move.placedBlock }) {
            placedBlocks.remove(at: index)
        }

        // Restore the blockNode to boxNodes and scene
        boxNodes.append(move.blockNode)
        addChild(move.blockNode)
        move.blockNode.position = move.blockNode.initialPosition
        move.blockNode.setScale(initialScale)

        // Re-layout the spawned blocks
        layoutSpawnedBlocks()

        // Restore the score
        score = move.previousScore
        updateScoreLabel()

        // Clear highlights
        clearHighlights()
    }


    // Handle the block placement and reset its size when placed on the grid
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let node = currentlyDraggedNode else { return }

        // Determine the grid position for placement
        let gridPos = node.gridPosition()

        // Attempt to place the block at the calculated grid position
        if let gameScene = node.gameScene {
            if gameScene.isPlacementValid(for: node, at: gridPos.row, col: gridPos.col) {
                gameScene.placeBlock(node, at: gridPos)
                // saveStateForUndo() is now handled inside placeBlock
            } else {
                // If the placement is invalid, return the block to its original position
                node.position = node.initialPosition
                node.run(SKAction.scale(to: initialScale, duration: 0.1))  // Scale back to initial scale
            }
        }

        // Remove the offset data
        node.userData = nil

        currentlyDraggedNode = nil
        clearHighlights()
    }

    // Check if the dragged block is colliding with any placed blocks
    func isCollisionWithPlacedBlocks(at position: CGPoint) -> Bool {
        for placedBlock in placedBlocks {
            for cellNode in placedBlock.cellNodes {
                if cellNode.frame.contains(position) {
                    return true
                }
            }
        }
        return false
    }
}

// Define the PlacedBlock class
class PlacedBlock {
    var cellNodes: [SKShapeNode]
    var gridPositions: [GridCoordinate]

    init(cellNodes: [SKShapeNode], gridPositions: [GridCoordinate]) {
        self.cellNodes = cellNodes
        self.gridPositions = gridPositions
    }
}

// Define the Move class for undo functionality
class Move {
    let placedBlock: PlacedBlock
    let blockNode: BBoxNode
    let previousScore: Int
    let addedCells: [(row: Int, col: Int, cellNode: SKShapeNode)]
    let clearedLines: [LineClear]

    init(placedBlock: PlacedBlock, blockNode: BBoxNode, previousScore: Int, addedCells: [(Int, Int, SKShapeNode)], clearedLines: [LineClear]) {
        self.placedBlock = placedBlock
        self.blockNode = blockNode
        self.previousScore = previousScore
        self.addedCells = addedCells
        self.clearedLines = clearedLines
    }
}

// Define the LineClear class to store cleared lines
class LineClear {
    let isRow: Bool
    let index: Int
    let clearedCells: [(row: Int, col: Int, cellNode: SKShapeNode)]

    init(isRow: Bool, index: Int, clearedCells: [(Int, Int, SKShapeNode)]) {
        self.isRow = isRow
        self.index = index
        self.clearedCells = clearedCells
    }
}
