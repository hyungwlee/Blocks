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
    var tileSize: CGFloat {
        return (size.width - 40) / CGFloat(gridSize)
    }
    // Power-up state variables
    var activePowerup: PowerupType? = nil
    var activePowerupIcon: SKSpriteNode? = nil // New variable to track the active power-up icon

    var score = 0
    var grid: [[SKShapeNode?]] = []
    var boxNodes: [BBoxNode] = []
    var currentlyDraggedNode: BBoxNode?
    var gameContext: BGameContext
    var isGameOver: Bool = false
    var placedBlocks: [PlacedBlock] = []
    var gameOverAudioPlayer: AVAudioPlayer?
    var lastClearTime: TimeInterval = 0 // Tracks the time of the last line cleared
    var currentCombo: Int = 1 // Multiplier for consecutive clears within the time window
    let comboResetTime: TimeInterval = 5 // Time window in seconds for combo multiplier
    var gridOrigin: CGPoint = CGPoint(x: 50, y: 50) // Adjust this to match your grid's starting point
    var cellSize: CGFloat = 40.0
    
    var multiplier: Int = 1  // Default multiplier is 1 (no multiplier)
    
    // Power-up state variables
//    var activePowerup: PowerupType? = nil
    var tempSpawnedBlocks: [BBoxNode] = []
    var isUndoInProgress: Bool = false

    var undoStack: [Move] = []  // Updated to store Move objects
    
    var highlightGrid: [[SKNode?]] = []
    
    var dropSound: SKAudioNode?
    var backgroundMusic: SKAudioNode?
    var gameOverSound: SKAudioNode?
    var blockSelectionSound: SKAudioNode?
    var audioPlayer: AVAudioPlayer?
    
    var dependencies: Dependencies
    var gameMode: GameModeType
    
    let initialScale: CGFloat = 0.6  // Set the initial scale to 0.6
    
    // Power-up related variables
    enum PowerupType {
        case delete
        case swap
        case undo
        case multiplier
    }
    
    struct Powerup {
        let type: PowerupType
        let imageName: String
    }
    
    let availablePowerups: [Powerup] = [
        Powerup(type: .delete, imageName: "delete.png"),
        Powerup(type: .swap, imageName: "swap.png"),
        Powerup(type: .undo, imageName: "undo.png"),
        Powerup(type: .multiplier, imageName: "multiplier.webp")
    ]
    
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
        let spacing: CGFloat = 40
        let totalWidth = placeholderSize.width * 4 + spacing * 3
        let startX = (size.width - totalWidth) / 2 + placeholderSize.width / 2
        
        // Position the placeholders below the spawned blocks
        let yPosition = size.height * 0.13  // Adjusted to place beneath the blocks
        
        for i in 0..<4 {
            let placeholder = SKShapeNode(rectOf: placeholderSize, cornerRadius: 8)
            placeholder.strokeColor = .white
            placeholder.lineWidth = 2.0
            placeholder.fillColor = .clear
            placeholder.name = "powerupPlaceholder\(i)"
            placeholder.userData = ["powerup": NSNull()]
            
            let xPosition = startX + CGFloat(i) * (placeholderSize.width + spacing)
            placeholder.position = CGPoint(x: xPosition, y: yPosition)
            addChild(placeholder)
            
            // Add the question icon initially
            let questionIcon = SKSpriteNode(imageNamed: "question.png")
            questionIcon.size = CGSize(width: 40, height: 40)
            questionIcon.position = CGPoint.zero // Center within the placeholder
            questionIcon.name = "questionIcon\(i)"
            placeholder.addChild(questionIcon)
        }
    }
    // MARK: - Variables for Progress Bar
         let requiredLinesForPowerup = 1 // Number of lines required to fill the bar
         var linesCleared = 0 // Tracks the total lines cleared for the progress bar
        var progressBar: SKSpriteNode? // Updated to SKSpriteNode
        var progressBarBackground: SKShapeNode? // Keep this as SKShapeNode for the background

        func createProgressBar() {
            // Define progress bar dimensions
            let barWidth: CGFloat = size.width * 0.8
            let barHeight: CGFloat = 10
            let placeholderYPosition = size.height * 0.1
            let barY = placeholderYPosition - 50

            // Create the background for the progress bar
            progressBarBackground = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: barHeight / 2)
            progressBarBackground?.fillColor = .darkGray
            progressBarBackground?.strokeColor = .clear
            progressBarBackground?.position = CGPoint(x: size.width / 2, y: barY)
            addChild(progressBarBackground!)

            // Create the progress bar using SKSpriteNode
            let texture = SKTexture(image: UIImage(color: UIColor.green, size: CGSize(width: 1, height: 1)))
    // 1x1 green texture
            progressBar = SKSpriteNode(texture: texture, size: CGSize(width: barWidth, height: barHeight))
            progressBar?.anchorPoint = CGPoint(x: 0, y: 0.5)  // Anchor to the left edge
            progressBar?.position = CGPoint(x: progressBarBackground!.frame.minX, y: barY) // Align with the left edge of the background
            progressBar?.xScale = 0.0  // Start with zero width
            addChild(progressBar!)
        }



        func updateProgressBar() {
            guard let progressBar = progressBar else {
                print("Progress bar node is missing!")
                return
            }
            
            let maxScale: CGFloat = 1.0  // Maximum xScale
            let progress = CGFloat(linesCleared) / CGFloat(requiredLinesForPowerup)
            let newScale = min(progress, maxScale)
            
            let scaleAction = SKAction.scaleX(to: newScale, duration: 0.2)
            progressBar.run(scaleAction)
            
            if newScale >= maxScale {
                print("Power-up triggered!")
                // Reset the progress bar
                progressBar.run(SKAction.scaleX(to: 0.0, duration: 0.2))
                // Reset the linesCleared counter
                self.linesCleared = 0
                // Spawn power-up
                spawnRandomPowerup()
            }
        }


    
    
    // MARK: - Power-up Management
    
    func spawnRandomPowerup() {
        // Find an available placeholder
        for i in 0..<4 {
            if let placeholder = childNode(withName: "powerupPlaceholder\(i)") as? SKShapeNode,
               placeholder.userData?["powerup"] is NSNull {
                // Start the shuffling effect
                startPowerupShuffle(in: placeholder)
                break
            }
        }
    }
    
    func startPowerupShuffle(in placeholder: SKShapeNode) {
        // Remove existing icons (e.g., question mark)
        placeholder.removeAllChildren()
        
        // Create an SKSpriteNode to display the power-up icon
        let powerupIcon = SKSpriteNode()
        powerupIcon.size = CGSize(width: 40, height: 40)
        powerupIcon.position = CGPoint.zero
        powerupIcon.name = "powerupIcon"
        placeholder.addChild(powerupIcon)
        
        // Create an array of textures for the power-up images
        let textures = availablePowerups.map { SKTexture(imageNamed: $0.imageName) }
        
        // Create a shuffling action
        let shuffleAction = SKAction.animate(with: textures, timePerFrame: 0.1)
        let repeatShuffle = SKAction.repeat(shuffleAction, count: 5)
        
        // Randomly select a power-up
        let selectedPowerup = availablePowerups.randomElement()!
        
        // After shuffling, set the final texture to the selected power-up
        let setFinalTexture = SKAction.run {
            powerupIcon.texture = SKTexture(imageNamed: selectedPowerup.imageName)
            powerupIcon.userData = ["powerupType": selectedPowerup.type]
            placeholder.userData?["powerup"] = selectedPowerup.type
            
            // Add a subtle glow or pulse effect
            let pulseUp = SKAction.scale(to: 1.1, duration: 0.6)
            let pulseDown = SKAction.scale(to: 1.0, duration: 0.6)
            let pulseSequence = SKAction.sequence([pulseUp, pulseDown])
            powerupIcon.run(SKAction.repeatForever(pulseSequence))
        }
        
        // Run the shuffling and then the set final texture action
        let sequence = SKAction.sequence([repeatShuffle, setFinalTexture])
        powerupIcon.run(sequence)
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
            // Reset the placeholder's userData
            placeholder.userData?["powerup"] = NSNull()
            
            // Add the question mark icon back
            let questionIcon = SKSpriteNode(imageNamed: "question.png")
            questionIcon.size = CGSize(width: 40, height: 40) // Adjust size as needed
            questionIcon.position = CGPoint.zero // Center within the placeholder
            questionIcon.name = "questionIcon\(index)"
            placeholder.addChild(questionIcon)
        }
    }
    
    func highlightPowerupIcon(_ icon: SKSpriteNode) {
        // Add a visual effect to indicate activation, e.g., a glowing border
        let glow = SKAction.run {
            icon.color = .yellow
            icon.colorBlendFactor = 0.5
        }
        icon.run(glow)
    }
    
    func removeHighlightFromPowerupIcon(_ icon: SKSpriteNode) {
        let removeGlow = SKAction.run {
            icon.colorBlendFactor = 0.0
        }
        icon.run(removeGlow)
    }
    
