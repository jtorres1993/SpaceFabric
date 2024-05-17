
import Foundation
import SpriteKit

let colors = [UIColor.red, UIColor.yellow, UIColor.blue, UIColor.green, UIColor.cyan, UIColor.gray, UIColor.white, UIColor.black, UIColor.magenta, UIColor.orange, UIColor.darkGray, UIColor.lightGray]

class DotNode: SKSpriteNode {
    var originalPosition: CGPoint?

    init(color: UIColor, size: CGSize, initialPosition: CGPoint, withCameraPos: CGPoint ) {
        
        let backgroundColorIndex = Int.random(in: 1...11)

        
        super.init(texture: nil, color: colors[backgroundColorIndex], size: size)
       // self.position = withCameraPos
        self.name = "dot"
        let randWaitTIme = Double.random(in: 0.0 ... 0.5)

        let randSpeedTIme = Double.random(in: 0.0 ... 0.5)
        
        let overshootPosition = CGPoint(x: initialPosition.x * 3.05, y: initialPosition.y * 3.50)
        let overshootPositionReversed = CGPoint(x: initialPosition.x * 0.90, y: initialPosition.y * 0.90)
        self.position = overshootPosition

        
      
        self.alpha = 0.0
        let finalAlphaVal = Double.random(in: 0.0 ... 1.0)
        self.setScale(4.0)
        self.run(SKAction.sequence([
            SKAction.wait(forDuration: randWaitTIme),
            SKAction.group([ SKAction.fadeAlpha(to: finalAlphaVal, duration: randSpeedTIme), SKAction.scale(to: 0.8, duration: randSpeedTIme),            SKAction.move(to: overshootPositionReversed, duration: randSpeedTIme) ]),
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
