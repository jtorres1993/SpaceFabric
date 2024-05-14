import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    
    var shipHasBeenPlaced = false
    var shipReference = SKSpriteNode.init()
    var cameraReference = SKCameraNode()
    var screenSizeReference = CGSize()
    var starReference : [SKSpriteNode] = []
    var planetPoints : [(position: CGPoint, radius: CGFloat)] = []
    var initialTouchLocation: CGPoint?
    var missleMode = false
    var updateDots = false
    var followShip = false
    var forceVector = CGVector()
    var frameSkipper = 0
    var savedVelocity : CGVector = CGVector(dx: 0, dy: 0)
    var savedAngularVelocity = 1.0
    var lineNode: SKShapeNode?
    var nodesArray: [SKNode] = []
    var earchReference = SKSpriteNode()
    var movevmeentreleaseLocation : CGPoint?
    var planets = [(position: CGPoint, radius: CGFloat, strength: CGFloat)]()
    var gridBackground: SKSpriteNode!
    var planetPositions: [CGPoint] = []
    var dotNodes: [SKSpriteNode] = []
    var dotGridManager = DotGridManager()
    var backgroundColorIndex = 0
    let colors = [UIColor.red, UIColor.yellow, UIColor.blue, UIColor.green, UIColor.cyan, UIColor.gray, UIColor.white, UIColor.black, UIColor.magenta, UIColor.orange]
    
    override func didMove(to view: SKView) {
        
      //  let scifiwepsound = SKAction.playSoundFileNamed("Galactic Swing (Singularity Mix)", waitForCompletion: false)
       
       // run(scifiwepsound)
        physicsWorld.gravity = CGVector(dx:0, dy: 0);
        self.physicsWorld.contactDelegate = self

        self.lineNode = SKShapeNode()
        self.lineNode?.strokeColor = .gray
        self.lineNode?.lineWidth = 4.0
        self.addChild(lineNode!)
        screenSizeReference = self.view!.safeAreaLayoutGuide.layoutFrame.size

        
        shipReference = SKSpriteNode.init(imageNamed: "spaceship")
        shipReference.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize.init(width: 10, height: 10))
        shipReference.name = "ship"
        shipReference.physicsBody?.fieldBitMask = PhysicsCategory.gravityStar
        shipReference.physicsBody!.categoryBitMask = PhysicsCategory.player
        shipReference.physicsBody!.mass = 100
        shipReference.physicsBody?.contactTestBitMask =  PhysicsCategory.gravityStar | PhysicsCategory.earthplanet
        shipReference.position =  CGPoint.init(x: 0, y: -200  - self.screenSizeReference.height )
        shipReference.physicsBody?.isDynamic = false
        velocityLine.anchorPoint = CGPoint.init(x: 0.5, y: 0.0)
        shipReference.addChild(velocityLine)
        
        
        SharedInfo.SharedInstance.screenSize = self.size
    
        self.view?.showsDrawCount = true
        self.backgroundColor = .black
        
        self.camera = cameraReference
        self.addChild(cameraReference)
        
        cameraReference.position.y = screenSizeReference.height / 4
       
        
        let menuBKG = BottomMenuBar()
        menuBKG.setup()
        //cameraReference.addChild(menuBKG)
        
        menuBKG.missileButton?.action = toggleMissileMode
        
        menuBKG.zPosition = 100
        let background = SKSpriteNode.init(texture: nil , color: SharedInfo.SharedInstance.backgroundColor , size:SharedInfo.SharedInstance.screenSize )
        self.backgroundColorIndex = Int.random(in: 1...9)
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
            
        background.setScale(3.0)
        //background.lightingBitMask = 1
        background.zPosition = -1
        self.addChild(background)
        
        dotGridManager.setupDots( scene: self, withCameraPos: cameraReference.position)
   
        //self.scene?.view?.showsPhysics = true
        //self.scene?.view?.showsFields = false
        
        let lightNode = SKLightNode()
        lightNode.categoryBitMask = 1
        lightNode.falloff = 4.5
        shipReference.addChild(lightNode)
        
        self.run(SKAction.sequence([SKAction.wait(forDuration: 1.5), SKAction.run {
            self.updateSceneNodes()
            self.addChild(self.shipReference)
            self.shipReference.run(SKAction.moveTo(y: -200, duration: 1.0))

        }]))
        
        completion.zPosition = 100
        
        completion.setup()
        completion.continueButton.action = self.nextLevelButtonPressed
        
    }
    
    
    func updateSceneNodes(){
        for node in self.children {
            if node.name == "gravitystar"
            {

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
                
                //node.addChild(shape2)
                
                let dotTexture = SKTexture.init(imageNamed: "sybdit")
                    
                    for i in 0...7 {
                        
                        if let spark = SKEmitterNode(fileNamed: "spark") {
                            
                            spark.particleTexture = dotTexture
                            node.addChild(spark)
                            spark.targetNode = node
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
                node.physicsBody!.categoryBitMask = PhysicsCategory.
                
                
               
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
    
    

    
    func addDot(at position: CGPoint, nextNode: SKNode) -> SKSpriteNode {
        let dot = SKSpriteNode(color: .white, size: CGSize(width: 20, height: 10))  // Appearance as a line
        dot.position = position
        dot.lightingBitMask = 1
        let dx = nextNode.position.x - position.x
        let dy = nextNode.position.y - position.y
        let angle = atan2(dy, dx)
        dot.zRotation = angle  // Set rotation to point towards the next node

        addChild(dot)
        return dot
    }
    
    func updateDotPosition( dot: SKSpriteNode, position: CGPoint, nextNode: SKNode){

        dot.position = position
        dot.lightingBitMask = 1
        let dx = nextNode.position.x - position.x
        let dy = nextNode.position.y - position.y
        let angle = atan2(dy, dx)
        dot.zRotation = angle  // Set rotation to point towards the next node
    }
    
    
    let completion = LevelCompleteMenu()

    func nextLevelButtonPressed(button: JKButtonNode){
        self.completion.hide()
        let calcuatedNumber = Int(self.name!)! + 1
        let scene = SKScene(fileNamed: "Level" + String(calcuatedNumber))
      
        
        self.dotGridManager.hyperSpaceNextLevelTransition(withCameraPos: self.cameraReference.position)
        
        for child in self.children {
            if (child.name != "dot"){
                
                child.run(SKAction.fadeAlpha(to: 0.0, duration: 0.3))
            }
        }
        
      
        (shipReference.childNode(withName: "trail") as! SKEmitterNode).removeAllChildren()
        (shipReference.childNode(withName: "trail") as! SKEmitterNode).removeFromParent()
        shipReference.removeAllChildren()
        shipReference.run(SKAction.fadeAlpha(to: 0.0, duration: 0.3))
        earchReference.alpha = 0.0
        
        self.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.run {
             
                scene!.scaleMode = .aspectFill
            self.view?.presentScene(scene!)
               
        }]))
        
       
        
        
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
                
        
            self.shipReference.removeFromParent()
            
            if let scene = SKScene(fileNamed: "Level" + self.name!)  {
                   scene.scaleMode = .aspectFill
                   view?.presentScene(scene, transition: SKTransition.fade(withDuration: 1.0))
               }
            
        } else if ((secondBody.categoryBitMask == PhysicsCategory.playerProjectile && firstBody.categoryBitMask == PhysicsCategory.enemy) || (secondBody.categoryBitMask == PhysicsCategory.enemy && firstBody.categoryBitMask == PhysicsCategory.playerProjectile)) {
            if let secondbody_node = secondBody.node {
                secondbody_node.removeFromParent()
            }
            if let firstbody_node = firstBody.node {
                firstbody_node.removeFromParent()
            }
            
            
        }
        
        else if ( secondBody.categoryBitMask == PhysicsCategory.player && firstBody.categoryBitMask == PhysicsCategory.earthplanet || secondBody.categoryBitMask == PhysicsCategory.earthplanet && firstBody.categoryBitMask == PhysicsCategory.player ) {
            
            
            shipReference.physicsBody!.isDynamic = false
            
           // completion.setup()
            
        self.cameraReference.addChild(completion)
           
            
            
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
   // let scifiwepsound = SKAction.playSoundFileNamed("scifiwep", waitForCompletion: false)
    

    var velocityLine = SKSpriteNode.init(color: UIColor.cyan, size: CGSize.init(width: 5, height: 15))
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         statisMode = true
        
        velocityLine.zPosition = 10

        
     //   self.run(scifiwepsound)
        
        
        
        self.physicsWorld.speed = 5
        for star in starReference {
                star.isPaused = true
        }
        
        earchReference.isPaused = true
        savedVelocity = shipReference.physicsBody!.velocity
        savedAngularVelocity = shipReference.physicsBody!.angularVelocity
        shipReference.physicsBody?.fieldBitMask = PhysicsCategory.none
        shipReference.physicsBody?.isDynamic = false
        shipReference.run(SKAction.scale(to: 1.0, duration: 0.1))
        
        if let touch = touches.first {
            initialTouchLocation = touch.location(in: self)
            
            if (shipHasBeenPlaced == false) {
                
                
                shipHasBeenPlaced = true
                if let fireParticles = SKEmitterNode(fileNamed: "Smoke") {
                    
                    fireParticles.name = "trail"
                    // fireParticles.position = CGPoint(x: size.width / 2, y: size.height / 2)
                    shipReference.addChild(fireParticles)
                    fireParticles.targetNode = self
                }}}
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
    
    func scalingFactor(fromVector vector: CGVector) -> CGFloat {
        let maxMagnitude: CGFloat = 500 // as derived above
        let magnitudeValue = magnitude(of: vector)
        let scale = 1 + (magnitudeValue / maxMagnitude) * 40
        return min(scale, 40) // Ensures the scale does not exceed 5
    }

    func magnitude(of vector: CGVector) -> CGFloat {
        return sqrt(vector.dx * vector.dx + vector.dy * vector.dy)
    }
    

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let initialLocation = initialTouchLocation {

            movevmeentreleaseLocation = touch.location(in: self)

            let forceVector = CGVector(dx: self.initialTouchLocation!.x - self.movevmeentreleaseLocation!.x, dy: self.initialTouchLocation!.y - self.movevmeentreleaseLocation!.y)
         
            let angle = atan2(forceVector.dy, forceVector.dx) - (CGFloat.pi / 2)
           // velocityLine.zRotation = angle
            
            shipReference.zRotation = angle
            
           // self.velocityLine.yScale = scalingFactor(fromVector: forceVector)
            print(forceVector)
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
                node.physicsBody?.collisionBitMask = PhysicsCategory.none
                node.physicsBody?.contactTestBitMask = PhysicsCategory.gravityStar | PhysicsCategory.earthplanet
                node.physicsBody?.categoryBitMask = PhysicsCategory.whip
                node.physicsBody!.velocity = self.savedVelocity
                node.physicsBody!.angularVelocity = self.savedAngularVelocity
                
                
                if(!self.missleMode){
                    node.physicsBody!.mass = 100
                } else {
                    node.physicsBody!.mass = 50
                }
                
                node.position = self.shipReference.position
                node.alpha = 0.0
                node.run(SKAction.sequence([SKAction.wait(forDuration: 0.6), SKAction.run {
                   
                    if let nodo =  self.nodesArray.first {
                            node.removeFromParent()
                            self.nodesArray.removeFirst()
                    }
                    
                }]))
                self.nodesArray.append(node)
               
                self.applyForce(to: node, vector: forceVector)

            }, SKAction.wait(forDuration: 0.016)])), withKey: "NodePattern")
         }
    }

    var statisMode = false
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        let sound = SKAction.playSoundFileNamed("star_man-155034", waitForCompletion: false)
        self.run(sound)
        
        
        statisMode = false

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
            shipReference.run(SKAction.scale(to: 0.25, duration: 0.01))
            
            shipReference.physicsBody!.velocity = savedVelocity
            shipReference.physicsBody!.angularVelocity = savedAngularVelocity
            
            /* Lazer firing
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
            */
            applyForce(to: shipReference, vector: forceVector)
            } else {
                
                
                launchMissile()
                missleMode = false
            }
        }
        
        for star in starReference {
            star.isPaused = false
        }
        
    }
    
        func applyForce(to sprite: SKSpriteNode, vector: CGVector, _ multipler: CGFloat = 100.0) {
        
        let impulseVector = CGVector(dx: vector.dx * multipler, dy: vector.dy * multipler )  // Adjust multiplier as needed
       // sprite.physicsBody?.isDynamic = true
        sprite.physicsBody?.applyImpulse(impulseVector)
    }
   

    override func update(_ currentTime: TimeInterval) {
        
        
        super.update(currentTime)
        
        if (followShip && shipReference.position.y > screenSizeReference.height / 4  ) {
            // Called before each frame is rendered
           
            cameraReference.position.y = shipReference.position.y
        }
        
        if (!statisMode) {
            
            if let velocity = shipReference.physicsBody?.velocity {
                   // Calculate the angle from the velocity vector
                   let angle = atan2(velocity.dy, velocity.dx) - (CGFloat.pi / 2)
                   // Adjust the sprite's rotation
                shipReference.zRotation = angle
               }
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
            if(!statisMode){
            self.dotGridManager.updateDotPositions(planets: self.planets)
            }
            frameSkipper = 0
        }
        frameSkipper = frameSkipper + 1
        
    }
    
}