//    func deactivateActivePowerup() {
//        // Find the power-up icon in the placeholder and remove it
//        for i in 0..<4 {
//            if let placeholder = childNode(withName: "powerupPlaceholder\(i)") as? SKShapeNode,
//               let powerupIcon = placeholder.childNode(withName: "powerupIcon") as? SKSpriteNode,
//               let powerupType = powerupIcon.userData?["powerupType"] as? PowerupType,
//               powerupType == activePowerup {
//
//                // Remove the power-up icon
//                powerupIcon.removeFromParent()
//                // Reset the placeholder
//                resetPlaceholder(at: i)
//                break
//            }
//        }
//        // Clear the active power-up
//        activePowerup = nil
//    }
    
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
        BSquareBlock3x3.self,
        BVerticalBlockNode1x2.self,
        BHorizontalBlockNode1x2.self,
        BLShapeNode2x2.self, // Added the L-shaped block
        BVerticalBlockNode1x3.self,
        BHorizontalBlockNode1x3.self,
        BVerticalBlockNode1x4.self,
        BHorizontalBlockNode1x4.self,
        BRotatedLShapeNode2x2.self,
        BLShapeNode5Block.self,
        BRotatedLShapeNode5Block.self,
        BTShapedBlock.self,
        BZShapedBlock.self
    ]
    
    func addHorizontalLines() {
        let scaledTileSize = tileSize * 0.7
        let verticalBlockHeight = 4 * scaledTileSize  // Adjusted height for scaled blocks
        let placeholderHeight: CGFloat = 50
        let spacing: CGFloat = 10  // Reduced spacing for a tighter layout

        // Calculate positions for the lines
        let centerX = size.width / 2
        let topLineY = size.height * 0.350  // Adjusted Y position for the top line
        let bottomLineY = topLineY - verticalBlockHeight - spacing  // Spaced below the top line

        // Line thickness
        let lineThickness: CGFloat = 1.5

        // Create the top line
        let topLine = SKShapeNode(rectOf: CGSize(width: size.width, height: lineThickness))
        topLine.position = CGPoint(x: centerX, y: topLineY)
        topLine.fillColor = .white
        topLine.strokeColor = .clear
        topLine.zPosition = 1
        addChild(topLine)

        // Create the bottom line
        let bottomLine = SKShapeNode(rectOf: CGSize(width: size.width, height: lineThickness))
        bottomLine.position = CGPoint(x: centerX, y: bottomLineY)
        bottomLine.fillColor = .white
        bottomLine.strokeColor = .clear
        bottomLine.zPosition = 1
        addChild(bottomLine)
    }








    func setupGridHighlights() {
        highlightGrid = Array(repeating: Array(repeating: nil, count: gridSize), count: gridSize)
        
        let gridOrigin = getGridOrigin()
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let node = SKNode()
                node.position = CGPoint(x: gridOrigin.x + CGFloat(col) * tileSize + tileSize / 2,
                                        y: gridOrigin.y + CGFloat(row) * tileSize + tileSize / 2)
                node.zPosition = 0  // Set zPosition for highlight nodes
                highlightGrid[row][col] = node
                addChild(node)
            }
        }
    }
    
    func clearHighlights() {
        for row in highlightGrid {
            for node in row {
                node?.removeAllChildren()
            }
        }
    }
    
    func highlightValidCells(for block: BBoxNode) {
        clearHighlights() // Clear previous highlights
        
        let occupiedCellsWithAssets = block.occupiedCellsWithAssets()
        var isValidPlacement = true
        
        // Check if all cells are valid
        for occupiedCell in occupiedCellsWithAssets {
            let cell = occupiedCell.gridCoordinate
            if cell.row < 0 || cell.row >= gridSize || cell.col < 0 || cell.col >= gridSize || grid[cell.row][cell.col] != nil {
                isValidPlacement = false
                break
            }
        }
        
        if !isValidPlacement {
            return // If any cell is invalid, don't show any highlights
        }
        
        // Highlight cells only if placement is valid
        for occupiedCell in occupiedCellsWithAssets {
            let cell = occupiedCell.gridCoordinate
            let assetName = occupiedCell.assetName
            
            if cell.row >= 0, cell.row < gridSize, cell.col >= 0, cell.col < gridSize, grid[cell.row][cell.col] == nil {
                if let highlightNode = highlightGrid[cell.row][cell.col] {
                    // Create the shadow node (ensure it sticks below the block)
                    let shadowNode = SKSpriteNode(imageNamed: assetName)
                    shadowNode.size = CGSize(width: tileSize, height: tileSize)
                    shadowNode.alpha = 0.3  // Subtle shadow transparency
                    shadowNode.zPosition = -1  // Always beneath the block
                    
                    // Create the block sprite node
                    let spriteNode = SKSpriteNode(imageNamed: assetName)
                    spriteNode.size = CGSize(width: tileSize, height: tileSize)
                    spriteNode.alpha = 0.8  // Adjust alpha if needed
                    spriteNode.zPosition = 1  // Above the shadow
                    
                    // Add shadow and block to the highlight node
                    highlightNode.addChild(shadowNode)
                    highlightNode.addChild(spriteNode)
                }
            }
        }
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Existing setup
        createGrid()
        addScoreLabel()
        createPowerupPlaceholders()
        createProgressBar()
        spawnNewBlocks()
        setupGridHighlights()
        
        // Add horizontal lines
        addHorizontalLines()
        
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
    
    func getGridOrigin() -> CGPoint {
        let totalGridWidth = CGFloat(gridSize) * tileSize
        let totalGridHeight = CGFloat(gridSize) * tileSize
        
        // Center horizontally
        let gridOriginX = (size.width - totalGridWidth) / 2
        
        // Position vertically (space above the grid for the score and below for placeholders)
        let topMargin: CGFloat = size.height * 0.10 // Space for score and icons
        let bottomMargin: CGFloat = size.height * 0.25 // Space for placeholders
        let gridOriginY = (size.height - totalGridHeight - topMargin - bottomMargin) / 2 + bottomMargin
        
        return CGPoint(x: gridOriginX, y: gridOriginY)
    }
    
    func createGrid() {
        grid = Array(repeating: Array(repeating: nil, count: gridSize), count: gridSize)
        let gridOrigin = getGridOrigin()
        let spacing: CGFloat = 3 // Spacing size
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cellNode = SKShapeNode(rectOf: CGSize(width: tileSize - spacing, height: tileSize - spacing), cornerRadius: 4)
                
                // Enhanced styles
                cellNode.fillColor = UIColor.lightGray.withAlphaComponent(0.1) // Subtle light gray fill
                cellNode.strokeColor = .clear  // Subtle border color
                cellNode.lineWidth = 1.0                                      // Thin grid lines
                
                cellNode.position = CGPoint(
                    x: gridOrigin.x + CGFloat(col) * tileSize + tileSize / 2,
                    y: gridOrigin.y + CGFloat(row) * tileSize + tileSize / 2
                )
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
                        print("Valid move found for block at row: \(row), col: \(col)")
                        return true
                    }
                }
            }
        }
        print("No valid moves available.")
        return false
    }


