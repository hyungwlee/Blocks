//
//  BGameScene.swift
//  Blocks
//
//  Created by Jevon Williams on 10/24/24.


import SpriteKit
import AVFoundation


class BGameScene: SKScene {
   let gridSize = 8

// Declare layoutInfo as a non-lazy property
var layoutInfo: BLayoutInfo

var gameOverSoundPlayer: AVAudioPlayer? // Variable to store the sound action
var hasShownMultiplierEffect = false  // Flag to track multiplier animation

var tileSize: CGFloat {
    return (size.width - 40) / CGFloat(gridSize)
}

// Power-up state variables
var activePowerup: PowerupType? = nil
var activePowerupIcon: SKSpriteNode? = nil // New variable to track the active power-up icon

var score = 0
var multiplierLabel: SKLabelNode!
var grid: [[SKShapeNode?]] = []
var boxNodes: [BBoxNode] = []
var currentlyDraggedNode: BBoxNode?
var gameContext: BGameContext?
var isGameOver: Bool = false
var placedBlocks: [PlacedBlock] = []
var gameOverAudioPlayer: AVAudioPlayer?
var lastClearTime: TimeInterval = 0 // Tracks the time of the last line cleared
var currentCombo: Int = 1 // Multiplier for consecutive clears within the time window
let comboResetTime: TimeInterval = 5 // Time window in seconds for combo multiplier

// Use computed properties for gridOrigin and cellSize
var gridOrigin: CGPoint {
    return layoutInfo.gridOrigin
}

var cellSize: CGFloat {
    return layoutInfo.cellSize
}

var currentVolume: Float = 0.5 // Default volume
var multiplier: Int = 1  // Default multiplier is 1 (no multiplier)
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

let initialScale: CGFloat  // Set the initial scale to 0.6

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
    Powerup(type: .multiplier, imageName: "multiplier.png")
]

// Initializer
init(context: BGameContext, dependencies: Dependencies, gameMode: GameModeType, size: CGSize) {
    self.gameContext = context
    self.dependencies = dependencies
    self.gameMode = gameMode

    // Initialize layoutInfo with the current screen size
    let screenSize = UIScreen.main.bounds.size
    self.layoutInfo = BLayoutInfo(screenSize: screenSize)
    self.initialScale = layoutInfo.initialScale // Assign the dynamic initialScale

    self.grid = Array(repeating: Array(repeating: nil, count: layoutInfo.gridSize), count: layoutInfo.gridSize)

    super.init(size: size)
}


