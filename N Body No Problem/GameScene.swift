//
//  GameScene.swift
//  N Body No Problem
//
//  Created by Jorge Torres on 4/13/24.
//

import SpriteKit
import GameplayKit




class GameScene: SKScene, SKPhysicsContactDelegate {

    
    var shipHasBeenPlaced = false
    var followShip = false
    var shipReference = SKSpriteNode.init()
    var cameraReference = SKCameraNode()
    var screenSizeReference = CGSize()
    var starReference : [SKSpriteNode] = []
    var planetPoints : [(position: CGPoint, radius: CGFloat)] = []
    var initialTouchLocation: CGPoint?
    var missleMode = false
    var updateDots = false
    var forceVector = CGVector()
    var frameSkipper = 0
    var savedVelocity : CGVector = CGVector(dx: 0, dy: 0)
    var savedAngularVelocity = 1.0
    var lineNode: SKShapeNode?
    var nodesArray: [SKNode] = []
    var earchReference = SKSpriteNode()
    var dots = [SKSpriteNode]()
    let dotSpacing: CGFloat = 40
    var movevmeentreleaseLocation : CGPoint?
    let gridSize: CGSize = CGSize.init(width: 30, height: 100)
    var planets = [(position: CGPoint, radius: CGFloat, strength: CGFloat)]()
    var gridBackground: SKSpriteNode!
    var planetPositions: [CGPoint] = []
    var planetRadii: [CGFloat] = []
    var gravityField: SKFieldNode!
    var dotNodes: [SKSpriteNode] = []


    
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = CGVector(dx:0, dy: 0);
        self.physicsWorld.contactDelegate = self

        self.lineNode = SKShapeNode()
        self.lineNode?.strokeColor = .gray
        self.lineNode?.lineWidth = 4.0
        self.addChild(lineNode!)
        
