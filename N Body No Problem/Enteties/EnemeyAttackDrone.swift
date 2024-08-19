//
//  EnemeyScout.swift
//  N Body No Problem
//
//  Created by Jorge Torres on 5/26/24.
//

import Foundation
import SpriteKit

class EnemeyAttackDrone: Enemey {
    

    var savedPlayerPosition = CGPoint.zero
    var savedPlayerVelocity = CGVector.zero
    var playerDetectionDistance = 250.0
    var misslespeed = 1000.0
    
   
    override  init(texture: SKTexture?, color: UIColor, size: CGSize) {
          
        let texture = SKTexture(imageNamed: "redtriangle")
          // Call the superclass's initializer
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        
      }
      
      // Required initializer
      required init?(coder aDecoder: NSCoder) {
          // Initialize the new property before calling super
          
          // Call the superclass's required initializer
          super.init(coder: aDecoder)
          
          let detectionCircle = SKShapeNode(circleOfRadius: playerDetectionDistance * 4 )
          detectionCircle.strokeColor = .red
          detectionCircle.lineWidth = 8
          
          self.addChild(detectionCircle)
        
      }
    
    override func detectIfPlayerVisibleToNode(playerPosition: CGPoint, playerVelocity: CGVector){
        
        savedPlayerPosition = playerPosition
        savedPlayerVelocity = playerVelocity
        super.detectIfPlayerVisibleToNode(playerPosition: playerPosition, playerVelocity: playerVelocity)
        
        if (self.distanceToPlayer < playerDetectionDistance && hasLockedOnToPlayer == false ) {
            
            
            startAttacktOPlayer(playerPosition: playerPosition)
            
        } else if (self.distanceToPlayer < playerDetectionDistance && hasLockedOnToPlayer == true  )
        {
            let dx = playerPosition.x - self.position.x
            let dy = playerPosition.y - self.position.y
              let angle = atan2(dy, dx)
              
              // Rotate the sprite to face the target point
            self.zRotation = angle - .pi  / 2
        } else if ( self.distanceToPlayer >= playerDetectionDistance && hasLockedOnToPlayer == true ) {
            
            hasLockedOnToPlayer = false
            self.removeAction(forKey: "AttackAction")
        }
        
    }
    
    override func startAttacktOPlayer(playerPosition: CGPoint) {
        
        hasLockedOnToPlayer = true
       
        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            
            let fireNode = SKSpriteNode.init(color: .red, size: CGSize.init(width: 5, height: 50 ))
            fireNode.position = self.position
         
            fireNode.physicsBody = SKPhysicsBody.init(rectangleOf: fireNode.size , center: CGPoint.zero)
              
            fireNode.physicsBody?.categoryBitMask = PhysicsCategory.enemeyProjectile
            fireNode.physicsBody?.contactTestBitMask = PhysicsCategory.player
            
            fireNode.physicsBody?.isDynamic = false 
            fireNode.physicsBody?.usesPreciseCollisionDetection = true
            
              // Rotate the sprite to face the target point
            
            let dx = self.savedPlayerPosition.x - fireNode.position.x
            let dy = self.savedPlayerPosition.y - fireNode.position.y
            
            
            let angle = atan2(dy, dx)
            fireNode.zRotation = angle - .pi  / 2

            let distance = sqrt(dx * dx + dy * dy)
            let timeToReach = distance / self.misslespeed
            
            print(timeToReach)
            
            let predictedPlayerPosition = CGPoint(
                x: self.savedPlayerPosition.x, //+ self.savedPlayerVelocity.dx, //* timeToReach,
                y: self.savedPlayerPosition.y //+ self.savedPlayerVelocity.dy //* timeToReach
               )
            
            let predictedDx = predictedPlayerPosition.x - fireNode.position.x
            let predictedDy = predictedPlayerPosition.y - fireNode.position.y
            
                // Normalize the direction vector to get a unit vector
            let magnitude = sqrt(predictedDx * predictedDx + predictedDy * predictedDy)
            let direction = CGPoint(x: predictedDx / magnitude, y: predictedDy / magnitude)
    

                // Calculate the movement vector by scaling the direction vector by the desired speed
            let moveVector = CGPoint(x: direction.x * self.misslespeed, y: direction.y * self.misslespeed)

            self.parent!.addChild(fireNode)
            fireNode.run(SKAction.move(by: CGVector(dx: moveVector.x, dy: moveVector.y), duration: 0.5))
            
            
        }, SKAction.wait(forDuration: 0.5)])), withKey: "AttackAction")
        
        
    }
    
    func endAttackOnPlayer(){
        
    }
    
}
