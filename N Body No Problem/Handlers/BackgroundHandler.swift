//
//  BackgroundHandler.swift
//  N Body No Problem
//
//  Created by Jorge Torres on 5/24/24.
//

import Foundation
import SpriteKit

class BackgroundHandler: SKSpriteNode {
    
    var backgroundColorIndex = 0
    let colors = [UIColor.red, UIColor.yellow, UIColor.blue, UIColor.green, UIColor.cyan, UIColor.gray, UIColor.white, UIColor.black, UIColor.magenta, UIColor.orange]
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        
        
        
        super.init(texture: nil, color: SharedInfo.SharedInstance.backgroundColor , size:SharedInfo.SharedInstance.screenSize )
        
              
              self.backgroundColorIndex = Int.random(in: 1...9)
             
        
              //self.setScale(3.0)
              self.lightingBitMask = 1
              self.zPosition = -1
        
    }
    
    func setup(){
        
        
             
   for _ in 0...50 {
       
       let star = SKSpriteNode.init(imageNamed: "shinestar")
       star.position = CGPoint.init(x: CGFloat.random(in: -SharedInfo.SharedInstance.screenSize.width ... SharedInfo.SharedInstance.screenSize.width), y: CGFloat.random(in: -SharedInfo.SharedInstance.screenSize.height ... SharedInfo.SharedInstance.screenSize.height))
       
       star.run(SKAction.colorize(with: colors[Int.random(in: 0...9)], colorBlendFactor: 1.0, duration: 0.01))
       star.alpha = CGFloat.random(in: 0.2...0.9)
       star.setScale(CGFloat.random(in: 0.3...0.9))
       
       
       self.addChild(star)
   }
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    
}
