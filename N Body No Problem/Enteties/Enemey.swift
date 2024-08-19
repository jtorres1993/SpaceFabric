//
//  Enemey.swift
//  N Body No Problem
//
//  Created by Jorge Torres on 8/18/24.
//

import Foundation
import SpriteKit

class Enemey: SKSpriteNode {
    
    var health = 10
    var distanceToPlayer : CGFloat = 90000.0
    var hasLockedOnToPlayer = false
    
    func detectIfPlayerVisibleToNode(playerPosition: CGPoint, playerVelocity: CGVector){
        
        
        let dx = self.position.x - playerPosition.x
        let dy = self.position.y - playerPosition.y
        distanceToPlayer = sqrt(dx * dx + dy * dy)
        
        
    }
    
    func startAttacktOPlayer(playerPosition: CGPoint){
        
        
        
        
    }
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
     
        super.init(texture: texture, color: UIColor.clear, size: texture!.size())
      }
    required init?(coder aDecoder: NSCoder) {
           // Initialize all properties
           self.health = 10
           self.distanceToPlayer = 90000.0
           self.hasLockedOnToPlayer = false
           
           // Call the designated initializer of SKSpriteNode
           super.init(coder: aDecoder)
       }
    
}
