
import Foundation
import SpriteKit

class DotNode: SKSpriteNode {
    var originalPosition: CGPoint?

    init(color: UIColor, size: CGSize, initialPosition: CGPoint, withCameraPos: CGPoint ) {
        super.init(texture: nil, color: color, size: size)
        self.position = withCameraPos
        self.name = "dot"
        let randWaitTIme = Double.random(in: 0.0 ... 0.5)

        let randSpeedTIme = Double.random(in: 0.0 ... 0.5)
        
        let overshootPosition = CGPoint(x: initialPosition.x * 1.05, y: initialPosition.y * 1.05)

        
      
        self.alpha = 0.0
        self.setScale(0.0)
        self.run(SKAction.sequence([
            SKAction.wait(forDuration: randWaitTIme),
            SKAction.group([ SKAction.fadeAlpha(to: 1.0, duration: randSpeedTIme), SKAction.scale(to: 1.4, duration: randSpeedTIme),            SKAction.move(to: overshootPosition, duration: randSpeedTIme) ]),
            SKAction.group([
                SKAction.move(to: initialPosition, duration: 0.2), 
                SKAction.scale(to: 1.0, duration: 0.2)]),
                SKAction.run {
                   
                        let randomInt = Int.random(in: 0...3)
                            if(randomInt == 0){
                         
                            self.run(SharedInfo.SharedInstance.scifiwepsound)
                        }
                    
                self.originalPosition = initialPosition
                self.position = initialPosition
                
            }]))
        // self.lightingBitMask = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
