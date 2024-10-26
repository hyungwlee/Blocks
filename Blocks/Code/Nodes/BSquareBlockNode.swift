//
//  TTSquareBlockNode.swift
//  Blocks
//
//  Created by Jevon Williams on 10/25/24.
//

import Foundation
import SpriteKit

class BSquareBlock: BBoxNode {
    
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat) {
        // Call the superclass initializer with a default color (e.g., pink)
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: .systemPink)
        
        // Create the square shape node with size twice the box size
        let squareWidth = layoutInfo.boxSize.width * 2
        let squareHeight = layoutInfo.boxSize.height * 2 // 2x2 block

        let squarePath = UIBezierPath(rect: CGRect(origin: CGPoint(x: -squareWidth / 2, y: -squareHeight / 2), size: CGSize(width: squareWidth, height: squareHeight)))
        let squareShapeNode = SKShapeNode(path: squarePath.cgPath)
        
        // Set the fill color for the square block (already set in the superclass)
        squareShapeNode.fillColor = .systemPink // Change color as needed
        squareShapeNode.lineWidth = 2.0 // Change line width if necessary
        
        // Center it in the block
        squareShapeNode.position = CGPoint.zero 
        
        // Add the square shape to the node
        addChild(squareShapeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder) // Ensure 'override' is used here
    }
    
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor) {
        // Call the superclass initializer with the provided parameters
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        
        // Create the square shape node with size twice the box size
        let squareWidth = layoutInfo.boxSize.width * 2
        let squareHeight = layoutInfo.boxSize.height * 2 // 2x2 block

        let squarePath = UIBezierPath(rect: CGRect(origin: CGPoint(x: -squareWidth / 2, y: -squareHeight / 2), size: CGSize(width: squareWidth, height: squareHeight)))
        let squareShapeNode = SKShapeNode(path: squarePath.cgPath)
        
        // Set the fill color for the square block
        squareShapeNode.fillColor = color // Use the provided color
        squareShapeNode.lineWidth = 2.0 // Change line width if necessary
        
        // Center it in the block
        squareShapeNode.position = CGPoint.zero 
        
        // Add the square shape to the node
        addChild(squareShapeNode)
    }
}