required init?(coder aDecoder: NSCoder) {
    let defaultDependencies = Dependencies()
    self.dependencies = defaultDependencies
    self.gameMode = .single
    self.gameContext = BGameContext(dependencies: dependencies, gameMode: gameMode)

    // Initialize layoutInfo with the current screen size
    let screenSize = UIScreen.main.bounds.size
    self.layoutInfo = BLayoutInfo(screenSize: screenSize)
    self.initialScale = layoutInfo.initialScale // Assign the dynamic initialScale

    self.grid = Array(repeating: Array(repeating: nil, count: layoutInfo.gridSize), count: layoutInfo.gridSize)

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
    let placeholderSize = CGSize(width: 60, height: 60)
    let spacing: CGFloat = 30
    let totalWidth = placeholderSize.width * 4 + spacing * 3
    let startX = (size.width - totalWidth) / 2 + placeholderSize.width / 2

    // Conditional Y position adjustment based on screen height
    let yPosition: CGFloat
    if size.height <= 667 { // iPhone SE screen height (667 points)
        yPosition = size.height * 0.12  // Lower position for SE
    } else {
        yPosition = size.height * 0.16  // Default position for Pro and Pro Max
    }

    for i in 0..<4 {
        let placeholder = SKShapeNode(rectOf: placeholderSize, cornerRadius: 8)
        
        // Subtle outline effect
        placeholder.strokeColor = UIColor.white.withAlphaComponent(0.3) // Light, semi-transparent white
        placeholder.lineWidth = 1.0 // Thinner line for subtlety
        
        placeholder.fillColor = .clear
        placeholder.name = "powerupPlaceholder\(i)"
        placeholder.userData = ["powerup": NSNull()]
        
        let xPosition = startX + CGFloat(i) * (placeholderSize.width + spacing)
        placeholder.position = CGPoint(x: xPosition, y: yPosition)
        addChild(placeholder)
        
        // Add the question icon initially
        let questionIcon = SKSpriteNode(imageNamed: "questioni.png")
        questionIcon.size = CGSize(width: 40, height: 40)
        questionIcon.position = CGPoint.zero // Center within the placeholder
        questionIcon.name = "questionIcon\(i)"
        placeholder.addChild(questionIcon)
    }
}

    // MARK: - Variables for Progress Bar
         let requiredLinesForPowerup = 5// Number of lines required to fill the bar
         var linesCleared = 0 // Tracks the total lines cleared for the progress bar
    var progressBar: SKShapeNode? // Change from SKSpriteNode
    var progressBarBackground: SKShapeNode? // Keep as SKShapeNode


    // Change this property type accordingly at the top of your class:
    // var progressBar: SKShapeNode? // Instead of SKSpriteNode
    func changeProgressBarColor(to color: UIColor) {
        guard let progressBar = progressBar else {
            print("Progress bar node is missing!")
            return
        }
        // Always set the color to orange
        progressBar.fillColor = .orange
    }


  func createProgressBar() {
    // Define progress bar dimensions
    let barWidth: CGFloat = size.width * 0.80
    let barHeight: CGFloat = 10
    let cornerRadius = barHeight / 2

    // Conditional Y position adjustment based on screen height
    let barY: CGFloat
    if size.height <= 667 { // iPhone SE screen height (667 points)
        barY = size.height * 0.05  // Lower position for SE
    } else {
        barY = size.height * 0.1   // Default position for Pro and Pro Max
    }

    // Create the background for the progress bar
    progressBarBackground = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: cornerRadius)
    progressBarBackground?.fillColor = .darkGray
    progressBarBackground?.strokeColor = .clear
    progressBarBackground?.position = CGPoint(x: size.width / 2, y: barY)
    addChild(progressBarBackground!)

    // Create a clipping node for the progress bar
    let clippingNode = SKCropNode()
    clippingNode.position = progressBarBackground!.position
    clippingNode.zPosition = progressBarBackground!.zPosition + 1

    // Create a mask for the clipping node
    let maskNode = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: cornerRadius)
    maskNode.fillColor = .white
    clippingNode.maskNode = maskNode

    // Create the progress bar as a shape node
    progressBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: cornerRadius)
    progressBar?.fillColor = .orange // Set the color to orange
    progressBar?.strokeColor = .clear
    progressBar?.position = CGPoint(x: -barWidth / 2, y: 0) // Start from the left edge
    progressBar?.xScale = 0.0 // Initially empty

    // Add the progress bar to the clipping node
    clippingNode.addChild(progressBar!)
    addChild(clippingNode)
}





    func updateProgressBar() {
        guard let progressBar = progressBar, let progressBarBackground = progressBarBackground else {
            print("Progress bar node is missing!")
            return
        }

        let barWidth = progressBarBackground.frame.width
        let progress = CGFloat(linesCleared) / CGFloat(requiredLinesForPowerup)
        let newScale = min(progress, 1.0)

        // Update the scale of the progress bar
        progressBar.xScale = newScale

        // Reposition the progress bar to align with the background
        let filledWidth = barWidth * newScale
        progressBar.position = CGPoint(x: -barWidth / 2 + filledWidth / 2, y: 0)

        // Change color based on progress (example logic)
//        if newScale < 0.5 {
//            changeProgressBarColor(to: .red) // Red for less progress
//        } else if newScale < 0.75 {
//            changeProgressBarColor(to: .yellow) // Yellow for moderate progress
//        } else {
//            changeProgressBarColor(to: .green) // Green for high progress
//        }

        // If the bar reaches max scale, trigger the power-up
        if newScale >= 1.0 {
            print("Power-up triggered!")
            progressBar.xScale = 0.0
            progressBar.position = CGPoint(x: -barWidth / 2, y: 0)
            linesCleared = 0
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
    func updatePowerupVisuals() {
        for i in 0..<4 {
            if let placeholder = childNode(withName: "powerupPlaceholder\(i)") as? SKShapeNode,
               let powerupIcon = placeholder.childNode(withName: "powerupIcon") as? SKSpriteNode {

                // Skip greying out visuals for undo since it is instant
                if activePowerup == .undo {
                    continue
                }

                if let activePowerupIcon = activePowerupIcon, activePowerupIcon == powerupIcon {
                    highlightPowerupIcon(powerupIcon) // Highlight the active icon
                } else {
                    powerupIcon.run(SKAction.group([
                        SKAction.fadeAlpha(to: 0.3, duration: 0.2),
                        SKAction.colorize(with: .gray, colorBlendFactor: 0.7, duration: 0.2)
                    ]))
                }
            }
        }
    }



    func resetPowerupVisuals() {
        for i in 0..<4 {
            if let placeholder = childNode(withName: "powerupPlaceholder\(i)") as? SKShapeNode,
               let powerupIcon = placeholder.childNode(withName: "powerupIcon") as? SKSpriteNode {
                
                // Reset the alpha and remove colorization
                powerupIcon.run(SKAction.group([
                    SKAction.fadeAlpha(to: 1.0, duration: 0.2),
                    SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.2)
                ]))
            }
        }
    }

    func startPowerupShuffle(in placeholder: SKShapeNode) {
        // Remove existing icons (e.g., question mark)
        placeholder.removeAllChildren()
        
        // Create an SKSpriteNode to display the power-up icon
        let powerupIcon = SKSpriteNode()
        powerupIcon.size = CGSize(width: 60, height: 60)
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
            
            // Hide the placeholder's visual appearance
            placeholder.strokeColor = .clear
            placeholder.fillColor = .clear
            
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
            
            // Restore the placeholder's visual appearance
            placeholder.strokeColor = UIColor.white.withAlphaComponent(0.3) // Original stroke color
            placeholder.fillColor = .clear // Original fill color (transparent)
            
            // Add the question mark icon back
            let questionIcon = SKSpriteNode(imageNamed: "questioni.png")
            questionIcon.size = CGSize(width: 40, height: 40) // Adjust size as needed
            questionIcon.position = CGPoint.zero // Center within the placeholder
            questionIcon.name = "questionIcon\(index)"
            placeholder.addChild(questionIcon)
        }
    }

    func highlightPowerupIcon(_ icon: SKSpriteNode) {
        icon.run(SKAction.group([
            SKAction.fadeAlpha(to: 1.0, duration: 0.2), // Ensure fully visible
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.2), // Remove any grey overlay
            SKAction.scale(to: 1.2, duration: 0.2) // Slightly enlarge the icon
        ]))
    }

    
   func removeHighlightFromPowerupIcon(_ icon: SKSpriteNode) {
    let removeGlow = SKAction.group([
        SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.2),
        SKAction.scale(to: 1.0, duration: 0.2), // Reset the scale to its original size
        SKAction.fadeAlpha(to: 1.0, duration: 0.2) // Ensure the icon is fully opaque
    ])
    icon.run(removeGlow)
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

    // Update layoutInfo with the actual view size first
    self.layoutInfo = BLayoutInfo(screenSize: view.bounds.size)

    // Debug prints to verify the correct values
    print("View Size: \(view.bounds.size)")
    print("Screen Size: \(layoutInfo.screenSize)")
    print("Grid Size: \(layoutInfo.gridSize)")
    print("Initial Scale: \(layoutInfo.initialScale)")
    print("Grid Origin: \(layoutInfo.gridOrigin)")

    // Create grid and other UI elements
    createGrid()
    addScoreLabel()
    createPowerupPlaceholders()
    createProgressBar()
    spawnNewBlocks()
    setupGridHighlights()

    // Play background music
    if let url = Bundle.main.url(forResource: "New", withExtension: "mp3") {
        backgroundMusic = SKAudioNode(url: url)
        if let backgroundMusic = backgroundMusic {
            backgroundMusic.autoplayLooped = true
            addChild(backgroundMusic)

            // Lower the volume to 20% (0.2 out of 1.0)
            backgroundMusic.run(SKAction.changeVolume(to: 0.2, duration: 0))
        }
    } else {
        print("Error: Background music file not found.")
    }
}


    
func getGridOrigin() -> CGPoint {
    // Use layoutInfo to get grid size and tile size
    let totalGridWidth = CGFloat(layoutInfo.gridSize) * layoutInfo.tileSize
    let totalGridHeight = CGFloat(layoutInfo.gridSize) * layoutInfo.tileSize

    // Center horizontally
    let gridOriginX = (size.width - totalGridWidth) / 2

    // Adjust the vertical positioning based on layoutInfo percentages
    var topMargin: CGFloat
    var bottomMargin: CGFloat
    var additionalOffset: CGFloat
    
    // Adjust for different screen sizes
    if layoutInfo.screenSize.height <= 667 {  // SE (smaller screen)
        topMargin = layoutInfo.screenSize.height * 0.15 // 10% for SE
        bottomMargin = layoutInfo.screenSize.height * 0.20 // 20% for SE
        additionalOffset = 70 // Shift grid down on SE
    } else if layoutInfo.screenSize.height <= 844 {  // Pro (6.1-inch)
        topMargin = layoutInfo.screenSize.height * 0.10 // 10% for Pro
        bottomMargin = layoutInfo.screenSize.height * 0.15 // 15% for Pro
        additionalOffset = 10 // Smaller offset for Pro
    } else {  // Pro Max (6.7-inch)
        topMargin = layoutInfo.screenSize.height * 0.35 // 8% for Pro Max
        bottomMargin = layoutInfo.screenSize.height * 0.12 // 12% for Pro Max
        additionalOffset = 10 // Smaller offset for Pro Max
    }

    // Calculate the vertical grid origin
    let gridOriginY = (size.height - totalGridHeight - topMargin - bottomMargin) / 2 + topMargin + additionalOffset

    // Return the grid origin point, ensuring it's not too high
    return CGPoint(x: gridOriginX, y: max(gridOriginY, topMargin)) // Ensure grid doesn't go too high
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
    let scoreContainer = SKShapeNode(rectOf: CGSize(width: 100, height: 50), cornerRadius: 25)
    scoreContainer.fillColor = .lightGray
    scoreContainer.strokeColor = .clear
    
    // Position the score container based on device screen size
    var topMargin: CGFloat
    var verticalPosition: CGFloat

    // Adjust for different screen sizes
    if layoutInfo.screenSize.height <= 667 {  // SE (smaller screen)
        topMargin = layoutInfo.screenSize.height * 0.08 // 10% for SE
        verticalPosition = topMargin + 10 // Adjust position for SE, slightly lower
    } else if layoutInfo.screenSize.height <= 844 {  // Pro (6.1-inch)
        topMargin = layoutInfo.screenSize.height * 0.10 // 10% for Pro
        verticalPosition = topMargin + 40 // Adjust position for Pro
    } else {  // Pro Max (6.7-inch)
        topMargin = layoutInfo.screenSize.height * 0.08 // 8% for Pro Max
        verticalPosition = topMargin + 40 // Slightly higher for Pro Max
    }

    // Set the position of the score container
    scoreContainer.position = CGPoint(x: size.width / 2, y: size.height - verticalPosition)
    scoreContainer.name = "scoreContainer"

    // Add the score label inside the container
    let scoreLabel = SKLabelNode(text: "\(score)")
    scoreLabel.fontSize = 24
    scoreLabel.fontColor = .black
    scoreLabel.fontName = "Helvetica-Bold"
    scoreLabel.verticalAlignmentMode = .center
    scoreLabel.position = CGPoint.zero
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
    // Create the X image sprite using SKSpriteNode
    let xNode = SKSpriteNode(imageNamed: "X") // Replace "X" with the name of your image asset
    xNode.zPosition = 10 // Ensure it's on top of the grid
    xNode.alpha = 0.0    // Start fully transparent

    // Get the grid dimensions
    let gridWidth = CGFloat(gridSize) * tileSize
    let gridHeight = CGFloat(gridSize) * tileSize

    // Set the X node size to a smaller value, e.g., 60% of the grid's size
    let xNodeWidth = gridWidth * 0.4
    let xNodeHeight = gridHeight * 0.4
    xNode.size = CGSize(width: xNodeWidth, height: xNodeHeight)

    // Get the origin of the grid
    let gridOrigin = getGridOrigin()

    // Calculate the final position at the center of the grid
    let finalPosition = CGPoint(
        x: gridOrigin.x + gridWidth / 2, 
        y: gridOrigin.y + gridHeight / 2 
    )

    // Position the X node directly in the center of the grid
    xNode.position = finalPosition
    addChild(xNode)

    // Fade actions for the blocks
    let fadeActions = nodes.map { node -> SKAction in
        if let spriteNode = node.children.first as? SKSpriteNode {
            return SKAction.sequence([
                SKAction.group([
                    SKAction.fadeAlpha(to: 0.8, duration: 0.1),  // Fade the alpha to 0.8 to reduce opacity, not fully transparent
                    SKAction.colorize(with: UIColor(white: 0.5, alpha: 1.0), colorBlendFactor: 1.0, duration: 0.1) // Grey out completely
                ]),
                SKAction.run {
                    spriteNode.color = UIColor(white: 0.5, alpha: 1.0)  // Set to full grey (no original color showing)
                    spriteNode.colorBlendFactor = 1.0  // Ensure full grey color
                }
            ])
        }
        return SKAction()
    }

    // Create a fade-to-black effect using SKSpriteNode
    let fadeToBlack = SKSpriteNode(color: .black, size: CGSize(width: self.size.width, height: self.size.height))
    fadeToBlack.zPosition = 20
    fadeToBlack.alpha = 0.0
    fadeToBlack.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
    addChild(fadeToBlack)

    // Instant fade-to-black effect (no duration)
    let fadeScreenAction = SKAction.fadeAlpha(to: 1.0, duration: 0.0)

    // Run the actions
    let animationGroup = SKAction.group(fadeActions)
    let sequence = SKAction.sequence([
        animationGroup,
        SKAction.wait(forDuration: 0.5), // Wait for the block fade out to complete
        SKAction.wait(forDuration: 0.5), // Add a delay before fade to black (adjust as needed)
        SKAction.run {
            fadeToBlack.run(fadeScreenAction)
        },
        SKAction.run(completion)
    ])

    for node in nodes {
        node.run(sequence)
    }
    
    // Fade-in the X node in the center of the grid with ease-in effect
  let fadeInAction = SKAction.fadeAlpha(to: 1.0, duration: 0.015) // Fade-in duration for "X"

    // Apply ease-in timing mode to the fade-in action
    fadeInAction.timingMode = .easeIn

let waitAction = SKAction.wait(forDuration: 1.0) // Wait for 1 second after the fade-in

// Sequence: Perform fade-in with ease-in effect, then wait for 1 second
let fadeInSequence = SKAction.sequence([fadeInAction, waitAction])

// Run the sequence on the X node
xNode.run(fadeInSequence)

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
        layoutSpawnedBlocks(isThreeNewBlocks: true) // Only call here after new blocks are added

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

func layoutSpawnedBlocks(isThreeNewBlocks: Bool) {
    guard boxNodes.count > 0 else { return }

    let scaledTileSize = tileSize * 0.6  // Adjust scale to make blocks visually smaller

    // Define X positions for the three blocks: 1/4, 1/2, 3/4 of screen width
    let xPositions: [CGFloat] = [
        size.width * 0.2,
        size.width * 0.5,
        size.width * 0.8
    ]

    // Conditional Y position adjustment based on screen height
    let blockYPosition: CGFloat
    if size.height <= 667 { // iPhone SE screen height (667 points)
        blockYPosition = size.height * 0.25 // Lower Y position for smaller devices like SE
    } else {
        blockYPosition = size.height * 0.3 // Default Y position for Pro and Pro Max
    }

    if isThreeNewBlocks {
        for (index, block) in boxNodes.enumerated() {
            block.position.x = xPositions[index]
        }
    }

    var positionInfo = [-1, -1, -1]
    for (index, block) in boxNodes.enumerated() {
        if block.position.x < size.width * 0.35 {
            positionInfo[0] = index
        } else if block.position.x < size.width * 0.65 {
            positionInfo[1] = index
        } else {
            positionInfo[2] = index
        }
    }

    for (index, blockIndex) in positionInfo.enumerated() {
        if blockIndex == -1 { continue }

        let block = boxNodes[blockIndex]

        // Calculate block's height based on its grid height and scaled tile size
        let blockHeight = CGFloat(block.gridHeight) * scaledTileSize
        let blockWidth = CGFloat(block.gridWidth) * scaledTileSize

        let xPosition = xPositions[index] - (blockWidth / 2)

        // Center the block vertically on blockYPosition
        let yPosition = blockYPosition - (blockHeight / 2)

        // Update block's position
        block.position = CGPoint(x: xPosition, y: yPosition)
        block.initialPosition = block.position
        block.gameScene = self

        // Set scale and add block to the scene
        block.setScale(0.6)  // Adjust as needed

        safeAddBlock(block)
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
        if activePowerup == .undo {
               // Skip resetting visuals or highlights for undo since it is instant
               activePowerup = nil
               activePowerupIcon = nil
               return
           }
        if let activeIcon = activePowerupIcon {
            removeHighlightFromPowerupIcon(activeIcon)
            activePowerupIcon = nil
        }
        activePowerup = nil
        
        // Reset block highlights when the power-up is deactivated
        resetBlockHighlights()
        stopDeletePowerupVibrations()
        // Additional cleanup for specific power-ups
        removeMultiplierLabel() // Ensure multiplier label is removed if applicable
        
        resetGridVisuals()
        resetPowerupVisuals()
        // Reset visuals of spawned blocks
        for blockNode in boxNodes {
            blockNode.removeAllActions()
            blockNode.run(SKAction.group([
                SKAction.fadeAlpha(to: 1.0, duration: 0.2),
                SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.2)
            ]))
        }
    }


var placedBlocksCount = 0

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

        // Original code to add sparkle effect
        addSparkleEffect(around: cellNodes)
        placedBlocksCount += 1

        // Remove the block from the spawn area
        if let index = boxNodes.firstIndex(of: block) {
            boxNodes.remove(at: index)
        }
        block.removeFromParent()

        // Check for completed lines
        let clearedLines = checkForCompletedLines()
        let totalLinesCleared = clearedLines.count
        let totalPoints = totalLinesCleared * 10

        if totalLinesCleared > 0 {
            let feedbackGenerator = UINotificationFeedbackGenerator()
            feedbackGenerator.prepare()
            feedbackGenerator.notificationOccurred(.success)

            let blockCenter = centroidOfBlockCells(cellNodes)
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
            layoutSpawnedBlocks(isThreeNewBlocks: true)
            isUndoInProgress = false
        } else if boxNodes.isEmpty {
            spawnNewBlocks()
        } else if !checkForPossibleMoves(for: boxNodes) {
            // Create a sequence to play the sparkle effect first, then check for game-over
            let sparkleAction = SKAction.run {
                self.addSparkleEffect(around: cellNodes)
            }

            let waitForSparkle = SKAction.wait(forDuration: 0.2) // Reduced wait time

            let gameOverCheckAction = SKAction.run {
                if !self.checkForPossibleMoves(for: self.boxNodes) {
                    let gridNodes = self.placedBlocks.flatMap { $0.cellNodes }
                    let fadeDuration: TimeInterval = 0.015

                    // Create a non-blocking vibration sequence
                   let vibrationActions = (0..<10).map { index in
                let style: UIImpactFeedbackGenerator.FeedbackStyle
                
                // Alternate between light, medium, and heavy impacts to simulate symphony
                switch index % 3 {
                case 0:
                    style = .heavy // Use light feedback for a soft impact
                case 1:
                    style = .heavy// Use medium feedback for a moderate impact
                default:
                    style = .heavy // Use heavy feedback for a strong impact
                }
    
    return SKAction.sequence([
        SKAction.run {
            // Create a new haptic feedback generator for each impact
            let feedbackGenerator = UIImpactFeedbackGenerator(style: style)
            feedbackGenerator.prepare() // Prepare for quick feedback
            feedbackGenerator.impactOccurred() // Trigger the haptic feedback
        },
       SKAction.wait(forDuration: Double.random(in: 0.05...0.2)) // Slightly wider range for a varied rhythm
 
    ])
}

                    let vibrationSequence = SKAction.sequence(vibrationActions)

                    // Run vibration and fade in parallel
                    self.run(SKAction.group([
                        vibrationSequence,
                        SKAction.run {
                        self.fadeBlocksToGrey(gridNodes) {
                                self.showGameOverScreen()
                            }

                        }
                    ]))

                    // Play game over sound
                    if let gameOverSoundURL = Bundle.main.url(forResource: "Muted", withExtension: "mp3") {
                        do {
                            self.gameOverSoundPlayer = try AVAudioPlayer(contentsOf: gameOverSoundURL)
                            self.gameOverSoundPlayer?.volume = 0.2
                            self.gameOverSoundPlayer?.prepareToPlay()
                            self.gameOverSoundPlayer?.play()
                        } catch {
                            print("Error loading sound file: \(error.localizedDescription)")
                        }
                    }
                }
            }

            self.run(SKAction.sequence([sparkleAction, waitForSparkle, gameOverCheckAction]))
        }

        if occupiedCells > 0 {
            let feedbackGenerator = UISelectionFeedbackGenerator()
            feedbackGenerator.selectionChanged()
        }

        run(SKAction.playSoundFileNamed("download.mp3", waitForCompletion: false))
    } else {
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
//        let sparkleCount = 8 // Adjust the number of sparkles around each cell
//        let edgeOffset: CGFloat = tileSize / 2.5  // Adjust how far from the edges the sparkles appear
//
//        for _ in 0..<sparkleCount {
//            // Create a small circle for the sparkle
//            let sparkleTexture = SKTexture(imageNamed: "b_twinkle")
//            let sparkle = SKSpriteNode(texture: sparkleTexture, size: sparkleTexture.size())  // Smaller sparkles
////            let sparkle = SKShapeNode(circleOfRadius: 3)  // Smaller sparkles
////            sparkle.fillColor = .white
//            sparkle.setScale(0.3)
//            sparkle.alpha = 0.4  // Slightly transparent for subtle effect
//
//            // Randomize the position around the edges of the cell node
//            let randomAngle = CGFloat.random(in: 0..<2 * .pi)
//            let randomRadius = CGFloat.random(in: edgeOffset...tileSize / 2)
//            let randomXOffset = randomRadius * cos(randomAngle)
//            let randomYOffset = randomRadius * sin(randomAngle)
//
//            sparkle.position = CGPoint(x: cellNode.position.x + randomXOffset, y: cellNode.position.y + randomYOffset)
//
//            addChild(sparkle)
//
//            // Animate the sparkle (scale up, fade out, and move)
//            let scaleUpAction = SKAction.scale(to: 0.4, duration: 0.2)
////            let scaleUpAction = SKAction.scale(to: 1.2, duration: 0.2)
//            let fadeOutAction = SKAction.fadeOut(withDuration: 0.4)
//            let moveAction = SKAction.moveBy(x: randomXOffset * 0.3, y: randomYOffset * 0.3, duration: 0.4)
//
//            // Combine the actions (scale up, fade out, move)
//            let sparkleAnimation = SKAction.group([scaleUpAction, fadeOutAction, moveAction])
//
//            // Run the animation on the sparkle node
//            sparkle.run(sparkleAnimation) {
//                sparkle.removeFromParent() // Remove the sparkle after animation completes
//            }
//        }
        
        var twinkleNodes: [SKSpriteNode] = []
        let twinkleTexture = SKTexture(imageNamed: "b_twinkle")

        for index in 0..<3 {
            let twinkleNode = SKSpriteNode(texture: twinkleTexture)
            twinkleNode.alpha = 0.0
            twinkleNode.zPosition = 15
            twinkleNode.setScale(0.4)

            let randomX = CGFloat.random(in: -self.tileSize/2...self.tileSize/2)
            let randomY = CGFloat.random(in: -self.tileSize/2...self.tileSize/2)
            twinkleNode.position = CGPoint(x: cellNode.position.x + randomX, y: cellNode.position.y + randomY)

            self.addChild(twinkleNode)
            twinkleNodes.append(twinkleNode)
        }
        twinkleNodes.shuffle()

        let fadeIn = SKAction.fadeAlpha(to: 0.4, duration: 0.1)
        let wait = SKAction.wait(forDuration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let baseSequence = SKAction.sequence([fadeIn, wait, fadeOut])

        let dispatchGroup = DispatchGroup()

        for twinkleNode in twinkleNodes {
            dispatchGroup.enter()
            
            // Generate a random delay between 0 and 0.5 seconds (adjust as needed)
            let randomDelay = Double.random(in: 0.0...0.2)
            let delayAction = SKAction.wait(forDuration: randomDelay)
            
            // Create a new sequence with the delay followed by the base sequence
            let delayedSequence = SKAction.sequence([delayAction, baseSequence])
            
            twinkleNode.run(delayedSequence) {
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            for twinkleNode in twinkleNodes {
                twinkleNode.removeFromParent()
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
        if placedBlocksCount >= 3 && isBoardCleared() {
               awardBonusPoints()
           }
        
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
    var points: Double = Double(totalPoints * currentCombo) // points as a Double to handle multipliers
    
    // Apply multiplier power-up if active
    if activePowerup == .multiplier {
        points *= 1.5  // Apply multiplier (e.g., 1.5x)

        // Find the placeholder index of the active power-up and reset it
        if let placeholder = activePowerupIcon?.parent as? SKShapeNode,
           let index = placeholderIndex(for: placeholder) {
            resetPlaceholder(at: index)
        }
        deactivateActivePowerup()
    }
    
    // Update score by casting points to Int
    score += Int(points) // Convert points (Double) to Int and add it to score
    updateScoreLabel()
    
    // Display combo animation if combo multiplier is greater than 1
    if currentCombo > 1 {
        displayComboAnimation(for: currentCombo)
    }
    
    // Display animated points at the block placement position
    displayAnimatedPoints(Int(points), at: displayPosition)
    
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
    let comboLabelYPosition = frame.midY + 300  // Position below screen
    
    let comboLabel = SKLabelNode(text: "COMBO x\(multiplier)")
    //comboLabel.fontSize = min(70, frame.width * 0.1)  // Adjust font size based on screen width
    comboLabel.fontSize = min(40, frame.width * 0.08) // Reduced font size (adjust further as needed)
    comboLabel.fontColor = .white
    comboLabel.fontName = "Arial-BoldMT"
    comboLabel.position = CGPoint(x: frame.midX, y: comboLabelYPosition)
    
        // Create shadow by adding another label
    let shadowComboLabel = createShadowedLabel(text: "COMBO x\(multiplier)", position: comboLabel.position, fontSize: comboLabel.fontSize)
    addChild(shadowComboLabel)
    
    addChild(comboLabel)  // Add combo label to the scene
        
    
    
        // Animation sequence (scale up, bounce, fade out)
    let scaleUp = SKAction.scale(to: 1.5, duration: 0.5)  // Increased to 0.5 seconds
    
let bounce = SKAction.sequence([
    SKAction.moveBy(x: 0, y: 80, duration: 0.2),  // Move up 80 pixels
SKAction.moveBy(x: 0, y: -10, duration: 0.2),  // Minor downward movement
SKAction.moveBy(x: 0, y: 10, duration: 0.2)   // Minor upward movement
])
    let fadeOut = SKAction.fadeOut(withDuration: 0.5)   // Increased to 0.5 seconds
        let remove = SKAction.removeFromParent()
    let delay = SKAction.wait(forDuration: 0.2)
    let comboAnimation = SKAction.sequence([delay, scaleUp, bounce, fadeOut, remove])
    
    
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

    // Show multiplier effect if the power-up is active
    if activePowerup == .multiplier {
        let rowCenterY = gridToScreenPosition(row: row, col: gridSize / 2).y
        showMultiplierEffect(at: CGPoint(x: size.width / 2, y: rowCenterY), orientation: "horizontal")
    }

   run(SKAction.playSoundFileNamed("clearedlines.wav", waitForCompletion: false))

    return clearedCells
}


func clearColumn(_ col: Int) -> [(row: Int, col: Int, cellNode: SKShapeNode)] {
    var clearedCells: [(row: Int, col: Int, cellNode: SKShapeNode)] = []
    var clearedRows: [Int] = []

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
            clearedRows.append(row)

            cellNode.userData?["originalPosition"] = originalPosition
        }
    }

    // Show multiplier effect if the power-up is active
    if activePowerup == .multiplier, !clearedRows.isEmpty {
        let minRow = clearedRows.min()!
        let maxRow = clearedRows.max()!
        let midRow = (minRow + maxRow) / 2
        let colCenterX = gridToScreenPosition(row: midRow, col: col).x
        let colCenterY = gridToScreenPosition(row: midRow, col: col).y

        showMultiplierEffect(at: CGPoint(x: colCenterX, y: colCenterY), orientation: "vertical")
    }

    // Use AVAudioPlayer for custom volume control
   run(SKAction.playSoundFileNamed("clearedlines.wav", waitForCompletion: false))

    return clearedCells
}



func showMultiplierEffect(at position: CGPoint, orientation: String) {
    let numberOfStars = 5
    let starSpacing: CGFloat = 20

    // Load the star image
    let starImage = SKTexture(imageNamed: "multiplier3") // Replace with your image name

    for i in 0..<numberOfStars {
        // Create a sprite node with the star image
        let starNode = SKSpriteNode(texture: starImage)
        starNode.size = CGSize(width: 60, height: 60) // Adjust the size of the star

        // Set the position based on the orientation
        if orientation == "vertical" {
            starNode.position = CGPoint(
                x: position.x,
                y: position.y + CGFloat(i) * starSpacing - CGFloat(numberOfStars - 1) * starSpacing / 2
            )
        } else {
            starNode.position = CGPoint(
                x: position.x + CGFloat(i) * starSpacing - CGFloat(numberOfStars - 1) * starSpacing / 2,
                y: position.y
            )
        }

        starNode.zPosition = 100
        starNode.alpha = 0.0

        addChild(starNode)

        // Make the fade-in, fade-out, and delay faster
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)    // Reduced from 0.5 to 0.3
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)  // Reduced from 0.5 to 0.3
        let delay = SKAction.wait(forDuration: Double(i) * 0.1) // Reduced delay between stars

        let sequence = SKAction.sequence([delay, fadeIn, fadeOut, SKAction.removeFromParent()])
        starNode.run(sequence)
    }
}



