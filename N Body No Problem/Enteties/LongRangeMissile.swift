//
//  LongRangeMissile.swift
//  N Body No Problem
//
//  Created by Jorge Torres on 8/18/24.
//

import Foundation
import SpriteKit

class LongRangeMissile : ProjectileEntity {
    
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        
        let texture = SKTexture(imageNamed: "missilei1")
        
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        
        self.physicsBody = SKPhysicsBody.init(rectangleOf: self.size)
        self.name = "longrangemissile"
        self.physicsBody?.fieldBitMask = PhysicsCategory.gravityStar
        self.physicsBody!.categoryBitMask = PhysicsCategory.playerProjectile
        self.physicsBody!.mass = 100
        self.physicsBody?.contactTestBitMask =  PhysicsCategory.gravityStar | PhysicsCategory.earthplanet | PhysicsCategory.enemy
        self.physicsBody?.isDynamic = false
        self.physicsBody?.usesPreciseCollisionDetection = true
        
        let lightNode = SKLightNode()
        lightNode.categoryBitMask = 1
        lightNode.falloff = 4.5
        self.addChild(lightNode)
        
        
    }
    
    
    override func recreatePhysicsBody(){
        
        self.physicsBody?.fieldBitMask =  PhysicsCategory.gravityStar
        self.physicsBody?.categoryBitMask = PhysicsCategory.playerProjectile
        self.physicsBody?.collisionBitMask = PhysicsCategory.enemy
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        
        
        
        
    }
    
    
    
}
