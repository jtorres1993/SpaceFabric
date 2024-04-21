
import Foundation
import SpriteKit

class DotNode: SKSpriteNode {
    var originalPosition: CGPoint

    init(color: UIColor, size: CGSize, initialPosition: CGPoint) {
        self.originalPosition = initialPosition
        super.init(texture: nil, color: color, size: size)
        self.position = initialPosition
        self.lightingBitMask = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
