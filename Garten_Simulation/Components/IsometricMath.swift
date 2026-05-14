import SwiftUI

struct IsometricMath {
    static let tileWidth: CGFloat = 145
    static let tileHeight: CGFloat = 72
    static let tileSide: CGFloat = 16
    
    static func point(col: Int, row: Int, screenWidth: CGFloat) -> CGPoint {
        let offsetX = screenWidth / 2
        let offsetY: CGFloat = 80
        
        let x = CGFloat(col - row) * (tileWidth / 2) + offsetX
        let y = CGFloat(col + row) * (tileHeight / 2) + offsetY
        return CGPoint(x: x, y: y)
    }
}