func fadeBlocksToGrey(_ nodes: [SKShapeNode], completion: @escaping () -> Void) {
    let fadeActions = nodes.map { node -> SKAction in
        if let spriteNode = node.children.first as? SKSpriteNode {
            return SKAction.sequence([
                SKAction.group([
                    SKAction.fadeAlpha(to: 0.5, duration: 0.5), // Fade effect
                    SKAction.colorize(with: UIColor(white: 0.2, alpha: 1.0), colorBlendFactor: 1.0, duration: 0.5) // Fully replace with dark gray
                ])
            ])
        }
        return SKAction() // No-op for nodes without children
    }
    
    let animationGroup = SKAction.group(fadeActions)
    let sequence = SKAction.sequence([animationGroup, SKAction.run(completion)])
    
    for node in nodes {
        node.run(sequence)
    }
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
        let scaledTileSize = tileSize * 0.6  // Adjust scale to make blocks visually smaller

        // Calculate total width of all blocks without spacing
        var totalBlockWidth: CGFloat = 0
        for block in boxNodes {
            let blockWidth = CGFloat(block.gridWidth) * scaledTileSize
            totalBlockWidth += blockWidth
        }

        // Calculate available width and spacing between blocks
        let availableWidth = size.width - totalBlockWidth  // Remaining space for spacing
        let numberOfSpaces = CGFloat(boxNodes.count - 1)
        let spacing = availableWidth / (numberOfSpaces + 2)  // Include equal spacing on the sides

        // Adjust starting X position to center the blocks horizontally
        let startXPosition = spacing

        // Keep the same Y position for spawned blocks
        let blockYPosition = size.height * 0.2  // Y position remains unchanged
        var currentXPosition = startXPosition

        // Layout the blocks with consistent spacing
        for block in boxNodes {
            let blockWidth = CGFloat(block.gridWidth) * scaledTileSize
            block.position = CGPoint(x: currentXPosition, y: blockYPosition)
            block.initialPosition = block.position
            block.gameScene = self

            // Set scale and add block to the scene
            block.setScale(0.6)  // Keep blocks at 70% of their full size
            safeAddBlock(block)

            // Move to the next block position
            currentXPosition += blockWidth + spacing
        }
    }
    
    func isPlacementValid(for block: BBoxNode, at row: Int, col: Int) -> Bool {
        for cell in block.shape {
            let gridRow = row + cell.row
            let gridCol = col + cell.col
            
            if gridRow < 0 || gridRow >= gridSize || gridCol < 0 || gridCol >= gridSize {
                print("Placement out of bounds for cell at row: \(gridRow), col: \(gridCol)")
                return false
            }
            
            if grid[gridRow][gridCol] != nil {
                print("Cell already occupied at row: \(gridRow), col: \(gridCol)")
                return false
            }
        }
        return true
    }

    func deactivateActivePowerup() {
        if let activeIcon = activePowerupIcon {
            removeHighlightFromPowerupIcon(activeIcon)
            activePowerupIcon = nil
        }
        activePowerup = nil
    }


    func placeBlock(_ block: BBoxNode, at gridPosition: (row: Int, col: Int)) {
        let row = gridPosition.row
        let col = gridPosition.col
        let gridOrigin = getGridOrigin()
        
        if isPlacementValid(for: block, at: row, col: col) {
            let previousScore = score
            var addedCells: [(row: Int, col: Int, cellNode: SKShapeNode)] = []
            
            var occupiedCells = 0
            var cellNodes: [SKShapeNode] = []
            var gridPositions: [GridCoordinate] = []
            
            // Place each cell of the block onto the grid
            for (index, cell) in block.shape.enumerated() {
                let gridRow = row + cell.row
                let gridCol = col + cell.col

                let cellNode = SKShapeNode(rectOf: CGSize(width: tileSize, height: tileSize))
                cellNode.fillColor = .clear
                cellNode.strokeColor = .clear
                cellNode.lineWidth = 0.0

                let asset = block.assets[index].name
                let assetTexture = SKTexture(imageNamed: asset)
                let spriteNode = SKSpriteNode(texture: assetTexture)
                spriteNode.size = CGSize(width: tileSize, height: tileSize)
                cellNode.addChild(spriteNode)

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
                
                addedCells.append((row: gridRow, col: gridCol, cellNode: cellNode))
            }
            
            // Create PlacedBlock object
            let placedBlock = PlacedBlock(cellNodes: cellNodes, gridPositions: gridPositions)
            for cellNode in cellNodes {
                cellNode.userData = ["placedBlock": placedBlock]
            }
            placedBlocks.append(placedBlock)
            
            score += occupiedCells
            updateScoreLabel()
            
            // Add sparkle or other effects
            addSparkleEffect(around: cellNodes)

            // Remove the block from the spawn area
            if let index = boxNodes.firstIndex(of: block) {
                boxNodes.remove(at: index)
            }
            block.removeFromParent()

            // Check for completed lines
            let clearedLines = checkForCompletedLines()
            let totalLinesCleared = clearedLines.count
            let totalPoints = totalLinesCleared * 10
            
            // **Place the centroid and combo multiplier code here**
            if totalLinesCleared > 0 {
                // Calculate the centroid of the placed block’s cells
                let blockCenter = centroidOfBlockCells(cellNodes)
                // Show score and apply combo multiplier at the block center
                applyComboMultiplier(for: totalLinesCleared, totalPoints: totalPoints, displayPosition: blockCenter)
            }
            
            // Create a Move object for undo
            let move = Move(
                placedBlock: placedBlock,
                blockNode: block,
                previousScore: previousScore,
                addedCells: addedCells,
                clearedLines: clearedLines
            )
            undoStack.append(move)

            // Handle spawning new blocks or checking for game-over
            if isUndoInProgress {
                boxNodes = tempSpawnedBlocks
                tempSpawnedBlocks.removeAll()
                for spawnedBlock in boxNodes {
                    safeAddBlock(spawnedBlock)
                }
                layoutSpawnedBlocks()
                isUndoInProgress = false
            } else if boxNodes.isEmpty {
                spawnNewBlocks()
            } else if !checkForPossibleMoves(for: boxNodes) {
                let gridNodes = placedBlocks.flatMap { $0.cellNodes }
                fadeBlocksToGrey(gridNodes) {
                    self.showGameOverScreen()
                }
            }

            run(SKAction.playSoundFileNamed("download.mp3", waitForCompletion: false))
        } else {
            // If invalid, return the block to its initial position
            block.position = block.initialPosition
            block.run(SKAction.scale(to: initialScale, duration: 0.1))
        }
        printGridState()
    }

    func centroidOfBlockCells(_ cellNodes: [SKShapeNode]) -> CGPoint {
        guard !cellNodes.isEmpty else { return .zero }
        var totalX: CGFloat = 0
        var totalY: CGFloat = 0
        
        for cell in cellNodes {
            totalX += cell.position.x
            totalY += cell.position.y
        }
        
        let count = CGFloat(cellNodes.count)
        return CGPoint(x: totalX / count, y: totalY / count)
    }

