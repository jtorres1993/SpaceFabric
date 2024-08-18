//
//  MotherShip.swift
//  N Body No Problem
//
//  Created by Jorge Torres on 5/22/24.
//

import Foundation
import SpriteKit

class MotherShip: SKSpriteNode {
    
    var isLockedOn = false 
    
    
    func setup(){
        
        self.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize.init(width: 10, height: 10))
        self.name = "ship"
        self.physicsBody?.fieldBitMask = PhysicsCategory.gravityStar
        self.physicsBody!.categoryBitMask = PhysicsCategory.player
        self.physicsBody!.mass = 100
        self.physicsBody?.contactTestBitMask =  PhysicsCategory.gravityStar | PhysicsCategory.earthplanet
        self.physicsBody?.isDynamic = false
        
        
        let lightNode = SKLightNode()
        lightNode.categoryBitMask = 1
        lightNode.falloff = 4.5
        self.addChild(lightNode)
        
        
    }
    
    func rotateBasedOnMovement(forceVector: CGVector){
        
        let angle = atan2(forceVector.dy, forceVector.dx) - (CGFloat.pi / 2)
        self.zRotation = angle
    }
    
    func lockedOnEnemeyDestroyed(){
        
    }
    
    func lazerShoot(_ vector: CGPoint){
     
        
      
      
    }
    
}