        shipReference = SKSpriteNode.init(imageNamed: "spaceship")
        shipReference.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize.init(width: 15, height: 30))
        shipReference.physicsBody?.fieldBitMask = PhysicsCategory.gravityStar
        shipReference.physicsBody!.categoryBitMask = PhysicsCategory.player
        shipReference.physicsBody!.mass = 100
        shipReference.physicsBody?.contactTestBitMask =  PhysicsCategory.gravityStar | PhysicsCategory.earthplanet
        shipReference.position =  CGPoint.init(x: 0, y: -200)
        shipReference.physicsBody?.isDynamic = false
        self.addChild(shipReference)
        
        
        SharedInfo.SharedInstance.screenSize = self.size
    
        self.view?.showsDrawCount = true
        screenSizeReference = self.view!.safeAreaLayoutGuide.layoutFrame.size
        self.backgroundColor = .black
        
        self.camera = cameraReference
        self.addChild(cameraReference)
        
        cameraReference.position.y = screenSizeReference.height / 4
       
        
        let menuBKG = BottomMenuBar()
        menuBKG.setup()
        cameraReference.addChild(menuBKG)
        
        menuBKG.missileButton?.action = toggleMissileMode
        
        menuBKG.zPosition = 100
        let background = SKSpriteNode.init(texture: nil, color: UIColor.black, size: CGSize.init(width: self.size.width, height: self.size.height * 3 ))
        background.lightingBitMask = 1
        background.zPosition = -1
        self.addChild(background)
        
        setupDots(withSpacing: dotSpacing)
   
        //self.scene?.view?.showsPhysics = true
        //self.scene?.view?.showsFields = false
        
        let lightNode = SKLightNode()
        lightNode.categoryBitMask = 1
        lightNode.falloff = 4.5
        shipReference.addChild(lightNode)
        
        
        self.updateSceneNodes()
        
    }
    
    
    func updateSceneNodes(){
        for node in self.children {
            if node.name == "gravitystar"
            {

                node.physicsBody!.categoryBitMask =  PhysicsCategory.gravityStar
              
                                        
                    starReference.append(node as! SKSpriteNode)
                  
               // (node as! SKSpriteNode).lightingBitMask = 1
                    planets.append((position: node.position, radius: 200, strength: 1500))
                
               // node.run(SKAction.repeatForever(SKAction.sequence([SKAction.moveBy(x: 400, y: 0, duration: 5), SKAction.moveBy(x: -400, y: 0, duration: 5)])))
                
                
                let lightNode = SKLightNode()
                lightNode.categoryBitMask = 1
                lightNode.falloff = 1
                node.addChild(lightNode)
                
                let dotTexture = SKTexture.init(imageNamed: "sybdit")
                    
                    for i in 0...7 {
                        
                        if let spark = SKEmitterNode(fileNamed: "spark") {
                            
                            spark.particleTexture = dotTexture
                            node.addChild(spark)
                            spark.targetNode = node
                            spark.emissionAngle = CGFloat(degreesToradians( Float(i) * 45 ))
                            
                        }
                    }
                    
                      
                
                for child in node.children {
                    if child.name == "SunGravityField" {
                        gravityField = child as! SKFieldNode
                    }
                }
                
            } else if node.name == "earth" {
                
                earchReference = node as! SKSpriteNode
                node.physicsBody!.categoryBitMask =  PhysicsCategory.earthplanet

                
            } else if node.name == "astro" {
                
                let dotNode = DotNode(color: .clear, size: CGSize(), initialPosition: node.position)
                dotNode.size = (node as! SKSpriteNode).size
                dotNode.texture = (node as! SKSpriteNode).texture
                node.alpha = 0
                self.addChild(dotNode)
                dots.append(dotNode)
            } else if node.name == "alien" {
                
                
                node.physicsBody = SKPhysicsBody(rectangleOf: CGSize.init(width: 100, height: 100))
                node.physicsBody!.affectedByGravity = false
                node.physicsBody!.pinned = true
                node.physicsBody!.categoryBitMask = PhysicsCategory.enemy
                node.physicsBody!.contactTestBitMask = PhysicsCategory.playerProjectile
                node.physicsBody?.usesPreciseCollisionDetection = true
                node.physicsBody?.allowsRotation = false
                node.physicsBody!.isDynamic = true
                
            }
        }
        
    }

    func updateLine() {
        let path = CGMutablePath()
        guard let firstNode = nodesArray.first else { return }
        path.move(to: firstNode.position)
        if updateDots {
               // Clear existing dots from the scene
               for dot in dotNodes {
                   dot.removeFromParent()
               }
               dotNodes = []

               // Prepare to collect new dots
               var nextNode: SKNode? = nil  // This will be the node each dot points to

               for (index, node) in nodesArray.enumerated().reversed() {
                   if dotNodes.count < 20 {
                       if nodesArray.indices.contains(index - 1 ) {
                           nextNode = nodesArray[index - 1]
                       }
                       let dot = addDot(at: node.position, nextNode:  nextNode ?? node)
                       dotNodes.append(dot)
                   }
                   nextNode = node  // Update nextNode to the current node for the next iteration
               }

               updateDots = false
           }
      
       }
    
 

    
    
    func setupDots(withSpacing: CGFloat ) {
        
        for doto in dots {
            doto.removeFromParent()
        }
        
        dots = []
        
        for x in 0..<Int(gridSize.width) {
            for y in 0..<Int(gridSize.height) {
                let initialPosition = CGPoint(x: CGFloat(x) * withSpacing + self.frame.midX - withSpacing * CGFloat(gridSize.width) / 2,
                                              y: CGFloat(y) * withSpacing + self.frame.midY - withSpacing * CGFloat(gridSize.height) / 2)
                let dot = DotNode(color: .white, size: CGSize(width: 10, height: 10), initialPosition: initialPosition)
                addChild(dot)
                dots.append(dot)
                dot.lightingBitMask = 1
            }
        }
        
        
        
    }

    
    func updateDotPositions() {
        for dot in dots as! [DotNode] {
            var totalShift = CGVector(dx: 0, dy: 0)
            
            var totalDisplacement = 0.0
            for planet in planets {
                let dx = planet.position.x - dot.originalPosition.x
                let dy = planet.position.y - dot.originalPosition.y
                let distance = sqrt(dx * dx + dy * dy)
                
                if distance < planet.radius && distance > 0 {  // Ensure distance is not zero to avoid division by zero
                    var displacementFactor = planet.strength * (1 - (distance / planet.radius))
                    if (displacementFactor > distance){
                        displacementFactor = distance
                    }
                    totalShift.dx += (dx / distance) * displacementFactor
                    totalShift.dy += (dy / distance) * displacementFactor
                    
                    let displacementratio = displacementFactor / distance
                    totalDisplacement = displacementratio + totalDisplacement
                    
                    // Apply the calculated shift from the original position
                   
                    
                }}
            
            dot.setScale(1 - totalDisplacement)

            
            dot.position = CGPoint(x: dot.originalPosition.x + totalShift.dx,
                                   y: dot.originalPosition.y + totalShift.dy)

         
        }
    }


    
    func degreesToradians(_ degrees: Float) -> Float {
          return degrees * .pi / 180
    }
    


    
    func addDot(at position: CGPoint, nextNode: SKNode) -> SKSpriteNode {
        let dot = SKSpriteNode(color: .white, size: CGSize(width: 20, height: 10))  // Appearance as a line
        dot.position = position
        dot.lightingBitMask = 2
        let dx = nextNode.position.x - position.x
        let dy = nextNode.position.y - position.y
        let angle = atan2(dy, dx)
        dot.zRotation = angle  // Set rotation to point towards the next node

        addChild(dot)
        return dot
    }
    
  
       
    func applyGravityWellEffects(planets: [(position: CGPoint, radius: CGFloat)]) {
        let shaderCode = """
        void main() {
            vec2 newCoord = v_tex_coord;
            float pullStrength = 0.0;
            float radius = 0.0;
            vec2 diff = vec2(0.0, 0.0);
            float dist = 0.0;

            \(planets.enumerated().map { index, planet in
                let position = CGPoint(x: planet.position.x / gridBackground.size.width, y: planet.position.y / gridBackground.size.height )
                let radius = Float(planet.radius / gridBackground.size.width)
                return """
                radius = \(radius); // Normalize radius for planet \(index)
                diff = v_tex_coord - vec2(\(position.x), \(position.y)); // Vector from pixel to center of planet \(index)
                dist = length(diff); // Distance from center for planet \(index)

                if (dist < radius) {
                    pullStrength = 0.12 * pow((radius - dist) / radius, 2.0); // Calculate pull strength for planet \(index)
                    newCoord.y -= pullStrength * -1; // Apply pull downwards
                }
                """
            }.joined(separator: "\n"))

            gl_FragColor = texture2D(u_texture, newCoord);
        }
        """

        let shader = SKShader(source: shaderCode)
        gridBackground.shader = shader
    }
    
    
    func setupBackground() {
          let gridSize = CGSize(width: size.height, height: size.height )
          UIGraphicsBeginImageContextWithOptions(gridSize, false, 0.0)
          guard let context = UIGraphicsGetCurrentContext() else { return }

          context.setLineWidth(1)
          context.setStrokeColor(UIColor.white.cgColor)
          
          let gridStep: CGFloat = 40
          for x in stride(from: 0, to: gridSize.width, by: gridStep) {
              for y in stride(from: 0, to: gridSize.height, by: gridStep) {
                  context.move(to: CGPoint(x: x, y: 0))
                  context.addLine(to: CGPoint(x: x, y: gridSize.height))
                  context.move(to: CGPoint(x: 0, y: y))
                  context.addLine(to: CGPoint(x: gridSize.width, y: y))
              }
          }
          context.strokePath()
          let image = UIGraphicsGetImageFromCurrentImageContext()
          UIGraphicsEndImageContext()

          gridBackground = SKSpriteNode(texture: SKTexture(image: image!))
          gridBackground.position = CGPoint(x: frame.midX, y: frame.midY)
          addChild(gridBackground)
        gridBackground.zPosition = -1
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
                  
            
            print("Collision detected")
            
            self.shipReference.removeFromParent()
            
            
            
            if let scene = SKScene(fileNamed: "Level" + self.name!)  {
                   scene.scaleMode = .aspectFill
                   view?.presentScene(scene, transition: SKTransition.fade(withDuration: 1.0))
               }
            
        } else if ((secondBody.categoryBitMask == PhysicsCategory.playerProjectile && firstBody.categoryBitMask == PhysicsCategory.enemy) || (secondBody.categoryBitMask == PhysicsCategory.enemy && firstBody.categoryBitMask == PhysicsCategory.playerProjectile)) {
            
            secondBody.node!.removeFromParent()
            firstBody.node!.removeFromParent()
            
            
        }
        
        else if ( secondBody.categoryBitMask == PhysicsCategory.player && firstBody.categoryBitMask == PhysicsCategory.earthplanet || secondBody.categoryBitMask == PhysicsCategory.earthplanet && firstBody.categoryBitMask == PhysicsCategory.player ) {
            
            let calcuatedNumber = Int(self.name!)! + 1
            if let scene = SKScene(fileNamed: "Level" + String(calcuatedNumber))  {
                   scene.scaleMode = .aspectFill
                   view?.presentScene(scene, transition: SKTransition.fade(withDuration: 1.0))
               }
            
        } else if ( secondBody.categoryBitMask == PhysicsCategory.whip && firstBody.categoryBitMask == PhysicsCategory.gravityStar || secondBody.categoryBitMask == PhysicsCategory.whip && firstBody.categoryBitMask == PhysicsCategory.earthplanet ) {
            
            print("dot collision")
            var count = 0
            for nodo in nodesArray {
                if let second = secondBody.node
                {
                if (nodo == secondBody.node!){
                    
                    nodesArray.remove(at: count)
                    nodo.removeAllActions()
                    nodo.removeFromParent()
                    break
                    
                }
                
                count = count + 1
                }
            }
            if count > 0 {
                for currentIndex in 0...count  {
                    
                    if let nodo = nodesArray.first {
                    nodo.removeAllActions()
                    nodo.removeFromParent()
                    nodesArray.removeFirst()
                    }
                }}
        }
        
           
           
       }
    
  
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.physicsWorld.speed = 5
        for star in starReference {
        //    star.isPaused = true
        }
        
       // earchReference.isPaused = true
        
        shipReference.physicsBody?.fieldBitMask = PhysicsCategory.none
        savedVelocity = shipReference.physicsBody!.velocity
        savedAngularVelocity = shipReference.physicsBody!.angularVelocity
        
        shipReference.physicsBody?.isDynamic = false
        shipReference.run(SKAction.scale(to: 1.0, duration: 0.1))
        
        if let touch = touches.first {
            initialTouchLocation = touch.location(in: self)
            
            if (shipHasBeenPlaced == false) {
                
             
                shipHasBeenPlaced = true
                if let fireParticles = SKEmitterNode(fileNamed: "Smoke") {
                         // fireParticles.position = CGPoint(x: size.width / 2, y: size.height / 2)
                    shipReference.addChild(fireParticles)
                    fireParticles.targetNode = self
                      }
                
                
            }
            
        }
        
        
        
        
    }
    
    
 
    
    func toggleMissileMode(_ button: JKButtonNode){
        
        if missleMode == false {
            missleMode = true
            
        } else if missleMode == true {
            missleMode = false
        }
        
    }
    
    
    func launchMissile(){
        
        
        
        let missile = SKSpriteNode.init(color: .blue, size: CGSize.init(width: 5, height: 5  ))
        missile.position = self.shipReference.position
        
        missile.physicsBody = SKPhysicsBody(rectangleOf: CGSize.init(width: 10, height: 10))
        missile.physicsBody?.affectedByGravity = false
        missile.physicsBody?.categoryBitMask = PhysicsCategory.playerProjectile
        missile.physicsBody?.collisionBitMask = PhysicsCategory.none
        missile.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        missile.physicsBody?.fieldBitMask = PhysicsCategory.gravityStar
        missile.physicsBody?.usesPreciseCollisionDetection = true
        missile.physicsBody?.isDynamic = true
        missile.physicsBody?.fieldBitMask = PhysicsCategory.none
       
        missile.physicsBody?.velocity = self.savedVelocity
        missile.physicsBody?.angularVelocity = self.savedAngularVelocity
        
        
        self.applyForce(to: missile, vector: self.forceVector)

        
        self.addChild(missile)
        
        
        
    }
    

   
       override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
           if let touch = touches.first, let initialLocation = initialTouchLocation {
               
             
               //updateDots = true
             
               
             
             
               
               
               movevmeentreleaseLocation = touch.location(in: self)

               let forceVector = CGVector(dx: self.initialTouchLocation!.x - self.movevmeentreleaseLocation!.x, dy: self.initialTouchLocation!.y - self.movevmeentreleaseLocation!.y)
               
               
               
              
               
               self.removeAction(forKey: "NodePattern")
               self.run(SKAction.repeatForever(SKAction.sequence([  SKAction.run {
                   
                   
                   var color = UIColor.white
                   if(self.missleMode){
                       color = UIColor.blue
                   }
                   
                   
                   let node = SKSpriteNode.init(texture: nil, color: color, size: CGSize.init(width: 50, height: 50))
                   
                   
                   self.addChild(node)

                   node.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize.init(width: 15, height: 30))
                   node.physicsBody?.fieldBitMask = PhysicsCategory.gravityStar
                   node.physicsBody?.isDynamic = true
                  // node.run(SKAction.scale(to: 0.05, duration: 0.1))
                   
                   node.physicsBody?.collisionBitMask = PhysicsCategory.none
                   node.physicsBody?.contactTestBitMask = PhysicsCategory.gravityStar | PhysicsCategory.earthplanet
                   node.physicsBody?.categoryBitMask = PhysicsCategory.whip
                   
                   if(self.missleMode){
                   node.physicsBody!.mass = 100
                   } else {
                       node.physicsBody!.mass = 50

                   }
                   
                   node.physicsBody!.velocity = self.savedVelocity
                   node.physicsBody!.angularVelocity = self.savedAngularVelocity
                   node.position = self.shipReference.position
                   
                   node.alpha = 0.0
                   self.nodesArray.append(node)
                   
                   node.run(SKAction.sequence([SKAction.wait(forDuration: 0.6), SKAction.run {
                      
                       if let nodo =  self.nodesArray.first {
                        
                               node.removeFromParent()
                           
                               self.nodesArray.removeFirst()
                          
                       }
                       
                   }]))
                   
                  
                 

                   self.applyForce(to: node, vector: forceVector)
                   
                 
                   
               }, SKAction.wait(forDuration: 0.016)])), withKey: "NodePattern")
               

               
              

               
               // Optionally, update something on the screen to indicate the pull direction and force
           }
       }
  
 
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.physicsWorld.speed = 0.5
        
        
        for dot in nodesArray {
            dot.removeAllActions()
            dot.removeFromParent()
            
        }
        
        for dot in dotNodes {
            dot.removeFromParent()
        }
        
    
         nodesArray = []
        
         self.removeAction(forKey: "NodePattern")
        if let touch = touches.first, let initialLocation = initialTouchLocation {
            
            
            if !missleMode {
             followShip = true
            let releaseLocation = touch.location(in: self)
            forceVector = CGVector(dx: initialLocation.x - releaseLocation.x, dy: initialLocation.y - releaseLocation.y)
            
            shipReference.physicsBody?.fieldBitMask =  PhysicsCategory.gravityStar
            shipReference.physicsBody?.categoryBitMask = PhysicsCategory.player
            shipReference.physicsBody?.collisionBitMask = PhysicsCategory.none
            shipReference.physicsBody?.isDynamic = true
            shipReference.run(SKAction.scale(to: 0.05, duration: 0.01))
            
            shipReference.physicsBody!.velocity = savedVelocity
            shipReference.physicsBody!.angularVelocity = savedAngularVelocity
            
            
            shipReference.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
                
                let lazerBullet = SKSpriteNode.init(color: .red, size: CGSize.init(width: 5, height: 5  ))
                lazerBullet.position = self.shipReference.position
                
                lazerBullet.physicsBody = SKPhysicsBody(rectangleOf: CGSize.init(width: 10, height: 10))
                lazerBullet.physicsBody?.affectedByGravity = false
                lazerBullet.physicsBody?.categoryBitMask = PhysicsCategory.playerProjectile
                lazerBullet.physicsBody?.collisionBitMask = PhysicsCategory.none
                lazerBullet.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
                lazerBullet.physicsBody?.usesPreciseCollisionDetection = true
                lazerBullet.physicsBody?.isDynamic = true
                lazerBullet.physicsBody?.fieldBitMask = PhysicsCategory.none
                lazerBullet.run(SKAction.repeatForever(SKAction.move(by: self.shipReference.physicsBody!.velocity, duration: 0.1)))
                
                
                
                    //  self.applyForce(to: lazerBullet, vector: self.forceVector)

                
                self.addChild(lazerBullet)
                
                
            }, SKAction.wait(forDuration: 0.2) ])), withKey: "Lazers")
            
            applyForce(to: shipReference, vector: forceVector)
            } else {
                
                
                launchMissile()
                missleMode = false
            }
        }
        
        for star in starReference {
            //star.isPaused = false
        }
        
       // earchReference.isPaused = false
        
        
    }
    
    

    
    func applyForce(to sprite: SKSpriteNode, vector: CGVector, _ multipler: CGFloat = 100.0) {
        
        let impulseVector = CGVector(dx: vector.dx * multipler, dy: vector.dy * multipler ) // Adjust multiplier as needed
       // sprite.physicsBody?.isDynamic = true
        sprite.physicsBody?.applyImpulse(impulseVector)
    }
   
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        
        
       
        
        if (followShip && shipReference.position.y > screenSizeReference.height / 4  ) {
            // Called before each frame is rendered
           
            cameraReference.position.y = shipReference.position.y
        }
        
        if (shipReference.position.x > screenSizeReference.width  - 200 || shipReference.position.x < -screenSizeReference.width  + 200  ) {
            
            let amountInitial = shipReference.position.x / (screenSizeReference.width )
            var amount = 0.0
            if (amountInitial < 0.0) {
                amount = amountInitial * -1
            } else {
                amount = amountInitial
            }
            cameraReference.removeAllActions()

            cameraReference.setScale( amount + 0.5)
             
       

            
        } else {
             
                cameraReference.run(SKAction.scale(to: 1.0, duration: 1))
            
        }
        
  
            planets = []

            for star in starReference {
        
                planets.append((position: CGPoint.init(x: star.position.x, y: star.position.y - 20) , radius: 350, strength: 100))

            
          
            }
        
            
        planets.append((position: earchReference.position , radius: 50, strength: 50))
           // applyGravityWellEffects(planets: planetPoints)
        
      
        if frameSkipper % 1 == 0 {
            
            updateDots = true
            updateLine()
            updateDotPositions()
            frameSkipper = 0
        }
        frameSkipper = frameSkipper + 1
        
    }
    
    
}
