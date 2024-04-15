
import Foundation
import SpriteKit

class DotNode: SKSpriteNode {
    var originalPosition: CGPoint

    init(color: UIColor, size: CGSize, initialPosition: CGPoint) {
        self.originalPosition = initialPosition
        super.init(texture: nil, color: color, size: size)
        self.position = initialPosition
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
