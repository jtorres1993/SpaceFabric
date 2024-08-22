//
//  MotherShip.swift
//  N Body No Problem
//
//  Created by Jorge Torres on 5/22/24.
//

import Foundation
import SpriteKit

class MotherShip: ProjectileEntity {
    
    var isLockedOn = false
    var totalHealth = 2
    var currentHealth  = 2
    
    func setup(){
        
        self.physicsBody = SKPhysicsBody.init(rectangleOf: self.size)
        self.name = "ship"
        self.physicsBody?.fieldBitMask = PhysicsCategory.gravityStar
        self.physicsBody!.categoryBitMask = PhysicsCategory.player
        self.physicsBody!.mass = 100
        self.physicsBody?.contactTestBitMask =  PhysicsCategory.gravityStar | PhysicsCategory.earthplanet
        self.physicsBody?.isDynamic = false
        self.physicsBody?.usesPreciseCollisionDetection = true 
        
        let lightNode = SKLightNode()
        lightNode.categoryBitMask = 1
        lightNode.falloff = 4.5
        self.addChild(lightNode)
        
        
    }
    
    override func recreatePhysicsBody(){
        
        self.physicsBody?.fieldBitMask =  PhysicsCategory.gravityStar
        self.physicsBody?.categoryBitMask = PhysicsCategory.player
        self.physicsBody?.collisionBitMask = PhysicsCategory.none
    }
    
    
    func lockedOnEnemeyDestroyed(){
        
    }
    
    func lazerShoot(_ vector: CGPoint){
     
        
      
      
    }
    
}
