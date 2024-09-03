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
    
    var shipHasBeenPlaced = false
    var playerDestroyed: (() -> Void)? = nil
    var currentSelectedEntity = ProjectileEntity()
    var statisMode = false
    var playerIsControllingRotation = false
    
    
    
    
    
    var currentGameMode : GameModes = .ship
    
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
                
                
                
                
            } else if node.name == "startingPos" {
                earchReference = node as! SKSpriteNode
                let startingLine = SKShapeNode.init(rectOf: CGSize.init(width: SharedInfo.SharedInstance.screenSize.width, height: 1    ))
                
                startingLine.strokeColor = .white
                startingLine.position = earchReference.position
                self.addChild(startingLine)
                
                
            }
            else if node.name == "astro" {
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
                
                let attackDrone = (node as! EnemeyAttackDrone)
                
                attackDrone.setupPhysicsNode()
                enemies.append(attackDrone)
                
            }
        }
        
    }
    
    func returnCurrentGameMode()->GameModes{
        return currentGameMode
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
            
            //Enemey projectile hit player
            
            if ((secondBody.categoryBitMask == PhysicsCategory.enemeyProjectile && firstBody.categoryBitMask == PhysicsCategory.player) ) {
                
                print("secondbody was enemyproj")
            } else if (secondBody.categoryBitMask == PhysicsCategory.player && firstBody.categoryBitMask == PhysicsCategory.enemeyProjectile) {
                
                print("firstbody was enemyproj")
            }
            
            
            
            if let fireParticles = SKEmitterNode(fileNamed: "miniSparko") {
                
                fireParticles.particleColor = .red
                fireParticles.particleColorSequence = nil
                fireParticles.name = "trail"
                fireParticles.position = secondBody.node!.position
                self.addChild(fireParticles)
                fireParticles.targetNode = self
            }
            
            
            
            
            shipReference.currentHealth = shipReference.currentHealth - 1
            
            if (shipReference.currentHealth == 0) {
                firstBody.node!.removeAllActions()
                secondBody.node!.removeAllActions()
                
                for enemy in enemies {
                    enemy.stopAttackOnPlayer()
                    
                }
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
    
    
    
    func missileModeToggled(_ sender: JKButtonNode){
        
        if (currentGameMode != .missile ) {
            
            currentGameMode = .missile
            
            
            
            
            
        }  else {
            
            currentGameMode = .camera
        }
        
    }
    
    func shipModeToggled(_ sender: JKButtonNode) {
        
        if (currentGameMode != .ship
        ) {
            
            currentGameMode = .ship
            
            
            
            
            
        }  else {
            
            currentGameMode = .camera
        }
    }
    
    func update(_ currentTime: TimeInterval){
        
        for enemy in enemies {
            if let playerPhysicsBody = shipReference.physicsBody {
                enemy.detectIfPlayerVisibleToNode(playerPosition: shipReference.position, playerVelocity: playerPhysicsBody.velocity)
            }
        }
        
    }
    
    
    var hasShippedBeenLaunched = false
    
    func touchesBeganPassthrough(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        if ( !hasShippedBeenLaunched){
            if(currentGameMode == .ship){
                
                shipReference = MotherShip.init(imageNamed: "spaceship")
                shipReference.setup()
                
                
                currentSelectedEntity = shipReference
                
                self.addChild(shipReference)
                
                for star in starReference {
                    star.isPaused = true
                }
                
                
                
                earchReference.isPaused = true
                
                shipReference.physicsBody?.fieldBitMask = PhysicsCategory.none
                shipReference.physicsBody?.isDynamic = false
                shipReference.run(SKAction.scale(to: 1.0, duration: 0.1))
                
                
                if (shipHasBeenPlaced == false) {
                    
                    
                    shipHasBeenPlaced = true
                    if let fireParticles = SKEmitterNode(fileNamed: "Smoke") {
                        
                        
                        fireParticles.name = "trail"
                        shipReference.addChild(fireParticles)
                        fireParticles.targetNode = self
                    }}
                
                hasShippedBeenLaunched = true
            } else if ( currentGameMode == .missile ) {
                
                
                
                let missile = LongRangeMissile()
                
                
                shipReference.physicsBody?.fieldBitMask = PhysicsCategory.none
                shipReference.physicsBody?.isDynamic = false
                currentSelectedEntity = missile
                self.addChild(missile)
                
                for star in starReference {
                    star.isPaused = true
                }
                
                
                
                earchReference.isPaused = true
                
                missile.physicsBody?.fieldBitMask = PhysicsCategory.none
                missile.physicsBody?.isDynamic = false
                missile.run(SKAction.scale(to: 1.0, duration: 0.1))
                
                
                
                
                if let fireParticles = SKEmitterNode(fileNamed: "Smoke") {
                    
                    
                    fireParticles.name = "trail"
                    missile.addChild(fireParticles)
                    fireParticles.targetNode = self
                }
                
            }
            
            if let touch = touches.first {
                
                let touchLocation = touch.location(in: self)
                currentSelectedEntity.position.x = touchLocation.x
                
            }
            
            currentSelectedEntity.position.y = earchReference.position.y
            
        } else {
            shipReference.isPaused = true
            shipReference.physicsBody!.isDynamic = false 
            
            
        }
        
        self.statisMode = true
    }
    
    func touchesMovedPassthrough(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        
    }
    
    
    
    
    
    
    
    
    func touchesEndedPassthrough(savedVelocity: CGVector, savedAngularVelocity: CGFloat){
        
        
        self.currentSelectedEntity.recreatePhysicsBody()
        self.currentSelectedEntity.physicsBody?.isDynamic = true
        self.currentSelectedEntity.setScale(0.25) 
        
        
        
    }
    
    func shootByWireActivated( ){
        
        
        
        
        
        
    }
    
    func shootByWireAttackButtonStarted(){
        
        
        self.run(SKAction.repeatForever(
            SKAction.sequence([
            
            
        
            SKAction.run {
            
                
                let fireNode = SKSpriteNode.init(color: .white , size: CGSize.init(width: 2, height: 50))
                
                fireNode.physicsBody = SKPhysicsBody.init(rectangleOf: fireNode.size , center: CGPoint.zero)
                  
                fireNode.physicsBody?.categoryBitMask = PhysicsCategory.playerProjectile
                fireNode.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
                
                fireNode.physicsBody?.isDynamic = false
                fireNode.physicsBody?.usesPreciseCollisionDetection = true
                
                  // Rotate the sprite to face the target point
                
               
                
                
                self.addChild(fireNode)
                fireNode.position = self.shipReference.position
               
                // Calculate the direction based on the ship's zRotation
                let direction = CGVector(dx: cos(self.shipReference.zRotation + .pi / 2), dy: sin(self.shipReference.zRotation + .pi / 2))
                       
                       // Define the distance to move the node (e.g., 500 points)
                       let distance: CGFloat = 2000.0
                       let moveAction = SKAction.move(by: CGVector(dx: direction.dx * distance, dy: direction.dy * distance), duration: 1.0)
                       
                
               
                
                let angle = atan2(direction.dy, direction.dx)
                fireNode.zRotation = angle - .pi  / 2
                
                
                
                fireNode.run(moveAction)
                
                    //fireNode.run(moveAction)
                
            }, SKAction.wait(forDuration: 0.2) ] )
        ), withKey: "ShootByWireAction")
        
    }
    
    func shootByWireAttackButtonEnded(){
        
        
        self.removeAction(forKey: "ShootByWireAction")
    }
    
    func shootByWireJoystickStarted(){
        
        playerIsControllingRotation = true
       
    }
    
    func shootByWireJoystickEnded(){
        
        playerIsControllingRotation = false
       
        
    }
    
    
    
    func shootByWireJoystickHandleMovement(data: AnalogJoystickData){
        
        
        currentSelectedEntity.zRotation = data.angular
        
    }
    
    func handleSelectedObjectsZRotation(){
        
        
        if(!playerIsControllingRotation){
            if let velocity = self.currentSelectedEntity.physicsBody?.velocity {
                // Calculate the angle from the velocity vector
                let angle = atan2(velocity.dy, velocity.dx) - (CGFloat.pi / 2)
                // Adjust the sprite's rotation
                
                
                self.currentSelectedEntity.zRotation = angle
                
                
            }} else {
                
                
                
                print(shipReference.zRotation)
                //0-3.14 left up, down
                //-3.14 to 0 down, up
            }
        
    }
    
}
