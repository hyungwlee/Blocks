import SpriteKit

class BLShapeNode2x2: BBoxNode {
    required init(layoutInfo: BLayoutInfo, tileSize: CGFloat, color: UIColor = .orange) {
        super.init(layoutInfo: layoutInfo, tileSize: tileSize, color: color)
        // Define the shape of the L-shaped block
        let shapeCells = [
            (row: 0, col: 0),
            (row: 1, col: 0),
            (row: 1, col: 1)
        ]
        setupShape(shapeCells)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
