//
//  GameState.swift
//  Blocks
//
//  Created by Jevon Williams on 10/28/24.
//

import Foundation

class BLGameState {
    static let shared = BLGameState()
    
    private var occupiedCells: Set<BLGridCoordinate> = []

    private init() {
        // Initialize with default occupied cells if necessary
    }

    // Method to check if a cell is occupied
    func isCellOccupied(row: Int, col: Int) -> Bool {
        return occupiedCells.contains(BLGridCoordinate(row: row, col: col))
    }

    // Method to occupy a cell
    func occupyCell(row: Int, col: Int) {
        occupiedCells.insert(BLGridCoordinate(row: row, col: col))
    }

    // Method to free a cell
    func freeCell(row: Int, col: Int) {
        occupiedCells.remove(BLGridCoordinate(row: row, col: col))
    }
    
    // Optional: Method to reset the game state
    func reset() {
        occupiedCells.removeAll()
    }
}