// Creates sparkle effect around the placed block
func addSparkleEffect(around cellNodes: [SKShapeNode]) {
    // Create multiple sparkles around the edges of each block
    for cellNode in cellNodes {
        // Create a small number of sparkles for each cell to make it cleaner
        let sparkleCount = 8 // Adjust the number of sparkles around each cell
        let edgeOffset: CGFloat = tileSize / 2.5  // Adjust how far from the edges the sparkles appear

        for _ in 0..<sparkleCount {
            // Create a small circle for the sparkle
            let sparkle = SKShapeNode(circleOfRadius: 3)  // Smaller sparkles
            sparkle.fillColor = .white  // Color of the sparkle
            sparkle.alpha = 0.6  // Slightly transparent for subtle effect

            // Randomize the position around the edges of the cell node
            let randomAngle = CGFloat.random(in: 0..<2 * .pi)
            let randomRadius = CGFloat.random(in: edgeOffset...tileSize / 2)
            let randomXOffset = randomRadius * cos(randomAngle)
            let randomYOffset = randomRadius * sin(randomAngle)
            
            sparkle.position = CGPoint(x: cellNode.position.x + randomXOffset, y: cellNode.position.y + randomYOffset)

            addChild(sparkle)

            // Animate the sparkle (scale up, fade out, and move)
            let scaleUpAction = SKAction.scale(to: 1.2, duration: 0.2)
            let fadeOutAction = SKAction.fadeOut(withDuration: 0.4)
            let moveAction = SKAction.moveBy(x: randomXOffset * 0.3, y: randomYOffset * 0.3, duration: 0.4)

            // Combine the actions (scale up, fade out, move)
            let sparkleAnimation = SKAction.group([scaleUpAction, fadeOutAction, moveAction])

            // Run the animation on the sparkle node
            sparkle.run(sparkleAnimation) {
                sparkle.removeFromParent() // Remove the sparkle after animation completes
            }
        }
    }
}




    
    // MARK: - Line Clearing Logic
      struct GridPosition: Hashable {
        let row: Int
        let col: Int
    }

    func checkForCompletedLines() -> [LineClear] {
        var lineClears: [LineClear] = []
        var completedRows: [Int] = []
        var completedColumns: [Int] = []
        
        // Identify completed rows
        for row in 0..<gridSize {
            if grid[row].allSatisfy({ $0 != nil }) {
                completedRows.append(row)
            }
        }
        
        // Identify completed columns
        for col in 0..<gridSize {
            var isCompleted = true
            for row in 0..<gridSize {
                if grid[row][col] == nil {
                    isCompleted = false
                    break
                }
            }
            if isCompleted {
                completedColumns.append(col)
            }
        }
        
        // Now clear all identified rows and columns
        var totalLinesCleared = 0
        var totalPoints = 0
        
        for row in completedRows {
            let clearedCells = clearRow(row)
            let lineClear = LineClear(isRow: true, index: row, clearedCells: clearedCells)
            lineClears.append(lineClear)
            totalLinesCleared += 1
            totalPoints += 10
        }
        
        for col in completedColumns {
            let clearedCells = clearColumn(col)
            let lineClear = LineClear(isRow: false, index: col, clearedCells: clearedCells)
            lineClears.append(lineClear)
            totalLinesCleared += 1
            totalPoints += 10
        }
        
        // Handle progress, combo, etc.
        if totalLinesCleared > 0 {
            self.linesCleared += totalLinesCleared
            updateProgressBar()
        } else {
            let currentTime = Date().timeIntervalSinceReferenceDate
            if currentTime - lastClearTime > comboResetTime {
                currentCombo = 1
            }
        }
        
        if totalLinesCleared > 0 {
            lastClearTime = Date().timeIntervalSinceReferenceDate
        }
        
        // Sync placed blocks
        syncPlacedBlocks()
        
        return lineClears
    }


    func syncPlacedBlocks() {
        placedBlocks = placedBlocks.compactMap { block in
            // Filter out any cellNodes that no longer exist in the scene
            block.cellNodes = block.cellNodes.filter { $0.parent != nil }
            
            // If the block has no remaining cells, exclude it
            return block.cellNodes.isEmpty ? nil : block
        }
    }
    func printGridState() {
        for row in (0..<gridSize).reversed() { // print top row last for a visual top-to-bottom
            var rowState = ""
            for col in 0..<gridSize {
                rowState += (grid[row][col] == nil) ? "." : "X"
            }
            print(rowState)
        }
        print("-----")
    }

    
    func applyComboMultiplier(for linesCleared: Int, totalPoints: Int, displayPosition: CGPoint) {
        var points = totalPoints * currentCombo
        
        // Apply multiplier power-up if active
        if activePowerup == .multiplier {
            points *= 2  // Apply 2x multiplier
            
            // Find the placeholder index of the active power-up and reset it
            if let placeholder = activePowerupIcon?.parent as? SKShapeNode,
               let index = placeholderIndex(for: placeholder) {
                resetPlaceholder(at: index)
            }
            deactivateActivePowerup()
        }
        
        // Update score
        score += points
        updateScoreLabel()
        
        // Display combo animation if combo multiplier is greater than 1
        if currentCombo > 1 {
            displayComboAnimation(for: currentCombo)
        }
        
        // Display animated points at the block placement position
        displayAnimatedPoints(points, at: displayPosition)
        
        // Increment combo multiplier for consecutive clears
        currentCombo += 1
        
        // Reset combo after a delay if no further lines are cleared
        resetComboAfterDelay()
        
        // Play a combo sound effect for multi-line clears
        if linesCleared > 1 {
            run(SKAction.playSoundFileNamed("ComboSound.mp3", waitForCompletion: false))
        }
    }




  func gridToScreenPosition(row: Int, col: Int) -> CGPoint {
    // Get the grid origin (assuming it's calculated somewhere else, like in createGrid())
    let gridOrigin = getGridOrigin() // You can use your existing grid origin calculation
    
    // Calculate cell size (using tileSize from your grid layout)
    let cellSize = tileSize
    
    // Calculate the center of the cell
    let xPosition = gridOrigin.x + CGFloat(col) * cellSize + cellSize / 2
    let yPosition = gridOrigin.y + CGFloat(row) * cellSize + cellSize / 2
    
    return CGPoint(x: xPosition, y: yPosition)
}




    
    func createShadowedLabel(text: String, position: CGPoint, fontSize: CGFloat) -> SKLabelNode {
        let shadowLabel = SKLabelNode(text: text)
        shadowLabel.fontSize = fontSize
        shadowLabel.fontColor = .black  // Dark color for shadow
        shadowLabel.position = CGPoint(x: position.x + 2, y: position.y - 2) // Slight offset
        shadowLabel.fontName = "Arial-BoldMT"
        return shadowLabel
    }
    
    func displayComboAnimation(for multiplier: Int) {
        // Define maximum position for the combo label based on screen size
        let maxComboYPosition = frame.midY + 150
        
        // Position combo label within screen bounds
        let comboLabelYPosition = min(frame.midY + 200, maxComboYPosition) // Clamps Y position to prevent going off-screen
        
        let comboLabel = SKLabelNode(text: "COMBO x\(multiplier)")
        comboLabel.fontSize = min(70, frame.width * 0.1)  // Adjust font size based on screen width
        comboLabel.fontColor = .yellow
        comboLabel.fontName = "Arial-BoldMT"
        comboLabel.position = CGPoint(x: frame.midX, y: comboLabelYPosition)
        
        // Create shadow by adding another label
        let shadowComboLabel = createShadowedLabel(text: "COMBO x\(multiplier)", position: comboLabel.position, fontSize: comboLabel.fontSize)
        addChild(shadowComboLabel)
        
        addChild(comboLabel)  // Add combo label to the scene
        
        // Animation sequence (scale up, bounce, fade out)
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let bounce = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 20, duration: 0.1),
            SKAction.moveBy(x: 0, y: -10, duration: 0.1),
            SKAction.moveBy(x: 0, y: 10, duration: 0.1)
        ])
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        
        let comboAnimation = SKAction.sequence([scaleUp, bounce, fadeOut, remove])
        
        comboLabel.run(comboAnimation)
        shadowComboLabel.run(comboAnimation)  // Make shadow move as well
    }
    
   func displayAnimatedPoints(_ points: Int, at position: CGPoint) {
    let pointsLabel = SKLabelNode(text: "+\(points)")
    pointsLabel.fontName = "Arial-BoldMT"
    pointsLabel.fontSize = 24  // Smaller font size for less distraction
    pointsLabel.fontColor = .white
    pointsLabel.position = position
    pointsLabel.zPosition = 100
    
    // Add glow effect using blending mode
    pointsLabel.blendMode = .add // This gives a glowing effect
    
    addChild(pointsLabel)
    
    // Animation sequence (scale up slightly, move upwards, fade out)
    let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)  // Slight scale up
    let moveUp = SKAction.moveBy(x: 0, y: 30, duration: 0.5)  // Shorter upward movement
    let fadeOut = SKAction.fadeOut(withDuration: 0.5)  // Fade out more quickly
    let remove = SKAction.run { pointsLabel.removeFromParent() }
    
    // Optional: Add a subtle sparkle effect (or rotation)
    let sparkle = SKAction.sequence([
        SKAction.scale(to: 1.1, duration: 0.1),  // Small scale effect
        SKAction.scale(to: 1.0, duration: 0.1)   // Return to original size
    ])
    
    let animationSequence = SKAction.sequence([scaleUp, moveUp, sparkle, fadeOut, remove])
    
    pointsLabel.run(animationSequence)
}

    func resetComboAfterDelay() {
        let currentTime = CACurrentMediaTime()
        let elapsedTime = currentTime - lastClearTime
        
        if elapsedTime > comboResetTime {
            currentCombo = 1
        }
        
        // Update the last clear time
        lastClearTime = currentTime
    }
    
    func pointsForLinesCleared(_ lines: Int) -> Int {
        // Points are determined by the combo multiplier (handled in `applyComboMultiplier`)
        return 10 * lines
    }
    
  func clearRow(_ row: Int) -> [(row: Int, col: Int, cellNode: SKShapeNode)] {
    var clearedCells: [(row: Int, col: Int, cellNode: SKShapeNode)] = []

    for col in 0..<gridSize {
        if let cellNode = grid[row][col] {
            let originalPosition = cellNode.position

            let burstAction = SKAction.group([
                SKAction.scale(to: 1.5, duration: 0.2),
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.moveBy(x: CGFloat.random(in: -30...30), y: CGFloat.random(in: -30...30), duration: 0.3)
            ])

            let removeAction = SKAction.run {
                cellNode.removeFromParent()
            }

            let sequence = SKAction.sequence([burstAction, removeAction])
            cellNode.run(sequence)

            grid[row][col] = nil
            clearedCells.append((row: row, col: col, cellNode: cellNode))

            cellNode.userData?["originalPosition"] = originalPosition
        }
    }

    // Add multiplier animation if the power-up is active
    if activePowerup == .multiplier {
        let rowCenterY = gridToScreenPosition(row: row, col: gridSize / 2).y
        showMultiplierEffect(at: CGPoint(x: size.width / 2, y: rowCenterY))
    }

    run(SKAction.playSoundFileNamed("Risingwav.mp3", waitForCompletion: false))

    return clearedCells
}




