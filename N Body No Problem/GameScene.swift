import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    
    var shipHasBeenPlaced = false
    let soundHandler = SoundHandler()
    let backgroundHandler = BackgroundHandler()
    let completion = LevelCompleteMenu()
    var shipReference = MotherShip()
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
    var dotNodes: [SKSpriteNode] = []
    var dotGridManager = DotGridManager()
    let cameraZoomSpeed = 0.05

   
    
    var initialEnemeyPosition : CGPoint = CGPoint.zero
    
    override func didMove(to view: SKView) {
        
        self.addChild(soundHandler)
        //soundHandler.playInitialSound()
        
        self.physicsWorld.contactDelegate = self

        screenSizeReference = self.view!.safeAreaLayoutGuide.layoutFrame.size
        SharedInfo.SharedInstance.screenSize = self.size
        setSceneOptions()
       
        self.backgroundColor = SharedInfo.SharedInstance.backgroundColor
        
        let menuBKG = BottomMenuBar()
        menuBKG.setup()
        menuBKG.cameraButton?.action = zoomTogglePressed
        menuBKG.zPosition = 100
        
        self.camera = cameraReference
        self.addChild(cameraReference)
        
        
        cameraReference.position.y = screenSizeReference.height / 4
        cameraReference.addChild(menuBKG)
        cameraReference.setScale(1.0)

        self.addChild(backgroundHandler)
        
        self.addChild(dotGridManager)
        dotGridManager.setupDots( scene: self, withCameraPos: cameraReference.position)
  
        self.run(SKAction.sequence([SKAction.wait(forDuration: 1.5), SKAction.run {
            
          //  self.addEnemyNodes()
            
            self.updateSceneNodes()
         

        }]))
        
        physicsWorld.gravity = CGVector(dx:0, dy: 0);
        self.physicsWorld.speed = 0.01

        completion.setup()
        completion.continueButton.action = self.nextLevelButtonPressed
        
    }
    
    var isCameraZoomToggled = false
    
    func addEnemyNodes(){
        
        let enemey = SKSpriteNode.init(imageNamed: "redtriangle")
        enemey.setScale(0.5)
        enemey.position.y = self.size.height / 2
        enemey.name = "Enemigo"
        self.addChild(enemey)
        
    }
    
    func setSceneOptions(){
        self.view?.showsDrawCount = true
        self.scene?.view?.showsPhysics = true
        //self.scene?.view?.showsFields = false
        
    }
    
    func zoomTogglePressed(_ button: JKButtonNode){
        
        
        if(isCameraZoomToggled){
           // cameraReference.run(SKAction.scale(to: 1.0, duration: cameraZoomSpeed))
            //cameraReference.run(SKAction.moveBy(x: 0, y: -self.size.height / 2, duration: cameraZoomSpeed))
            cameraReference.setScale(2.0)
           // cameraReference.position.y = cameraReference.position.y - self.size.height / 2
            isCameraZoomToggled = false
        } else {
           // cameraReference.run(SKAction.scale(to: 2.0, duration: cameraZoomSpeed))
            //cameraReference.run(SKAction.moveBy(x: 0, y: self.size.height / 2, duration: cameraZoomSpeed))
            
            cameraReference.setScale(1.0)
          //  cameraReference.position.y = cameraReference.position.y + self.size.height / 2
            isCameraZoomToggled = true
        }
    }
    
    func updateSceneNodes(){
        for node in self.children {
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
                
                self.initialEnemeyPosition =  node.position
                 
                 
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
                        node.position = self.initialEnemeyPosition
                    }
                ])))
                
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
        
        //node.addChild(shape2)
        
            
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
                       let dot = self.dotGridManager.addDot(at: node.position, nextNode:  nextNode ?? node)
                       dotNodes.append(dot)
                   }
                   nextNode = node  // Update nextNode to the current node for the next iteration
               }

               updateDots = false
           }
      
       }
    
    

    
    

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
            
            
            //shipReference.physicsBody!.isDynamic = false
            
           // completion.setup()
            
      //  self.cameraReference.addChild(completion)
           
            
            
        } else if ( secondBody.categoryBitMask == PhysicsCategory.whip && firstBody.categoryBitMask == PhysicsCategory.gravityStar ) {
            
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
        }  else if ( secondBody.categoryBitMask == PhysicsCategory.player && firstBody.categoryBitMask == PhysicsCategory.astronaut || secondBody.categoryBitMask == PhysicsCategory.astronaut && firstBody.categoryBitMask == PhysicsCategory.player )  {
            
            let node =  secondBody.node!
            node.run(SKAction.sequence([SKAction.group([
                
                SKAction.scale(to: 1.3, duration: 0.2),
                SKAction.fadeAlpha(to: 0.0, duration: 0.2)]),
           
                                        SKAction.run {
                node.removeFromParent()
            }
            ])
            
            )
            
            
            
            
            
            node.physicsBody = nil
                
           // secondBody.node?.run(SKAction.scale(to: 5, duration: 0.3))
            
        }
           
       }
  
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         statisMode = true
        
        shipReference = MotherShip.init(imageNamed: "spaceship")
        shipReference.setup()
        
        
        
        shipReference.position = earchReference.position
        self.addChild(shipReference)
         
         
        
     //   self.run(scifiwepsound)
        
        
        
        self.physicsWorld.speed = 5
        for star in starReference {
                star.isPaused = true
        }
        for node in self.children {
            if (node.name == "Enemigo") {
                node.isPaused = true
                node.physicsBody!.isDynamic = false 
            }
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
        for node in self.children {
            if (node.name == "Enemigo") {
                node.isPaused = false
                node.physicsBody!.isDynamic = true
            }
        }
        
        let sound = SKAction.playSoundFileNamed("blast-37988", waitForCompletion: false)
      //  self.run(sound)
        
        
        statisMode = false

        self.physicsWorld.speed = 0.25
        
        
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
           
          //  cameraReference.position.y = shipReference.position.y
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
                // cameraReference.removeAllActions()
            //cameraReference.setScale( amount + 0.5)
            
        } else {
             
               // cameraReference.run(SKAction.scale(to: 1.0, duration: 1))
        }
        
            planets = []

            for star in starReference {
                
                if star.parent!.name == "HolderNode"  {
                    
                    planets.append((position:  self.convert(star.position, from: star.parent!) , radius: 350, strength: 100))
                    
                } else  {
                
                planets.append((position: CGPoint.init(x: star.position.x, y: star.position.y - 20) , radius: 350, strength: 100))
                }
            }
        
            
        planets.append((position: earchReference.position , radius: 50, strength: 50))
           // applyGravityWellEffects(planets: planetPoints)
        
      
        if frameSkipper % 3 == 0 {
            
            updateDots = true
            updateLine()
            if(!statisMode){
             
                self.dotGridManager.updateDotPositions(planets: self.planets, playerPos: shipReference.position)
            }
            frameSkipper = 0
            
            calculateLockOn()
        }
        frameSkipper = frameSkipper + 1
        
    }
    
    
    func calculateLockOn(){
        
        for shipnode in self.children
        {
         
            if shipnode.name == "ship"
            {
                for enemey in self.children{
                    if enemey.name == "Enemigo"{
                        
                        let distanceTo = distanceBetweenNodes(nodeA: shipnode, nodeB: enemey)
                        
                        
                        //Close to enemey detection logic
                        /*
                        if distanceTo < 200 {
                            
                            
                            let shipReference = (shipnode as! MotherShip)
                            if(shipReference.isLockedOn == false ) {
                                shipReference.isLockedOn = true
                                shipnode.physicsBody!.isDynamic = false
                                enemey.physicsBody!.isDynamic = false
                            
                                let angle = angleBetweenNodes(nodeA: shipnode, nodeB: enemey)
                                let normalizedDirection = normalizedDirection(from: shipnode.position, to: enemey.position)
                            
                            
                                let directionVector = CGVector(dx: cos(angle) * speed, dy: cos(angle) * speed)
                            
                                self.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
                                
                                    let lazerBullet = SKSpriteNode.init(color: .red, size: CGSize.init(width: 10, height: 5  ))
                                    lazerBullet.position = shipnode.position
                                
                                    lazerBullet.physicsBody = SKPhysicsBody(rectangleOf: CGSize.init(width: 10, height: 10))
                                    lazerBullet.physicsBody?.affectedByGravity = false
                                    lazerBullet.physicsBody?.categoryBitMask = PhysicsCategory.playerProjectile
                                    lazerBullet.physicsBody?.collisionBitMask = PhysicsCategory.none
                                    lazerBullet.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
                                    lazerBullet.physicsBody?.usesPreciseCollisionDetection = true
                                    lazerBullet.physicsBody?.isDynamic = true
                                    lazerBullet.physicsBody?.fieldBitMask = PhysicsCategory.none
                                
                                    lazerBullet.run(SKAction.repeatForever(SKAction.move(by: CGVector(dx: normalizedDirection.x, dy: normalizedDirection.y), duration: 0.01)))
                                
                        

                                
                                self.addChild(lazerBullet)
                                
                                
                            }, SKAction.wait(forDuration: 1.0) ])), withKey: "Lazers")
                                
                                
                            }
                            //(shipnode as! MotherShip).lazerShoot(normalizedDirection)
                             
                        }*/
                        
                    }
                }
            }
        }
    }
    
}
