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
             
                  
              self.setScale(3.0)
              self.lightingBitMask = 1
              self.zPosition = -1
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // background.run(SKAction.colorize(with: self.colors[self.backgroundColorIndex], colorBlendFactor: 1.0, duration: 0.01))
     
     /*background.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 5),
                                                              
                                                              SKAction.run {
         background.run(SKAction.colorize(with: self.colors[self.backgroundColorIndex], colorBlendFactor: 0.5, duration: 5))
     }
                                                             
                                                             
                                                          , SKAction.run {
         if(self.backgroundColorIndex < self.colors.count - 1) {
             self.backgroundColorIndex = self.backgroundColorIndex + 1} else {
                 self.backgroundColorIndex = 0
             }
     }])))
      */ 
    
}