func showGameOverScreen() {
    isGameOver = true
    
    // Stop any ongoing animations and actions
    self.enumerateChildNodes(withName: "*") { node, _ in
        node.removeAllActions() // Stop any ongoing actions
        if let spriteNode = node as? SKSpriteNode {
            spriteNode.removeAllActions() // Ensure sprite nodes don't have any actions
        }
    }
    
    // Remove all nodes except those related to the game over screen
    self.enumerateChildNodes(withName: "*") { node, _ in
        if node.name != "gameOverUI" && node.name != "restartButton" {
            node.removeFromParent()
        }
    }
    
    // Stop background music immediately
    backgroundMusic?.removeFromParent()
    backgroundMusic = nil
    
 // Set the background color to black
    self.backgroundColor = UIColor.black

    // Create the red Game Over banner (bottom layer)
    let redBanner = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.2))
    redBanner.strokeColor = .black // Set stroke color to black
    redBanner.fillColor = UIColor(red: 243.0 / 255.0, green: 80.0 / 255.0, blue: 76.0 / 255.0, alpha: 1.0) // Hex #F3504C converted
    redBanner.position = CGPoint(x: size.width / 2, y: size.height / 2)
    redBanner.zPosition = 11
    redBanner.name = "gameOverUI" // For cleanup
    addChild(redBanner)
    
    
    // Create the dark gray banner (top layer)
    let grayBanner = SKShapeNode(rectOf: CGSize(width: size.width * 0.9, height: size.height * 0.18)) // Slightly smaller than red banner
    grayBanner.strokeColor = .black // Set stroke color to black
    grayBanner.fillColor = .black // Black
    grayBanner.position = CGPoint(x: size.width / 2, y: size.height * 0.8) // Position the gray banner where the score label was
    grayBanner.zPosition = 12 // Place above the red banner
    grayBanner.name = "gameOverUI" // For cleanup
    addChild(grayBanner)

    // Create the "Game Over" label within the gray banner
    let gameOverLabel = SKLabelNode(text: "Game Over")
    gameOverLabel.fontSize = 36 // Adjust font size as needed
    gameOverLabel.fontColor = UIColor.white
    gameOverLabel.fontName = "HelveticaNeue-Bold"
    gameOverLabel.position = CGPoint(x: 0, y: 0) // Position relative to the banner's center
    gameOverLabel.horizontalAlignmentMode = .center
    gameOverLabel.verticalAlignmentMode = .center
    grayBanner.addChild(gameOverLabel)
    
    
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
    
  // Final score label (positioned below "Game Over" label)
    let finalScoreLabel = SKLabelNode(text: "Score: \(score)")
    finalScoreLabel.fontSize = 36
    finalScoreLabel.fontColor = UIColor.white
    finalScoreLabel.fontName = "HelveticaNeue-Bold"
    finalScoreLabel.position = CGPoint(x: 0, y: -(grayBanner.frame.height / 4)) // Position slightly below the center of the banner // Position slightly below the center
    finalScoreLabel.horizontalAlignmentMode = .center
    finalScoreLabel.verticalAlignmentMode = .center
    grayBanner.addChild(finalScoreLabel)
    
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
    restartLabel.position = CGPoint(x: 0, y: 0) // Position relative to the banner's center
    restartLabel.horizontalAlignmentMode = .center
    restartLabel.verticalAlignmentMode = .center
    restartLabel.name = "restartButton" // For touch detection
    restartButton.addChild(restartLabel)
    
    // Disable all further animations in the scene (ensure nothing happens)
    self.isPaused = true
}


    
func restartGame() {
    // Unpause the scene before re-initializing.
    self.isPaused = false

    print("Restarting game...")

  // Stop and remove the game-over sound player
   // Stop the game-over sound if it's playing
   if let gameOverSoundPlayer = gameOverSoundPlayer {
    gameOverSoundPlayer.stop() // Stop the audio playback
    self.gameOverSoundPlayer = nil // Dereference the player if you no longer need it
}


   self.backgroundColor = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1.0)
    
    score = 0
    updateScoreLabel()

    // Reset the grid and remove all children
    grid = Array(repeating: Array(repeating: nil, count: gridSize), count: gridSize)
    removeAllChildren()

    isGameOver = false
    placedBlocks.removeAll()
    undoStack.removeAll()

    // Reset power-up state
    activePowerup = nil
    activePowerupIcon = nil
    linesCleared = 0

    // Re-add game elements
    createGrid()
    addScoreLabel()
    createPowerupPlaceholders() // Recreate placeholders with default state
    createProgressBar()
    spawnNewBlocks()
    setupGridHighlights()

    // Restart background music
    if let url = Bundle.main.url(forResource: "New", withExtension: "mp3") {
        backgroundMusic = SKAudioNode(url: url)
        if let backgroundMusic = backgroundMusic {
            backgroundMusic.autoplayLooped = true
            backgroundMusic.run(SKAction.changeVolume(to: currentVolume, duration: 0))
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
    
func showMultiplierLabel() {
  // Create an SKSpriteNode for the multiplier image
  let multiplierImage = SKSpriteNode(imageNamed: "multiplier2.png") // Replace with your image name
  multiplierImage.size = CGSize(width: 50, height: 50) // Adjust size as needed
  multiplierImage.position = CGPoint(x: size.width / 2 + 40, y: size.height - 115) // Position next to the score container
  multiplierImage.alpha = 0 // Initially hidden
  multiplierImage.name = "multiplierLabel" // Set the name for identification (optional)

  // Add the image to the scene
  addChild(multiplierImage)

  // Animate the image's appearance with a smooth fade-in
  let fadeIn = SKAction.fadeIn(withDuration: 0.5)
  let scaleIn = SKAction.scale(to: 1.0, duration: 0.5)
  multiplierImage.run(SKAction.group([fadeIn, scaleIn]))

  // Gentle shimmer effect (optional)
  /*
  let shimmer = SKAction.sequence([
    SKAction.fadeAlpha(to: 0.8, duration: 0.8),
    SKAction.fadeAlpha(to: 1.0, duration: 0.8)
  ])
  let repeatShimmer = SKAction.repeatForever(shimmer)
  multiplierImage.run(repeatShimmer)
  */

  // Create a pulse action with desired duration and scale
  let pulseUp = SKAction.scale(to: 1.1, duration: 0.5)
  let pulseDown = SKAction.scale(to: 1.0, duration: 0.5)
  let pulse = SKAction.sequence([pulseUp, pulseDown])
  let repeatPulse = SKAction.repeatForever(pulse)

  // Run the pulse animation after a slight delay
  let delay = SKAction.wait(forDuration: 0.5) // Adjust delay if needed
  let pulseSequence = SKAction.sequence([delay, repeatPulse])
  multiplierImage.run(pulseSequence)
}


func removeMultiplierLabel() {
  if let multiplierLabel = childNode(withName: "multiplierLabel") as? SKSpriteNode {
    // Animate label disappearance (fade out and scale down) - adjust for SpriteNode
    let fadeOut = SKAction.fadeOut(withDuration: 0.3)
    // Scale actions are optional, adjust as needed
    let scaleDown = SKAction.scale(to: 0.5, duration: 0.3)
    
    let removeAction = SKAction.sequence([SKAction.group([fadeOut, scaleDown]), SKAction.removeFromParent()])
    multiplierLabel.run(removeAction)
  }
}


    var deletePowerupVibrationTimer: Timer? // Keep a reference to the timer

    func startDeletePowerupVibrations() {
        // Start a repeating timer for vibrations
        deletePowerupVibrationTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }
    }

    func stopDeletePowerupVibrations() {
        deletePowerupVibrationTimer?.invalidate()
        deletePowerupVibrationTimer = nil
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
        
         // Play haptic feedback for power-up tap
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.impactOccurred()

        // Check if tapped power-up is in the placeholder
        if let placeholder = powerupIcon.parent as? SKShapeNode,
           placeholder.name == "powerupPlaceholder0" ||
               placeholder.name == "powerupPlaceholder1" ||
               placeholder.name == "powerupPlaceholder2" ||
               placeholder.name == "powerupPlaceholder3"{ // Assuming the placeholder name is correct

            print("Power-up icon tapped in placeholder!")
            print("Placeholder name: \(placeholder.name)")
            print("Power-up icon name: \(powerupIcon.name)")

            // Play sound effect
            if let url = Bundle.main.url(forResource: "first", withExtension: "mp3") {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.prepareToPlay()
                    audioPlayer?.play()
                    audioPlayer?.volume = 0.2 // Adjust the volume (0.0 to 1.0)
                    print("Sound effect played")
                } catch {
                    print("Error: Unable to play sound - \(error)")
                }
            } else {
                print("Error: Audio file not found.")
            }

            // ... rest of power-up handling logic ...
        } else {
            print("Power-up icon tapped outside placeholder: \(nodeTapped.name)")
            print("Parent node: \(nodeTapped.parent?.name ?? "No parent")")
        }


        // ... rest of power-up handling logic ...
        if let currentActivePowerupIcon = activePowerupIcon {
            if currentActivePowerupIcon == powerupIcon {
                // Tapped on the active power-up icon, so deactivate it
                deactivateActivePowerup()
                if powerupType == .multiplier {
                    removeMultiplierLabel() // Hide multiplier animation when deactivated
                }
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
            updatePowerupVisuals()

           if powerupType == .undo {
    if let placeholder = powerupIcon.parent as? SKShapeNode,
       let index = placeholderIndex(for: placeholder) {
        
        // Play sound effect when undo power-up is activated
        if let url = Bundle.main.url(forResource: "reverse", withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                audioPlayer?.volume = 0.2 // Adjust the volume
                print("Undo power-up sound effect played")
            } catch {
                print("Error: Unable to play undo sound - \(error)")
            }
        } else {
            print("Error: Undo sound audio file not found.")
        }

        undoLastMove()
        resetPlaceholder(at: index)
    }
    deactivateActivePowerup()
}
else if powerupType == .multiplier {
                showMultiplierLabel()
            } else if powerupType == .delete {
                // Highlight deletable blocks when delete power-up is activated
                updateDeletableBlockHighlights()
                startDeletePowerupVibrations()
            }
            else if powerupType == .swap {
                            blurGridBlocks()
                startDeletePowerupVibrations()
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
                    if let placeholder = activePowerupIcon?.parent as? SKShapeNode,
                       let index = placeholderIndex(for: placeholder) {
                        resetPlaceholder(at: index)
                    }
                    deactivateActivePowerup()
                } else {
                    print("Block could not be deleted because it wasn't full. Power-up remains active.")
                }
            }
            return

       case .swap:
    if let blockNode = nodeTapped.closestParent(ofType: BBoxNode.self),
       boxNodes.contains(blockNode) {
        
        // Play sound effect when a block is selected for swapping
        if let url = Bundle.main.url(forResource: "whoosh", withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                audioPlayer?.volume = 0.2 // Adjust volume
                print("Block selected for swapping sound effect played")
            } catch {
                print("Error: Unable to play sound - \(error)")
            }
        } else {
            print("Error: Audio file for block selected for swap not found.")
        }

        // Perform the block deletion and reset
        deleteBlock(blockNode)
        if let placeholder = activePowerupIcon?.parent as? SKShapeNode,
           let index = placeholderIndex(for: placeholder) {
            resetPlaceholder(at: index)
        }
        deactivateActivePowerup()
    }
    return


        case .undo:
            return

        case .multiplier:
            break
        }
    }

    // Handle block selection and dragging based on proximity
    if let blockNode = nodeTapped.closestParent(ofType: BBoxNode.self), boxNodes.contains(blockNode) {
        currentlyDraggedNode = blockNode
    } else {
        for blockNode in boxNodes {
            let distance = distanceBetweenPoints(location, blockNode.position)
            let selectionRadius: CGFloat = 100

            print("Distance from touch to block: \(distance), Selection radius: \(selectionRadius)")

            if distance < selectionRadius {
                print("Block selected: \(blockNode)")
                currentlyDraggedNode = blockNode
                break
            }
        }
    }

    if let node = currentlyDraggedNode {
        if let rotatePowerupIcon = childNode(withName: "//rotatePowerup") as? SKSpriteNode {
            rotatePowerupIcon.colorBlendFactor = 0.0
        }

        if let url = Bundle.main.url(forResource: "Soft_Pop_or_Click", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                audioPlayer?.volume = 0.2
            } catch {
                print("Error: Unable to play sound - \(error)")
            }
        } else {
            print("Error: Audio file not found.")
        }

        // Increase the size of the block when it's selected
        node.run(SKAction.scale(to: 1.0, duration: 0.1)) {
            node.removeOutline()
        }

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





    func highlightDeletableCells() {
        // Create the haptic feedback generator for vibrations
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.prepare()

        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if let cellNode = grid[row][col] {
                    if let placedBlock = cellNode.userData?["placedBlock"] as? PlacedBlock,
                       canDeleteBlock(placedBlock) {
                        cellNode.alpha = 1.0
                        cellNode.run(SKAction.colorize(with: .green, colorBlendFactor: 0.5, duration: 0.2))
                    } else {
                        cellNode.alpha = 0.3
                        cellNode.run(SKAction.colorize(with: .gray, colorBlendFactor: 1.0, duration: 0.2))
                    }
                } else {
                    grid[row][col]?.alpha = 0.3
                    grid[row][col]?.run(SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.2))
                }
            }
        }

        // Trigger a vibration every time the cells are updated
        feedbackGenerator.impactOccurred()
    }

    func resetGridVisuals() {
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if let cellNode = grid[row][col] {
                    // Reset visuals only if the cell is occupied logically
                    guard grid[row][col] != nil else { continue }
                    
                    // Reset alpha and remove colorization
                    cellNode.alpha = 1.0
                    cellNode.run(SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.2))

                    // Remove scale and animations
                    cellNode.removeAllActions()
                    cellNode.setScale(1.0)
                }
            }
        }
    }


    

    
    func addDeletionEffect(to block: PlacedBlock) {
        // Iterate over each cell node in the block
        for cellNode in block.cellNodes {
            // Create a burst effect at the cell's position
            let burstEffect = SKEmitterNode(fileNamed: "BurstEffect.sks") // Use a pre-made particle effect
            burstEffect?.position = cellNode.position
            burstEffect?.zPosition = 10 // Above the grid
            
            // Adjust particle properties (optional)
            burstEffect?.particleAlpha = 0.8
            burstEffect?.particleScale = 0.5
            burstEffect?.particleColorBlendFactor = 1.0
            
            if let burst = burstEffect {
                addChild(burst)
            }
            
            // Scale and fade out the cell node
            let scaleDown = SKAction.scale(to: 0.5, duration: 0.2)
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let remove = SKAction.run {
                cellNode.removeFromParent()
            }
            
            // Run the actions in sequence
            cellNode.run(SKAction.sequence([SKAction.group([scaleDown, fadeOut]), remove]))
        }
        
        // Play a sound effect for the deletion
        run(SKAction.playSoundFileNamed("empty trash.aif", waitForCompletion: false))
    }

    func deletePlacedBlock(_ placedBlock: PlacedBlock, updateScore: Bool = true) -> Bool {
        // Ensure all cells of the block are intact and match the grid state
        for gridPosition in placedBlock.gridPositions {
            if let cellNode = grid[gridPosition.row][gridPosition.col],
               let blockInCell = cellNode.userData?["placedBlock"] as? PlacedBlock {
                if blockInCell !== placedBlock {
                    print("Block cannot be deleted: Some cells belong to another block.")
                    return false
                }
            } else {
                print("Block cannot be deleted: Missing cells.")
                return false
            }
        }

        print("Block is intact and will be deleted.")
        
        let previousScore = score
        
        // Add the deletion effect
        addDeletionEffect(to: placedBlock)

        // Delete all cells of the block
        for gridPosition in placedBlock.gridPositions {
            grid[gridPosition.row][gridPosition.col] = nil
        }

        if let index = placedBlocks.firstIndex(where: { $0 === placedBlock }) {
            placedBlocks.remove(at: index)
        }

        if updateScore {
            score += placedBlock.gridPositions.count
            updateScoreLabel()
        }

        _ = checkForCompletedLines()
        syncPlacedBlocks()

        // Record a move for this deletion so we can undo it
        let deletionMove = Move(deletedBlock: placedBlock, previousScore: previousScore)
        undoStack.append(deletionMove)

        // Handle game-over conditions
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
    func highlightSwapPowerupIcon(_ icon: SKSpriteNode) {
            let pulseUp = SKAction.scale(to: 1.3, duration: 0.5)
            let pulseDown = SKAction.scale(to: 1.0, duration: 0.5)
            let pulseSequence = SKAction.sequence([pulseUp, pulseDown])
            icon.run(SKAction.repeatForever(pulseSequence), withKey: "swapPulse")
        }

        func removeHighlightFromSwapPowerupIcon(_ icon: SKSpriteNode) {
            icon.removeAction(forKey: "swapPulse")
            icon.run(SKAction.scale(to: 1.0, duration: 0.2)) // Reset to original size
        }
        func blurGridBlocks(excludeSpawnedBlocks: Bool = true) {
            for row in 0..<gridSize {
                for col in 0..<gridSize {
                    if let cellNode = grid[row][col] {
                        // Dim out all grid blocks
                        cellNode.alpha = 0.3
                        cellNode.run(SKAction.colorize(with: .gray, colorBlendFactor: 0.5, duration: 0.2))
                    }
                }
            }

            // Subtle pulse effect for spawned blocks
            for blockNode in boxNodes {
                blockNode.removeAllActions() // Stop existing animations
                let pulseUp = SKAction.scale(to: 0.7, duration: 0.6) // Subtle scale up
                let pulseDown = SKAction.scale(to: 0.6, duration: 0.6) // Return to original size
                let pulseSequence = SKAction.sequence([pulseUp, pulseDown])
                blockNode.run(SKAction.repeatForever(pulseSequence), withKey: "pulse")
            }
        }



        func resetGridBlur() {
            for row in 0..<gridSize {
                for col in 0..<gridSize {
                    if let cellNode = grid[row][col] {
                        cellNode.alpha = 1.0 // Reset alpha
                        cellNode.run(SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.2))
                    }
                }
            }
        }
    func isBoardCleared() -> Bool {
        for row in grid {
            for cell in row {
                if cell != nil {
                    return false
                }
            }
        }
        return true
    }
    func awardBonusPoints() {
        let bonusPoints = 250 // Random bonus between 250-300
        score += bonusPoints
        updateScoreLabel()

        // Celebration Animation
        let bonusLabel = SKLabelNode(text: "+\(bonusPoints)")
        bonusLabel.fontName = "Helvetica-Bold"
        bonusLabel.fontSize = 40
        bonusLabel.fontColor = .yellow
        bonusLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bonusLabel.zPosition = 200
        addChild(bonusLabel)

        // Animate bonus label (fade in, scale, bounce, fade out)
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.5)
        let bounce = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 50, duration: 0.3),
            SKAction.moveBy(x: 0, y: -20, duration: 0.3),
            SKAction.moveBy(x: 0, y: 20, duration: 0.3)
        ])
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let remove = SKAction.removeFromParent()
        bonusLabel.run(SKAction.sequence([fadeIn, scaleUp, bounce, fadeOut, remove]))

        // Particle Effect
        if let particleEffect = SKEmitterNode(fileNamed: "CelebrationEffect.sks") {
            particleEffect.position = CGPoint(x: size.width / 2, y: size.height / 2)
            particleEffect.zPosition = 200
            addChild(particleEffect)
            particleEffect.run(SKAction.sequence([
                SKAction.wait(forDuration: 2.0),
                SKAction.removeFromParent()
            ]))
        }

        // Play Celebration Sound
        run(SKAction.playSoundFileNamed("celebration.mp3", waitForCompletion: false))
    }

    func addSwapDeletionEffect(to blockNode: BBoxNode) {
        // Use the center of the block’s frame as the position
        let blockCenter = CGPoint(
            x: blockNode.calculateAccumulatedFrame().midX,
            y: blockNode.calculateAccumulatedFrame().midY
        )


        // Step 1: Swirl effect
        if let swirlEffect = SKEmitterNode(fileNamed: "SwapBurstEffect.sks") {
            swirlEffect.position = blockCenter
            swirlEffect.zPosition = 100
            addChild(swirlEffect)
            
            swirlEffect.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.5),
                SKAction.removeFromParent()
            ]))
        }

        // Step 2: Sparkle effects
        let sparkleTexture = SKTexture(imageNamed: "b_twinkle")
        let sparkleEmitterNode = SKNode()
        sparkleEmitterNode.position = blockCenter
        sparkleEmitterNode.zPosition = 150
        addChild(sparkleEmitterNode)

        let sparkleCount = 12
        let sparkleRadius: CGFloat = blockNode.calculateAccumulatedFrame().width / 2 + 10

        for i in 0..<sparkleCount {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(sparkleCount))
            let sparkle = SKSpriteNode(texture: sparkleTexture)
            sparkle.setScale(0.4)
            sparkle.alpha = 0.0
            sparkle.position = CGPoint(
                x: sparkleRadius * cos(angle),
                y: sparkleRadius * sin(angle)
            )
            sparkleEmitterNode.addChild(sparkle)

            // Animate sparkles
            let fadeIn = SKAction.fadeAlpha(to: 0.8, duration: 0.1)
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let sequence = SKAction.sequence([fadeIn, fadeOut])
            sparkle.run(sequence)
        }

        // Step 3: Vanish block
        let scaleDown = SKAction.scale(to: 0.0, duration: 0.3)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let vanishGroup = SKAction.group([scaleDown, fadeOut])
        blockNode.run(vanishGroup)

        // Step 4: Remove sparkles after vanish
        sparkleEmitterNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }



    func deleteBlock(_ blockNode: BBoxNode) {
        let previousScore = score

        // Run the enhanced delete (swap) animation
        addSwapDeletionEffect(to: blockNode)
        
        // Remember which block is being removed
        let originalBlock = blockNode

        // After the vanish duration completes, remove the block and spawn the new one
        let waitAction = SKAction.wait(forDuration: 0.3) // Enough time for the full animation
        let removeAndReplace = SKAction.run {
            // Remove the old block from the scene and array
            blockNode.removeFromParent()
            if let index = self.boxNodes.firstIndex(of: blockNode) {
                self.boxNodes.remove(at: index)
            }
            
            // Spawn a new, different block
            var newBlock: BBoxNode
            repeat {
                let blockType = self.availableBlockTypes.randomElement()!
                newBlock = blockType.init(
                    layoutInfo: BLayoutInfo(screenSize: self.size, boxSize: CGSize(width: self.tileSize, height: self.tileSize)),
                    tileSize: self.tileSize
                )
            } while type(of: newBlock) == type(of: blockNode)
            
            newBlock.gameScene = self
            newBlock.setScale(self.initialScale)
            newBlock.position = blockNode.position
            self.boxNodes.append(newBlock)
            self.safeAddBlock(newBlock)
            
            // Record a swap move so we can undo it (this will restore the original block and remove the new one)
            let swapMove = Move(originalBlock: originalBlock, newBlock: newBlock, previousScore: previousScore)
            self.undoStack.append(swapMove)

            // Re-layout spawned blocks
            self.layoutSpawnedBlocks(isThreeNewBlocks: false)
            
            // Check for game-over condition
            if self.boxNodes.isEmpty || (!self.checkForPossibleMoves(for: self.boxNodes) && !self.isDeletePowerupAvailable()) {
                self.showGameOverScreen()
            }
        }

        run(SKAction.sequence([waitAction, removeAndReplace]))
    }



    
    func resetBlockHighlights() {
    for blockNode in boxNodes {
        blockNode.run(SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.2))
    }
}

    
    func updateDeletableBlockHighlights() {
        // Dim out almost all scene elements except placeholders, score, and gameOverUI
        // This draws attention to the grid and the blocks that can be deleted
        for child in children {
            if !(child is BBoxNode) &&
                child.name?.starts(with: "powerupPlaceholder") == false &&
                child.name != "scoreContainer" &&
                child.name != "gameOverUI" &&
                child.name != "restartButton" {
                child.run(SKAction.fadeAlpha(to: 0.3, duration: 0.2))
            }
        }

        // Highlight placed blocks that can be deleted
        for placedBlock in placedBlocks {
            if canDeleteBlock(placedBlock) {
                // This placed block is fully intact and can be deleted
                // Give it a bright green highlight and a subtle pulse
                for cellNode in placedBlock.cellNodes {
                    cellNode.removeAllActions()
                    cellNode.run(SKAction.group([
                        SKAction.fadeAlpha(to: 1.0, duration: 0.2),
                        SKAction.colorize(with: .green, colorBlendFactor: 0.7, duration: 0.2)
                    ]))
                    
                    // Add a pulsing scale effect to draw attention
                    let scaleUp = SKAction.scale(to: 1, duration: 0.3)
                    let scaleDown = SKAction.scale(to: 0.95, duration: 0.3)
                    let pulse = SKAction.sequence([scaleUp, scaleDown])
                    cellNode.run(SKAction.repeatForever(pulse))

                }
            } else {
                // This placed block cannot be deleted (not all original cells are present)
                // Fade it out and color it gray
                for cellNode in placedBlock.cellNodes {
                    cellNode.removeAllActions()
                    cellNode.run(SKAction.group([
                        SKAction.fadeAlpha(to: 0.3, duration: 0.2),
                        SKAction.colorize(with: .gray, colorBlendFactor: 0.5, duration: 0.2)
                    ]))
                }
            }
        }

        // Newly spawned blocks (in boxNodes) cannot be deleted since they're not placed
        // Fade them out and color them gray
        for blockNode in boxNodes {
            blockNode.removeAllActions()
            blockNode.run(SKAction.group([
                SKAction.fadeAlpha(to: 0.3, duration: 0.2),
                SKAction.colorize(with: .gray, colorBlendFactor: 0.5, duration: 0.2)
            ]))
        }
    }



    func canDeleteBlock(_ placedBlock: PlacedBlock) -> Bool {
        // Ensure all cells of the block are still present in the grid
        return placedBlock.cellNodes.count == placedBlock.gridPositions.count &&
               placedBlock.gridPositions.allSatisfy { grid[$0.row][$0.col] != nil }
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
        guard let move = undoStack.popLast() else { return }

        switch move.moveType {
        case .placement:
            // Undo a placement move (existing logic)
            // Remove the placed block
            for gridPos in move.placedBlock!.gridPositions {
                if let cellNode = grid[gridPos.row][gridPos.col] {
                    cellNode.removeFromParent()
                    grid[gridPos.row][gridPos.col] = nil
                }
            }

            // Remove from placedBlocks
            if let index = placedBlocks.firstIndex(where: { $0 === move.placedBlock! }) {
                placedBlocks.remove(at: index)
            }

            // Restore cleared lines
            for lineClear in move.clearedLines {
                for (row, col, cellNode) in lineClear.clearedCells {
                    grid[row][col] = cellNode
                    if cellNode.parent == nil {
                        addChild(cellNode)
                    }
                    cellNode.alpha = 1.0
                    cellNode.setScale(1.0)

                    if let originalPosition = cellNode.userData?["originalPosition"] as? CGPoint {
                        cellNode.position = originalPosition
                    } else {
                        cellNode.position = positionForGridCoordinate(GridCoordinate(row: row, col: col))
                    }
                }
            }

            // Remove addedCells from the grid
            for (row, col, cellNode) in move.addedCells {
                grid[row][col] = nil
                cellNode.removeFromParent()
            }

            // Restore the block node to the undo center position
            move.blockNode!.position = getUndoBlockCenterPosition()
            move.blockNode!.setScale(initialScale)
            safeAddBlock(move.blockNode!)
            
            // Restore score
            score = move.previousScore
            updateScoreLabel()

            currentCombo = 1
            clearHighlights()

            // Hide current spawned blocks
            tempSpawnedBlocks = boxNodes
            for block in boxNodes {
                block.removeFromParent()
            }
            boxNodes.removeAll()

            // Add the undo block to boxNodes
            boxNodes.append(move.blockNode!)
            safeAddBlock(move.blockNode!)
            move.blockNode!.position = getUndoBlockCenterPosition()
            move.blockNode!.setScale(initialScale)
            move.blockNode!.gameScene = self
            isUndoInProgress = true

        case .deletion:
               // Undo a deletion move:
               guard let deletedBlock = move.deletedBlock else { return }

               // Restore the deleted block visually
               for (row, col, cellNode) in move.addedCells {
                   grid[row][col] = cellNode
                   if cellNode.parent == nil {
                       addChild(cellNode)
                   }

                   // Reset the cell's visual state
                   cellNode.alpha = 1.0
                   cellNode.setScale(1.0)
                   cellNode.run(SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.2))

                   // Remove any ongoing actions
                   cellNode.removeAllActions()
               }

               // Re-add the block to placedBlocks
               placedBlocks.append(deletedBlock)

               // Restore score
               score = move.previousScore
               updateScoreLabel()

               currentCombo = 1
               clearHighlights()

        case .swap:
            // Undo a swap move:
            // Remove the newly created block and restore the original block
            guard let originalBlock = move.originalBlockNode, let newBlock = move.newBlockNode else { return }

            // Remove the new block from the scene and from boxNodes
            if let index = boxNodes.firstIndex(of: newBlock) {
                boxNodes.remove(at: index)
            }
            newBlock.removeFromParent()

            // Re-add the original block to the scene
            originalBlock.setScale(initialScale)
            safeAddBlock(originalBlock)
            boxNodes.append(originalBlock)

            // Restore score
            score = move.previousScore
            updateScoreLabel()

            currentCombo = 1
            clearHighlights()
        }
    }


