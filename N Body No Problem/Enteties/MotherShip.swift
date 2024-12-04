//
//  MotherShip.swift
//  N Body No Problem
//
//  Created by Jorge Torres on 5/22/24.
//

import Foundation
import SpriteKit
import AudioToolbox



class MotherShip: ProjectileEntity {
    
    var isLockedOn = false
    var totalHealth = 2
    var currentHealth  = 2
    
    let chargeNode = SKShapeNode.init(circleOfRadius: 5)

    
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
        
        self.addChild(chargeNode)
        chargeNode.position = CGPoint.init(x: 0, y:  -self.size.height )
        //chargeNode.alpha
        chargeNode.fillColor = .white
        chargeNode.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(by: 1.5, duration: 0.1),
            SKAction.scale(by: 1 / 1.5, duration: 0.1)
        
        ])))
        
        
        
    }
    
    override func recreatePhysicsBody(){
        
        self.physicsBody!.mass = 100

        self.physicsBody?.fieldBitMask =  PhysicsCategory.gravityStar
        self.physicsBody?.categoryBitMask = PhysicsCategory.player
        self.physicsBody?.collisionBitMask = PhysicsCategory.none
    }
    
    
    func lockedOnEnemeyDestroyed(){
        
    }
    
    func lazerShoot(_ vector: CGPoint){
     
        
      
      
    }
    
    
    func boostChargeUpAnimation(){
        
        
        var randomNodes : [SKSpriteNode] =  []
        for x in 1...10{
            
                for y in 1...10 {
            
                    let randomNode = SKSpriteNode.init(color: .white, size: CGSize.init(width: 10, height: 10) )
                    self.addChild(randomNode)
                    
                    randomNode.position.y = -CGFloat.random(in: CGFloat(0.0)...(SharedInfo.SharedInstance.screenSize.height/2))
                    
                    randomNode.position.x = CGFloat.random(in: -SharedInfo.SharedInstance.screenSize.width/2...SharedInfo.SharedInstance.screenSize.width/2)
                    
                    randomNodes.append(randomNode)
                    randomNode.alpha = 0.0
                }
        }
        
        
        let animation_speed = 0.10
        
        for node in randomNodes {
            
            node.run(SKAction.sequence([SKAction.wait(forDuration: CGFloat.random(in: 0...0.5)), SKAction.group([ SKAction.move(to: CGPoint.init(x: 0, y:  -self.size.height * 1)  , duration: animation_speed), SKAction.fadeAlpha(to: 1.0, duration: animation_speed)]),SKAction.fadeAlpha(to: 0.0, duration: 0.01)]), completion: buildUpChargeNode)
            
            
            
            
        }
        
        self.run(SKAction.playSoundFileNamed("sci-fi-charge-up-37395", waitForCompletion: false))
        
    }
    
    
    func buildUpChargeNode(){
        self.chargeNode.run(SKAction.scale(by: 1.017, duration: 0.01))
        
    }
    
    
    func startAnimation() {
         // Load the texture atlas
         let textureAtlas = SKTextureAtlas(named: "ShipAnimation")
         
         // Create an array to hold the textures
         var frames: [SKTexture] = []
         
         // Load all 16 frames from the atlas
         for i in 1...16 {
             let textureName = "000\(i)"
             frames.append(textureAtlas.textureNamed(textureName))
         }
         
         // Create the animation action
         let animation = SKAction.animate(with: frames, timePerFrame: 0.025, resize: true, restore: false)
         
         // Repeat the animation forever
         let repeatAnimation = SKAction.repeatForever(animation)
         
         // Run the animation on the sprite
        self.run(repeatAnimation)
        
     }
    
    
    func shipLaunchedAnimation(){
        
        
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }


       // startAnimation()
        //  self.chargeNode.removeAllActions()
        self.chargeNode.run(SKAction.scale(to: 0.0, duration: 0.5), completion: {self.chargeNode.removeAllActions()})
        
        
        
        var randomNodes : [SKSpriteNode] =  []
        for _ in 1...10{
            
                for _ in 1...10 {
            
                    let randomNode = SKSpriteNode.init(color: .white, size: CGSize.init(width: 10, height: 10) )
                    self.addChild(randomNode)
                    
                    randomNode.position = CGPoint.init(x: 0, y:  -self.size.height )
                    
                    randomNodes.append(randomNode)
                }
        }
        
        
        
        let animation_speed = 0.025
        for node in randomNodes {
            
            let movePosition = CGPoint.init(x: CGFloat.random(in: -SharedInfo.SharedInstance.screenSize.width/2...SharedInfo.SharedInstance.screenSize.width/2), y: -CGFloat.random(in: (SharedInfo.SharedInstance.screenSize.height/16)...(SharedInfo.SharedInstance.screenSize.height/2)))
            
            node.run(SKAction.sequence([SKAction.wait(forDuration: CGFloat.random(in: 0...0.01)), SKAction.group([ SKAction.move(to: movePosition, duration: animation_speed), SKAction.fadeAlpha(to: 0.0, duration: animation_speed)]),SKAction.fadeAlpha(to: 0.0, duration: 0.01)]))
        }
        
        
    }
}
