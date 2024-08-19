//
//  GameplayHandler.swift
//  N Body No Problem
//
//  Created by Jorge Torres on 8/11/24.
//

import Foundation
import SpriteKit

class GameplayHandler : SKNode, SKPhysicsContactDelegate {
    
    
    var starReference : [SKSpriteNode] = []
    var planets = [(position: CGPoint, radius: CGFloat, strength: CGFloat)]()
    var earchReference = SKSpriteNode()
    var trajectoryLineIntersectionWithStarCallback : ((_ dotNode: SKNode?) -> Void)? = nil
    var sameLevelTriggered : (() -> Void )? = nil
    var astroCapturedHandler : (() -> Void)? = nil
    var playerTookHealthDamage: ((_ percentage: CGFloat ) -> Void)? = nil
    
    var playerDestroyed: (() -> Void)? = nil
    
    var requiredAstrosToNextLevel = 0
    var shipReference = MotherShip()
    var enemies : [Enemey] = []

    
    func updateSceneNodes(withNodes: [SKNode]){
        for node in withNodes {
            if node.name == "gravitystar"
            {
                setupStarWithNode(node: node)
                
            } else if node.name == "earth" {
                
                earchReference = node as! SKSpriteNode
                node.physicsBody!.categoryBitMask =  PhysicsCategory.earthplanet


                let shape = SKShapeNode.init(circleOfRadius: 100)
                shape.strokeColor = UIColor.cyan
                shape.run(SKAction.repeatForever(SKAction.sequence([
                    SKAction.group([SKAction.scale(to: 0.0, duration: 4), SKAction.fadeAlpha(to: 0.0, duration: 4.0)]),
                    SKAction.wait(forDuration: 1),
                    SKAction.group([SKAction.scale(to: 1.0, duration: 0.001), SKAction.fadeAlpha(to: 1.0, duration: 0.001)])
                   
                    
                ])))
                node.addChild(shape)
                node.position.y = node.position.y + 25
                node.run(SKAction.group([SKAction.moveBy(x: 0, y: -25, duration: 1.0),  SKAction.fadeAlpha(to: 1.0, duration: 0.5)]))
                
                
                
                
            } else if node.name == "astro" {
                node.position.y = node.position.y + 25
                node.run(SKAction.group([SKAction.moveBy(x: 0, y: -25, duration: 1.0),  SKAction.fadeAlpha(to: 1.0, duration: 0.5)]))
                node.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize.init(width: 30, height: 50))
                node.physicsBody!.categoryBitMask = PhysicsCategory.astronaut
                node.physicsBody!.affectedByGravity = false
                node.physicsBody!.isDynamic = false
                node.physicsBody!.contactTestBitMask = PhysicsCategory.player
                
                
               
            } else if node.name == "alien" {
                
                
                node.physicsBody = SKPhysicsBody(rectangleOf: CGSize.init(width: 100, height: 100))
                node.physicsBody!.affectedByGravity = false
                node.physicsBody!.pinned = true
                node.physicsBody!.categoryBitMask = PhysicsCategory.enemy
                node.physicsBody!.contactTestBitMask = PhysicsCategory.playerProjectile
                node.physicsBody?.usesPreciseCollisionDetection = true
                node.physicsBody?.allowsRotation = false
                node.physicsBody!.isDynamic = true
                
            } else if node.name == "HolderNode" {
                
                for nodos in node.children {
                    setupStarWithNode(node: nodos)
                }
            } else if node.name == "Enemigo" {
                
                 
                 
                 node.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize.init(width: 10, height: 10))
                 node.name = "Enemigo"
                 node.physicsBody?.fieldBitMask = PhysicsCategory.gravityStar
                node.physicsBody?.categoryBitMask = PhysicsCategory.enemy
                node.physicsBody?.usesPreciseCollisionDetection = true
                 node.physicsBody?.mass = 10000000
                
                
                self.run(SKAction.repeatForever(SKAction.sequence([
                
                    SKAction.wait(forDuration: 60 ),
                    
                    SKAction.run {
                        node.physicsBody!.velocity = CGVector.init(dx: 0, dy: 0)
                        node.physicsBody!.allowsRotation = false
                    }
                ])))
                
            } else if node.name == "EnemeyAttackDrone" {
                
                enemies.append(node as! EnemeyAttackDrone)
                
            }
        }
        
    }
    
    
    
    func setupStarWithNode(node: SKNode){
        
        node.physicsBody!.categoryBitMask =  PhysicsCategory.gravityStar

        starReference.append(node as! SKSpriteNode)
        planets.append((position: node.position, radius: 200, strength: 1500))
    
        let lightNode = SKLightNode()
        lightNode.categoryBitMask = 1
        lightNode.falloff = 1
        node.addChild(lightNode)
        
        
    
        let shape = SKShapeNode.init(circleOfRadius: 200)
        
        shape.lineWidth = 10
        
        
        shape.alpha = 0.0
        shape.strokeColor = UIColor.systemYellow
        shape.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.group([SKAction.scale(to: 0.0, duration: 2), SKAction.fadeAlpha(to: 0.8, duration: 2.0)]),
            SKAction.wait(forDuration: 1),
            SKAction.group([SKAction.scale(to: 1.0, duration: 0.001), SKAction.fadeAlpha(to: 0.0, duration: 0.001)])
           
            
        ])))
        
        
        node.addChild(shape)
        node.position.y = node.position.y + 25
        
        node.run(SKAction.group([SKAction.moveBy(x: 0, y: -25, duration: 1.0),  SKAction.fadeAlpha(to: 1.0, duration: 0.5)]))

        
        let shape2 = SKShapeNode.init(circleOfRadius: 200)
        shape2.strokeColor = UIColor.yellow
        
        shape2.alpha = 0.5
        
            
            for i in 0...7 {
                
                if let spark = SKEmitterNode(fileNamed: "spark") {
                    
                    spark.particleTexture = SharedInfo.SharedInstance.dotTexture
                   // node.addChild(spark)
                   // spark.targetNode = node
                    spark.emissionAngle = CGFloat(degreesToradians( Float(i) * 45 ))
                    
                }
            }
        
        
        
        let sunLensFlare = SKShapeNode.init(circleOfRadius: 40)
        sunLensFlare.fillColor = .systemYellow
        sunLensFlare.strokeColor = .systemYellow
        sunLensFlare.alpha = 0.15
        sunLensFlare.run(SKAction.repeatForever( SKAction.sequence([
          
            SKAction.scale(to: 1.2, duration: 0.4),
            SKAction.scale(to: 1.0, duration: 0.4) ]) ))
               
            
            
           
       node.addChild(sunLensFlare)
                            
        for child in node.children {
            if child.name == "SunGravityField" {
            }
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
     
     if secondBody.categoryBitMask == PhysicsCategory.player && firstBody.categoryBitMask == PhysicsCategory.gravityStar {
             
         //Player crashed into a star
       
         self.sameLevelTriggered?()
     
        
         
     } else if ((secondBody.categoryBitMask == PhysicsCategory.playerProjectile && firstBody.categoryBitMask == PhysicsCategory.enemy) || (secondBody.categoryBitMask == PhysicsCategory.enemy && firstBody.categoryBitMask == PhysicsCategory.playerProjectile)) {
         
         //Player projectile hit enemey
         
         if let secondbody_node = secondBody.node {
             secondbody_node.removeFromParent()
         }
         if let firstbody_node = firstBody.node {
             firstbody_node.removeFromParent()
         }
         
         
     }
        
        else if ((secondBody.categoryBitMask == PhysicsCategory.enemeyProjectile && firstBody.categoryBitMask == PhysicsCategory.player) || (secondBody.categoryBitMask == PhysicsCategory.player && firstBody.categoryBitMask == PhysicsCategory.enemeyProjectile)) {
            
            //Enemey projectile hit Player
            
            
           
            
            shipReference.currentHealth = shipReference.currentHealth - 1
            
            if (shipReference.currentHealth == 0) {
                firstBody.node!.removeAllActions()
                secondBody.node!.removeAllActions()
                self.playerDestroyed?()
                
                
            }
            
            self.playerTookHealthDamage?(CGFloat(shipReference.currentHealth /  shipReference.totalHealth ))
           
            
        }
     
     else if ( secondBody.categoryBitMask == PhysicsCategory.player && firstBody.categoryBitMask == PhysicsCategory.earthplanet || secondBody.categoryBitMask == PhysicsCategory.earthplanet && firstBody.categoryBitMask == PhysicsCategory.player ) {
         
         
         //player hit earth planet
      
        
         
         
     } else if ( secondBody.categoryBitMask == PhysicsCategory.whip && firstBody.categoryBitMask == PhysicsCategory.gravityStar ) {
         
         // End of Trajectory line hit a star object, remove the last dot node

             if let dotNode = secondBody.node {
                 self.trajectoryLineIntersectionWithStarCallback?( dotNode )
                }
             
         
         
     }  else if ( secondBody.categoryBitMask == PhysicsCategory.player && firstBody.categoryBitMask == PhysicsCategory.astronaut || secondBody.categoryBitMask == PhysicsCategory.astronaut && firstBody.categoryBitMask == PhysicsCategory.player )  {
         
         //Astro was captured by the player
         
         let node =  secondBody.node!
         node.run(SKAction.sequence([SKAction.group([
             
             SKAction.scale(to: 1.3, duration: 0.2),
             SKAction.fadeAlpha(to: 0.0, duration: 0.2)]),
        
                                     SKAction.run {
             node.removeFromParent()
             
             self.astroCapturedHandler?()
             
         }
         ])
         
         )
         
         
         node.physicsBody = nil
             
        
         
     }
    }
    
    func update(_ currentTime: TimeInterval){
        
        for enemy in enemies {
            if let playerPhysicsBody = shipReference.physicsBody {
            enemy.detectIfPlayerVisibleToNode(playerPosition: shipReference.position, playerVelocity: playerPhysicsBody.velocity)
            }
        }
        
    }
   
}