func clearColumn(_ col: Int) -> [(row: Int, col: Int, cellNode: SKShapeNode)] {
    var clearedCells: [(row: Int, col: Int, cellNode: SKShapeNode)] = []

    for row in 0..<gridSize {
        if let cellNode = grid[row][col] {
            let originalPosition = cellNode.position

            let burstAction = SKAction.group([
                SKAction.scale(to: 1.5, duration: 0.2),
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.moveBy(x: CGFloat.random(in: -30...30), y: CGFloat.random(in: -30...30), duration: 0.3)
            ])

            let removeAction = SKAction.run {
                cellNode.removeFromParent()
            }

            let sequence = SKAction.sequence([burstAction, removeAction])
            cellNode.run(sequence)

            grid[row][col] = nil
            clearedCells.append((row: row, col: col, cellNode: cellNode))

            cellNode.userData?["originalPosition"] = originalPosition
        }
    }

    // Add multiplier animation if the power-up is active
    if activePowerup == .multiplier {
        let colCenterX = gridToScreenPosition(row: gridSize / 2, col: col).x
        showMultiplierEffect(at: CGPoint(x: colCenterX, y: size.height / 2))
    }

    run(SKAction.playSoundFileNamed("Risingwav.mp3", waitForCompletion: false))

    return clearedCells
}



   func showMultiplierEffect(at position: CGPoint) {
    let multiplierLabel = SKLabelNode(text: "x1.5")
    multiplierLabel.fontSize = 60
    multiplierLabel.fontName = "HelveticaNeue-Bold"
    multiplierLabel.position = position
    multiplierLabel.zPosition = 100
    multiplierLabel.colorBlendFactor = 1.0
    addChild(multiplierLabel)
    
    // Rainbow color animation
    let rainbowColors: [SKColor] = [.red, .orange, .yellow, .green, .blue, .purple]
    let colorChangeActions = rainbowColors.map { color in
        SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: 0.2)
    }
    let rainbowSequence = SKAction.sequence(colorChangeActions)
    let repeatRainbow = SKAction.repeatForever(rainbowSequence)
    multiplierLabel.run(repeatRainbow)
    
    // Scale and fade out animation
    let fadeOut = SKAction.fadeOut(withDuration: 1.5)
    let scaleUp = SKAction.scale(to: 2.0, duration: 1.5)
    let group = SKAction.group([fadeOut, scaleUp])
    let remove = SKAction.removeFromParent()
    let sequence = SKAction.sequence([group, remove])
    
    multiplierLabel.run(sequence)
    
    // Debug print
    print("Multiplier effect triggered at position: \(position)")
}


     func showGameOverScreen() {
        isGameOver = true
        
        // Play Game Over Sound
        if let url = Bundle.main.url(forResource: "Muted", withExtension: "mp3") {
            do {
                gameOverAudioPlayer = try AVAudioPlayer(contentsOf: url)
                gameOverAudioPlayer?.play()
            } catch {
                print("Error: Unable to play Game Over sound. \(error.localizedDescription)")
            }
        }
        
        // Stop background music
        backgroundMusic?.removeFromParent()
        backgroundMusic = nil
        
        // Semi-transparent background overlay
        let overlay = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        overlay.fillColor = UIColor.black.withAlphaComponent(0.8)
        overlay.strokeColor = UIColor.clear // Ensure no border is drawn
        overlay.zPosition = 10
        overlay.name = "gameOverUI"
        overlay.position = CGPoint(x: 0, y: 0) // Align to screen's bottom-left corner
        addChild(overlay)
        
        // Create the red Game Over banner
        let banner = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.2))
        banner.fillColor = UIColor.systemRed
        banner.position = CGPoint(x: size.width / 2, y: size.height / 2)
        banner.zPosition = 11
        banner.name = "gameOverUI" // For cleanup
        addChild(banner)
        
        // Custom Smiley Face
        let faceRadius: CGFloat = 50
        let faceCenter = CGPoint(x: size.width / 2, y: size.height / 2)
        
        // Face circle
        let face = SKShapeNode(circleOfRadius: faceRadius)
        face.fillColor = UIColor.white
        face.strokeColor = UIColor.clear
        face.position = faceCenter
        face.zPosition = 12
        face.name = "gameOverUI"
        addChild(face)
        
        // Left eye
        let leftEye = SKShapeNode(circleOfRadius: 8)
        leftEye.fillColor = UIColor.systemRed // Matches the banner
        leftEye.strokeColor = UIColor.clear
        leftEye.position = CGPoint(x: faceCenter.x - 20, y: faceCenter.y + 15)
        leftEye.zPosition = 13
        leftEye.name = "gameOverUI"
        addChild(leftEye)
        
        // Right eye
        let rightEye = SKShapeNode(circleOfRadius: 8)
        rightEye.fillColor = UIColor.systemRed // Matches the banner
        rightEye.strokeColor = UIColor.clear
        rightEye.position = CGPoint(x: faceCenter.x + 20, y: faceCenter.y + 15)
        rightEye.zPosition = 13
        rightEye.name = "gameOverUI"
        addChild(rightEye)
        
        // Sad mouth
        let mouthPath = CGMutablePath()
        mouthPath.addArc(center: CGPoint.zero, radius: 20, startAngle: CGFloat.pi, endAngle: CGFloat(2 * Double.pi), clockwise: true)
        let mouth = SKShapeNode(path: mouthPath)
        mouth.strokeColor = UIColor.systemRed // Matches the banner
        mouth.lineWidth = 3
        mouth.position = CGPoint(x: faceCenter.x, y: faceCenter.y - 20)
        mouth.zPosition = 13
        mouth.name = "gameOverUI"
        addChild(mouth)
        
        // Final score label
        let finalScoreLabel = SKLabelNode(text: "Score: \(score)")
        finalScoreLabel.fontSize = 36
        finalScoreLabel.fontColor = UIColor.white
        finalScoreLabel.fontName = "HelveticaNeue-Bold"
        finalScoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.75)
        finalScoreLabel.zPosition = 12
        finalScoreLabel.name = "gameOverUI"
        addChild(finalScoreLabel)
        
        // Restart button
        let restartButton = SKShapeNode(rectOf: CGSize(width: size.width * 0.4, height: size.height * 0.08), cornerRadius: 10)
        restartButton.fillColor = UIColor.systemBlue
        restartButton.position = CGPoint(x: size.width / 2, y: size.height * 0.25)
        restartButton.zPosition = 12
        restartButton.name = "restartButton" // For touch detection
        addChild(restartButton)
        
        let restartLabel = SKLabelNode(text: "Restart")
        restartLabel.fontSize = 24
        restartLabel.fontColor = UIColor.white
        restartLabel.fontName = "HelveticaNeue-Bold"
        restartLabel.position = CGPoint(x: 0, y: -10)
        restartLabel.zPosition = 13
        restartLabel.name = "restartButton" // For touch detection
        restartButton.addChild(restartLabel)
    }
    
    func restartGame() {
        print("Restarting game...")
        
        // Stop the Game Over sound
        if let gameOverAudioPlayer = gameOverAudioPlayer {
            gameOverAudioPlayer.stop()
            self.gameOverAudioPlayer = nil
        }
        
        score = 0
        updateScoreLabel()
        
        // Reset the grid and remove all children from the scene
        grid = Array(repeating: Array(repeating: nil, count: gridSize), count: gridSize)
        removeAllChildren()
        
        isGameOver = false
        placedBlocks.removeAll() // Clear the placed blocks
        undoStack.removeAll()    // Clear the undo stack
        
        // Set the background color to black
//        backgroundColor = .black
        
        // Re-add other game elements
        createGrid()
        addScoreLabel()
        spawnNewBlocks()
        createPowerupPlaceholders()
        setupGridHighlights()
        addHorizontalLines()
        createProgressBar()
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
    
    func updateScoreLabel() {
        if let scoreContainer = childNode(withName: "scoreContainer") as? SKShapeNode,
           let scoreLabel = scoreContainer.childNode(withName: "scoreLabel") as? SKLabelNode {
            scoreLabel.text = "\(score)"
        }
    }
    



override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let location = touch.location(in: self)
    let nodeTapped = atPoint(location)

    if isGameOver {
        if nodeTapped.name == "restartButton" {
            restartGame()
        }
        return
    }

    // Check if a power-up icon is tapped
    if let powerupIcon = nodeTapped as? SKSpriteNode, powerupIcon.name == "powerupIcon",
       let powerupType = powerupIcon.userData?["powerupType"] as? PowerupType {
        
        if let currentActivePowerupIcon = activePowerupIcon {
            if currentActivePowerupIcon == powerupIcon {
                // Tapped on the active power-up icon, so deactivate it
                deactivateActivePowerup()
            } else {
                // Another power-up is already active, cannot activate a new one
                print("Another power-up is already active.")
                return
            }
        } else {
            // No power-up is active, so activate the tapped one
            activePowerup = powerupType
            activePowerupIcon = powerupIcon
            highlightPowerupIcon(powerupIcon)
            
            if powerupType == .undo {
                if let placeholder = powerupIcon.parent as? SKShapeNode,
                   let index = placeholderIndex(for: placeholder) {
                    undoLastMove()
                    resetPlaceholder(at: index)
                }
                deactivateActivePowerup()
            }
        }
        return
    }

    // If a power-up is active, handle its specific action
    if let activePowerup = activePowerup {
        switch activePowerup {
        case .delete:
            if let cellNode = nodeTapped.closestParent(ofType: SKShapeNode.self),
               let placedBlock = cellNode.userData?["placedBlock"] as? PlacedBlock {
               
               let wasDeleted = deletePlacedBlock(placedBlock, updateScore: false)
               
               if wasDeleted {
                   // Full block was successfully deleted
                   if let placeholder = activePowerupIcon?.parent as? SKShapeNode,
                      let index = placeholderIndex(for: placeholder) {
                       resetPlaceholder(at: index)
                   }
                   deactivateActivePowerup()
               } else {
                   // Block not deleted because it isn't full
                   print("Block could not be deleted because it wasn't full. Power-up remains active.")
                   // The block should remain as is, with no changes to the grid or placedBlocks.
               }
            }
            return

        case .swap:
            if let blockNode = nodeTapped.closestParent(ofType: BBoxNode.self),
               boxNodes.contains(blockNode) {
                // Swap the block
                deleteBlock(blockNode)
                // Find the placeholder index of the active power-up
                if let placeholder = activePowerupIcon?.parent as? SKShapeNode,
                   let index = placeholderIndex(for: placeholder) {
                    resetPlaceholder(at: index)
                }
                deactivateActivePowerup()
            }
            return
        case .undo:
            // Undo is executed immediately when tapped, so no action here
            return
        case .multiplier:
            // Multiplier is applied during line clears, no immediate action
            // Do not return here; allow block interaction
            break // Continue to allow block interaction
        }
    }

    // Handle block selection and dragging based on proximity
    if let blockNode = nodeTapped.closestParent(ofType: BBoxNode.self), boxNodes.contains(blockNode) {
        currentlyDraggedNode = blockNode
    } else {
        // If tapped outside, check proximity to all blocks
        for blockNode in boxNodes {
            let distance = distanceBetweenPoints(location, blockNode.position)
            let selectionRadius: CGFloat = 100 // Increase this radius as needed
            
            // Debug print to check the distance
            print("Distance from touch to block: \(distance), Selection radius: \(selectionRadius)")

            if distance < selectionRadius {
                // Debug print to confirm the block selected
                print("Block selected: \(blockNode)")
                currentlyDraggedNode = blockNode
                break
            }
        }
    }

    // Play block selection sound when a block is selected
    if let node = currentlyDraggedNode {
        // Reset rotate power-up icon appearance
        if let rotatePowerupIcon = childNode(withName: "//rotatePowerup") as? SKSpriteNode {
            rotatePowerupIcon.colorBlendFactor = 0.0
        }

        // Play the selection sound
        if let url = Bundle.main.url(forResource: "Soft_Pop_or_Click", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("Error: Unable to play sound - \(error)")
            }
        } else {
            print("Error: Audio file not found.")
        }

        // Increase the size of the block when it's selected
        node.run(SKAction.scale(to: 1.0, duration: 0.1))

        // Calculate touch offset for smooth dragging (ensure the block stays centered under the touch)
        let touchLocation = touch.location(in: self)
        let offsetX = node.position.x - touchLocation.x
        let offsetY = node.position.y - touchLocation.y

        node.userData = ["offsetX": offsetX, "offsetY": offsetY]
    }
}