// Helper function to calculate the center position for the undo block
func getUndoBlockCenterPosition() -> CGPoint {
    let centerX = size.width / 2
    let centerY = size.height * 0.25  // Match the Y position of the spawn area
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
                // Check if the block is the only one in the spawn area
                if boxNodes.count == 1 && boxNodes.first === node {
                    // Fix the block to the center of the spawn area
                    node.position = getUndoBlockCenterPosition()
                    node.initialPosition = node.position // Update the initial position to the center
                } else {
                    // If the placement is invalid, return the block to its original position
                    node.position = node.initialPosition
                }
                node.run(SKAction.scale(to: initialScale, duration: 0.1)) {
                    node.addOutline()
                }
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

// Define a MoveType enum to distinguish move types
enum MoveType {
    case placement
    case deletion
    case swap
}

class Move {
    let placedBlock: PlacedBlock?
    let blockNode: BBoxNode?
    let previousScore: Int
    let addedCells: [(row: Int, col: Int, cellNode: SKShapeNode)]
    let clearedLines: [LineClear]
    let moveType: MoveType
    
    // For deletion moves:
    // The deletedBlock stores the block that was deleted.
    // We can restore it by placing its cells back.
    var deletedBlock: PlacedBlock?
    
    // For swap moves:
    // We store the original block that was removed and the new block that replaced it.
    var originalBlockNode: BBoxNode?
    var newBlockNode: BBoxNode?
    
    // Placement move initializer
    init(placedBlock: PlacedBlock,
         blockNode: BBoxNode,
         previousScore: Int,
         addedCells: [(Int, Int, SKShapeNode)],
         clearedLines: [LineClear]) {
        
        self.placedBlock = placedBlock
        self.blockNode = blockNode
        self.previousScore = previousScore
        self.addedCells = addedCells
        self.clearedLines = clearedLines
        self.moveType = .placement
        self.deletedBlock = nil
        self.originalBlockNode = nil
        self.newBlockNode = nil
    }
    
    // Deletion move initializer
    init(deletedBlock: PlacedBlock, previousScore: Int) {
        self.placedBlock = nil
        self.blockNode = nil
        self.previousScore = previousScore
        // For a deletion move, addedCells represent the cells that were part of the deleted block
        self.addedCells = deletedBlock.gridPositions.enumerated().compactMap { (index, pos) in
            if let cellNode = deletedBlock.cellNodes[index] as? SKShapeNode {
                return (pos.row, pos.col, cellNode)
            }
            return nil
        }
        self.clearedLines = []
        self.moveType = .deletion
        self.deletedBlock = deletedBlock
        self.originalBlockNode = nil
        self.newBlockNode = nil
    }
    
    // Swap move initializer
    init(originalBlock: BBoxNode, newBlock: BBoxNode, previousScore: Int) {
        self.placedBlock = nil
        self.blockNode = nil
        self.previousScore = previousScore
        self.addedCells = []
        self.clearedLines = []
        self.moveType = .swap
        self.deletedBlock = nil
        self.originalBlockNode = originalBlock
        self.newBlockNode = newBlock
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
//extension UIImage {
//    convenience init(color: UIColor, size: CGSize) {
//        let rect = CGRect(origin: .zero, size: size)
//        UIGraphicsBeginImageContextWithOptions(size, false, 0)
//        color.setFill()
//        UIRectFill(rect)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        self.init(cgImage: image!.cgImage!)
//    }
//}
extension UIImage {
    // Utility to create textures from UIColor
    convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContext(size)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.init(cgImage: image.cgImage!)
    }
}
