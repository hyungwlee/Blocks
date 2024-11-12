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
    var isPowerupActive = false

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

    func spawnPowerupQuestion() {
        // Locate an available placeholder
        for i in 0..<4 {
            if let placeholder = childNode(withName: "powerupPlaceholder\(i)") as? SKShapeNode, placeholder.children.isEmpty {
                // Create the question power-up icon
                let questionPowerup = SKSpriteNode(imageNamed: "question.png")
                questionPowerup.size = CGSize(width: 40, height: 40) // Adjust size as needed
                questionPowerup.position = CGPoint.zero
                questionPowerup.name = "questionPowerup"

                // Add a subtle glow or pulse effect
                let pulseUp = SKAction.scale(to: 1.1, duration: 0.6)
                let pulseDown = SKAction.scale(to: 1.0, duration: 0.6)
                let pulseSequence = SKAction.sequence([pulseUp, pulseDown])
                let pulseEffect = SKAction.repeatForever(pulseSequence)
                questionPowerup.run(pulseEffect)

                // Add the power-up icon as a child of the placeholder
                placeholder.addChild(questionPowerup)
                break // Exit the loop after placing the power-up
            }
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
       /* BSingleBlock.self,
        BSquareBlock2x2.self,
        BSquareBlock3x3.self,
        BVerticalBlockNode1x2.self,
        BHorizontalBlockNode1x2.self,
        BLShapeNode5Block.self,
        BLShapeNode2x2.self, // Added the L-shaped block
        BVerticalBlockNode1x3.self,
        BHorizontalBlockNode1x3.self,
        BVerticalBlockNode1x4.self,
        BHorizontalBlockNode1x4.self,*/
        BRotatedLShapeNode2x2.self,
        BRotatedLBlock2x2.self,
        BLShapeNode5Block.self,
        BRotatedLShapeNode5Block.self,
        BRotatedLShape5Block.self
    ]

    override func didMove(to view: SKView) {
        backgroundColor = .black
        createGrid()
        addScoreLabel()
        createPowerupPlaceholders()
        spawnNewBlocks()

        // Play background music
        if let url = Bundle.main.url(forResource: "New", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: url) // Set the background music from the file URL
            if let backgroundMusic = backgroundMusic {
                backgroundMusic.autoplayLooped = true // Loop background music
                addChild(backgroundMusic) // Add the audio node to the scene
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
        boxNodes = newBlocks
        layoutSpawnedBlocks()

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
            var occupiedCells = 0
            var cellNodes: [SKShapeNode] = []
            var gridPositions: [GridCoordinate] = []

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

                // Collect cellNodes and their grid positions
                cellNodes.append(cellNode)
                gridPositions.append(GridCoordinate(row: gridRow, col: gridCol))
            }

            // Create a PlacedBlock instance
            let placedBlock = PlacedBlock(cellNodes: cellNodes, gridPositions: gridPositions)

            // Store a reference to the placedBlock in each cellNode's userData
            for cellNode in cellNodes {
                cellNode.userData = ["placedBlock": placedBlock]
            }

            // Add the placedBlock to the array
            placedBlocks.append(placedBlock)

            // Update the score based on occupied cells
            score += occupiedCells
            updateScoreLabel()

            // Remove the block node from the scene (but keep the cells in the scene)
            if let index = boxNodes.firstIndex(of: block) {
                boxNodes.remove(at: index)
            }
            block.removeFromParent()  // This only removes the block, not its visual parts

            // Re-layout the remaining spawned blocks
            layoutSpawnedBlocks()

            // Check if any lines are completed and clear them
            checkForCompletedLines()

            // Spawn new blocks or end the game if no moves are possible
            if boxNodes.isEmpty {
                spawnNewBlocks()
            } else if !checkForPossibleMoves(for: boxNodes) {
                showGameOverScreen()
            }

            run(SKAction.playSoundFileNamed("download.mp3", waitForCompletion: false))

        } else {
            block.position = block.initialPosition  // Reset the block if placement is invalid
            block.run(SKAction.scale(to: initialScale, duration: 0.1))  // Scale back to initial scale
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
                let fadeOutAction = SKAction.fadeOut(withDuration: 0.3)
                let scaleDownAction = SKAction.scale(to: 0.0, duration: 0.3)
                let removeAction = SKAction.run { cellNode.removeFromParent() }

                // Create a sequence of actions: fade out, scale down, then remove from parent
                let clearSequence = SKAction.sequence([fadeOutAction, scaleDownAction, removeAction])

                // Run the sequence and set the grid cell to nil after the animation
                cellNode.run(clearSequence)

                // Remove cellNode from its placedBlock
                if let placedBlock = cellNode.userData?["placedBlock"] as? PlacedBlock {
                    if let index = placedBlock.cellNodes.firstIndex(of: cellNode) {
                        placedBlock.cellNodes.remove(at: index)
                        placedBlock.gridPositions.remove(at: index)
                    }
                    // If the placedBlock has no more cells, remove it from placedBlocks
                    if placedBlock.cellNodes.isEmpty {
                        if let placedBlockIndex = placedBlocks.firstIndex(where: { $0 === placedBlock }) {
                            placedBlocks.remove(at: placedBlockIndex)
                        }
                    }
                }

                grid[row][col] = nil

                // Increment score with each cell removed
                score += 1
            }
        }

        updateScoreLabel()

        // After clearing the row, spawn one power-up
        spawnPowerupQuestion()

        // Play sound after clearing the row
        run(SKAction.playSoundFileNamed("Risingwav.mp3", waitForCompletion: false))
    }

    func clearColumn(_ col: Int) {
        for row in 0..<gridSize {
            if let cellNode = grid[row][col] {
                let fadeOutAction = SKAction.fadeOut(withDuration: 0.3)
                let scaleDownAction = SKAction.scale(to: 0.0, duration: 0.3)
                let removeAction = SKAction.run { cellNode.removeFromParent() }

                // Create a sequence of actions: fade out, scale down, then remove from parent
                let clearSequence = SKAction.sequence([fadeOutAction, scaleDownAction, removeAction])

                // Run the sequence and set the grid cell to nil after the animation
                cellNode.run(clearSequence)

                // Remove cellNode from its placedBlock
                if let placedBlock = cellNode.userData?["placedBlock"] as? PlacedBlock {
                    if let index = placedBlock.cellNodes.firstIndex(of: cellNode) {
                        placedBlock.cellNodes.remove(at: index)
                        placedBlock.gridPositions.remove(at: index)
                    }
                    // If the placedBlock has no more cells, remove it from placedBlocks
                    if placedBlock.cellNodes.isEmpty {
                        if let placedBlockIndex = placedBlocks.firstIndex(where: { $0 === placedBlock }) {
                            placedBlocks.remove(at: placedBlockIndex)
                        }
                    }
                }

                grid[row][col] = nil

                // Increment score with each cell removed
                score += 1
            }
        }

        updateScoreLabel()

        // After clearing the column, spawn one power-up
        spawnPowerupQuestion()

        // Play sound after clearing the column
        run(SKAction.playSoundFileNamed("Risingwav.mp3", waitForCompletion: false))
    }

    func showGameOverScreen() {
        isGameOver = true

        // Play Game Over Sound
        if let url = Bundle.main.url(forResource: "Muted", withExtension: "mp3") {
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

        grid = Array(repeating: Array(repeating: nil, count: gridSize), count: gridSize)
        removeAllChildren() // Remove all existing nodes from the scene

        isGameOver = false
        placedBlocks.removeAll() // Reset the placedBlocks array
        createGrid()
        addScoreLabel()
        spawnNewBlocks()
        createPowerupPlaceholders()

        // Remove existing background music if it exists
        backgroundMusic?.removeFromParent()
        backgroundMusic = nil

        // Restart background music
        if let url = Bundle.main.url(forResource: "New", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: url) // Create a new SKAudioNode with the correct file
            if let backgroundMusic = backgroundMusic {
                print("Background music found and will play.")
                backgroundMusic.autoplayLooped = true // Loop background music
                addChild(backgroundMusic) // Add the audio node to the scene
            }
        } else {
            print("Error: Background music file not found.")
        }
    }

    func updateScoreLabel() {
        if let scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode {
            scoreLabel.text = "Score: \(score)"
        }
    }

    // MARK: - Touch Handling

    // Detect when the user touches a block
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

        // Check if the power-up icon is tapped
        if nodeTapped.name == "questionPowerup" {
            isPowerupActive = true
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

        // If power-up is active, delete the selected block (entire PlacedBlock)
        if isPowerupActive {
            // Check if the tapped node is a cell node in the grid
            if let cellNode = nodeTapped as? SKShapeNode, let placedBlock = cellNode.userData?["placedBlock"] as? PlacedBlock {
                deletePlacedBlock(placedBlock)
                isPowerupActive = false
                performPowerupDeactivationEffect()
                return
            } else if let cellNode = nodeTapped.parent as? SKShapeNode, let placedBlock = cellNode.userData?["placedBlock"] as? PlacedBlock {
                deletePlacedBlock(placedBlock)
                isPowerupActive = false
                performPowerupDeactivationEffect()
                return
            }
            // If the tapped node is a block in the spawning area (BBoxNode)
            else if let blockNode = nodeTapped as? BBoxNode, boxNodes.contains(blockNode) {
                deleteBlock(blockNode)
                isPowerupActive = false  // Deactivate the power-up after use
                performPowerupDeactivationEffect()
                return
            } else if let blockNode = nodeTapped.parent as? BBoxNode, boxNodes.contains(blockNode) {
                deleteBlock(blockNode)
                isPowerupActive = false
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

    func deletePlacedBlock(_ placedBlock: PlacedBlock) {
        // Remove all the cell nodes from the scene and grid
        for cellNode in placedBlock.cellNodes {
            cellNode.removeFromParent()
        }
        for gridPos in placedBlock.gridPositions {
            grid[gridPos.row][gridPos.col] = nil
        }
        // Remove the placedBlock from the placedBlocks array
        if let index = placedBlocks.firstIndex(where: { $0 === placedBlock }) {
            placedBlocks.remove(at: index)
        }
        // Do not change the score when deleting with power-up
        // score += placedBlock.cellNodes.count // Commented out
        // updateScoreLabel() // Not needed
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

        // Do not change the score when deleting with power-up
        // score += occupiedCells.count // Commented out
        // updateScoreLabel() // Not needed
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
            } else {
                // If the placement is invalid, return the block to its original position
                node.position = node.initialPosition
                node.run(SKAction.scale(to: initialScale, duration: 0.1))  // Scale back to initial scale
            }
        }

        // Remove the offset data
        node.userData = nil

        currentlyDraggedNode = nil
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