// Helper function to calculate the distance between two points
func distanceBetweenPoints(_ point1: CGPoint, _ point2: CGPoint) -> CGFloat {
    return sqrt(pow(point2.x - point1.x, 2) + pow(point2.y - point1.y, 2))
}






    
    func deletePlacedBlock(_ placedBlock: PlacedBlock, updateScore: Bool = true) -> Bool {
        // Debug print to inspect the block's cell counts before the fullness check
        print("Attempting to delete block...")
        print("cellNodes.count = \(placedBlock.cellNodes.count), gridPositions.count = \(placedBlock.gridPositions.count)")

        // Check if the block is still full (no missing cells)
        if placedBlock.cellNodes.count < placedBlock.gridPositions.count {
            print("Cannot delete this block because it is not full. Some cells are missing due to line clears.")
            return false
        }

        // If we reach here, the block is considered full
        // You can also print a confirmation here:
        print("Block is full and will be deleted.")

        // Proceed with the existing deletion logic
        for cellNode in placedBlock.cellNodes {
            cellNode.removeFromParent()
            // Clear userData
            cellNode.userData = nil
        }

        for gridPos in placedBlock.gridPositions {
            grid[gridPos.row][gridPos.col] = nil
        }

        if let index = placedBlocks.firstIndex(where: { $0 === placedBlock }) {
            placedBlocks.remove(at: index)
        }

        if updateScore {
            score += placedBlock.cellNodes.count
            updateScoreLabel()
        }

        _ = checkForCompletedLines()
        syncPlacedBlocks()

        if boxNodes.isEmpty || (!checkForPossibleMoves(for: boxNodes) && !isDeletePowerupAvailable()) {
            showGameOverScreen()
        }

        return true
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
    
override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first, let node = currentlyDraggedNode else { return }
    
    let touchLocation = touch.location(in: self)
    
    // If the block is being dragged, ensure it is fully opaque
    node.alpha = 1.0
    
    // Retrieve the stored offset if it exists, otherwise calculate it
    if let offsetX = node.userData?["offsetX"] as? CGFloat,
       let offsetY = node.userData?["offsetY"] as? CGFloat {
        
        // Adjust the offset to move the block upwards (increase the Y-offset)
        let distanceFactor: CGFloat = 100 // Increase this factor to move the block further upwards
        
        // Calculate the new target position based on the touch location and adjusted offset
        let targetPosition = CGPoint(x: touchLocation.x + offsetX,
                                     y: touchLocation.y + offsetY + distanceFactor) // Move the block upwards
        
        // Smooth movement via interpolation
        let currentPosition = node.position
        let easedPosition = interpolate(from: currentPosition, to: targetPosition, fraction: 0.3)
        
        // Update the node’s position
        node.position = easedPosition
    }
    
    // Highlight valid cells based on the updated position
    highlightValidCells(for: node)
}


    
    func interpolate(from start: CGPoint, to end: CGPoint, fraction: CGFloat) -> CGPoint {
        let x = start.x + (end.x - start.x) * fraction
        let y = start.y + (end.y - start.y) * fraction
        return CGPoint(x: x, y: y)
    }
    
    func positionForGridCoordinate(_ coordinate: GridCoordinate) -> CGPoint {
    let x = gridOrigin.x + CGFloat(coordinate.col) * cellSize
    let y = gridOrigin.y + CGFloat(coordinate.row) * cellSize
    return CGPoint(x: x, y: y)
}

