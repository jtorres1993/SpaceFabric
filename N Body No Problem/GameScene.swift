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
        
        physicsWorld.gravity = CGVector(dx:0, dy: 0);
        self.physicsWorld.contactDelegate = self

        self.lineNode = SKShapeNode()
        self.lineNode?.strokeColor = .gray
        self.lineNode?.lineWidth = 4.0
        self.addChild(lineNode!)
        
        shipReference = SKSpriteNode.init(imageNamed: "spaceship")
        shipReference.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize.init(width: 10, height: 10))
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
        let background = SKSpriteNode.init(imageNamed: "gradientbkg")
        background.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 5),
                                                                 
                                                                 SKAction.run {
            background.run(SKAction.colorize(with: self.colors[self.backgroundColorIndex], colorBlendFactor: 0.5, duration: 5))
        }
                                                                
                                                                
                                                             , SKAction.run {
            if(self.backgroundColorIndex < self.colors.count - 1) {
                self.backgroundColorIndex = self.backgroundColorIndex + 1} else {
                    self.backgroundColorIndex = 0
                }
        }])))
            
            
        background.setScale(3.0)
        background.lightingBitMask = 1
        background.zPosition = -1
        self.addChild(background)
        
        dotGridManager.setupDots( scene: self)
   
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
                planets.append((position: node.position, radius: 200, strength: 1500))
            
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
                    }
                }
                
            } else if node.name == "earth" {
                
                earchReference = node as! SKSpriteNode
                node.physicsBody!.categoryBitMask =  PhysicsCategory.earthplanet

                
            } else if node.name == "astro" {
                
               
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
        dot.lightingBitMask = 2
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
         statisMode = true

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
    

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let initialLocation = initialTouchLocation {

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
            star.isPaused = false
        }
        
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
            if(!statisMode){
            self.dotGridManager.updateDotPositions(planets: self.planets)
            }
            frameSkipper = 0
        }
        frameSkipper = frameSkipper + 1
        
    }
    
}