func undoLastMove() {
    // Check if there is a move to undo
    guard let move = undoStack.popLast() else { return }
    
    // Step 1: Remove the placed block from the grid and scene
    for gridPos in move.placedBlock.gridPositions {
        if let cellNode = grid[gridPos.row][gridPos.col] {
            cellNode.removeFromParent()
            grid[gridPos.row][gridPos.col] = nil
        }
    }
    
    // Remove the placed block from the placedBlocks array
    if let index = placedBlocks.firstIndex(where: { $0 === move.placedBlock }) {
        placedBlocks.remove(at: index)
    }
    
    // Step 2: Restore the cleared lines
    for lineClear in move.clearedLines {
        for (row, col, cellNode) in lineClear.clearedCells {
            grid[row][col] = cellNode
            if cellNode.parent == nil {
                addChild(cellNode)
            }
            cellNode.alpha = 1.0
            cellNode.setScale(1.0)
            
            // Restore the original position
            if let originalPosition = cellNode.userData?["originalPosition"] as? CGPoint {
                cellNode.position = originalPosition
            } else {
                cellNode.position = positionForGridCoordinate(GridCoordinate(row: row, col: col))
            }
        }
    }
    
    // Step 3: Remove any remnants of the placed block from the grid
    for (row, col, cellNode) in move.addedCells {
        grid[row][col] = nil
        cellNode.removeFromParent()
    }
    
    // Step 4: Restore the block node to a temporary "undo" position
    move.blockNode.position = getUndoBlockCenterPosition()
    move.blockNode.setScale(initialScale)
    
    // Add the undo block directly to the scene but not to `boxNodes`
    safeAddBlock(move.blockNode)
    
    // Step 5: Restore the score
    score = move.previousScore
    updateScoreLabel()
    
    // Step 6: Reset the current combo multiplier to its base value
    currentCombo = 1 // Reset combo multiplier
    // Optionally, update any UI elements tracking the combo multiplier here (if needed)
    
    // Step 7: Clear any visual highlights
    clearHighlights()
    
    // Step 8: Hide current spawned blocks and store them
    tempSpawnedBlocks = boxNodes
    for block in boxNodes {
        block.removeFromParent()
    }
    boxNodes.removeAll()
    
    // Step 9: Add the undo block to boxNodes and the scene
    boxNodes.append(move.blockNode)
    safeAddBlock(move.blockNode)
    move.blockNode.position = getUndoBlockCenterPosition()
    move.blockNode.setScale(initialScale)
    move.blockNode.gameScene = self

    // Set the undo in progress flag
    isUndoInProgress = true
}


// Helper function to calculate the center position for the undo block
func getUndoBlockCenterPosition() -> CGPoint {
    let centerX = size.width / 2
    let centerY = size.height * 0.2  // Match the Y position of the spawn area
    return CGPoint(x: centerX, y: centerY)
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

extension SKNode {
    func closestParent<T: SKNode>(ofType type: T.Type) -> T? {
        var currentNode: SKNode? = self
        while let node = currentNode {
            if let parent = node as? T {
                return parent
            }
            currentNode = node.parent
        }
        return nil
    }
}
extension UIImage {
    convenience init(color: UIColor, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
}


