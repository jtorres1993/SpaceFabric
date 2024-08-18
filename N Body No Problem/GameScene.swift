import SpriteKit
import GameplayKit

class GameScene: SKScene {

    
    var shipHasBeenPlaced = false
    let soundHandler = SoundHandler()
    let backgroundHandler = BackgroundHandler()
    let completion = LevelCompleteMenu()
    var dotGridManager = DotGridManager()
    let trajectoryLineManager = TrajectoryLineManager()
    var shipReference = MotherShip()
    var cameraHandler = CameraHandler()
    var gameplayHandler = GameplayHandler()
    var uiHandler = UIHandler()
    var planetPoints : [(position: CGPoint, radius: CGFloat)] = []
    var initialTouchLocation: CGPoint?
    var followShip = false
    var forceVector = CGVector()
    var frameSkipper = 0
    var savedVelocity : CGVector = CGVector(dx: 0, dy: 0)
    var savedAngularVelocity = 1.0
    var movevmeentreleaseLocation : CGPoint?
    var statisMode = false
    var isCameraZoomToggled = false
    let cameraZoomSpeed = 0.05

   
    
    var initialEnemeyPosition : CGPoint = CGPoint.zero
    
    override func didMove(to view: SKView) {
        
       
        
        SharedInfo.SharedInstance.safeAreaLayoutSize = self.view!.safeAreaLayoutGuide.layoutFrame.size
        SharedInfo.SharedInstance.screenSize = self.size
        
        self.addChild(soundHandler)
        self.addChild(cameraHandler)
        self.addChild(backgroundHandler)
        self.addChild(gameplayHandler)
        self.addChild(trajectoryLineManager)
        cameraHandler.addChild(uiHandler)
        self.addChild(dotGridManager)
        uiHandler.bottomMenuBar.cameraButton?.action = self.cameraHandler.zoomTogglePressed
     

        self.physicsWorld.contactDelegate = self.gameplayHandler

        setSceneOptions()
       
        self.backgroundColor = SharedInfo.SharedInstance.backgroundColor
        
       
        
        self.camera = cameraHandler
        
       
        //soundHandler.playInitialSound()

        cameraHandler.position.y = SharedInfo.SharedInstance.safeAreaLayoutSize.height / 4
        
       
        uiHandler.setup()
        
        dotGridManager.setupDots( scene: self, withCameraPos: cameraHandler.position)
  
        self.run(SKAction.sequence([SKAction.wait(forDuration: 1.5), SKAction.run {
            
            self.gameplayHandler.updateSceneNodes(withNodes: self.children)
         

        }]))
        
        physicsWorld.gravity = CGVector(dx:0, dy: 0);
        self.physicsWorld.speed = 0.01

        completion.setup()
        completion.continueButton.action = self.nextLevelButtonPressed
        
        gameplayHandler.trajectoryLineIntersectionWithStarCallback = self.trajectoryLineManager.trajectoryLineIntersectedWithStar
         
        gameplayHandler.nextSceneLevelTriggered = self.nextLevelTriggered
        
        gameplayHandler.astroCapturedHandler = uiHandler.runCapturedAstro
        
       
        gameplayHandler.requiredAstrosToNextLevel = self.userData?["astrosRequiredForNextLevel"] as! Int
        
    }
    
   
    func setSceneOptions(){
        self.view?.showsDrawCount = true
        self.scene?.view?.showsPhysics = false
        self.scene?.view?.showsFields = false
        
    }
    
   
 
    func nextLevelButtonPressed(button: JKButtonNode){
        
        self.completion.hide()
        let calcuatedNumber = Int(self.name!)! + 1
        let scene = SKScene(fileNamed: "Level" + String(calcuatedNumber))
      
        
        self.dotGridManager.hyperSpaceNextLevelTransition(withCameraPos: self.cameraHandler.position)
        
        for child in self.children {
            if (child.name != "dot"){
                
                child.run(SKAction.fadeAlpha(to: 0.0, duration: 0.3))
            }
        }
        
      
        (shipReference.childNode(withName: "trail") as! SKEmitterNode).removeAllChildren()
        (shipReference.childNode(withName: "trail") as! SKEmitterNode).removeFromParent()
        shipReference.removeAllChildren()
        shipReference.run(SKAction.fadeAlpha(to: 0.0, duration: 0.3))
        self.gameplayHandler.earchReference.alpha = 0.0
        
        self.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.run {
             
                scene!.scaleMode = .aspectFill
            self.view?.presentScene(scene!)
               
        }]))
        
        
    }
    
    func nextLevelTriggered(){
        
        self.shipReference.removeFromParent()
        
        print(self.name!)
        if let scene = SKScene(fileNamed: "Level" + self.name!)  {
               scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 1.0))
           }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        statisMode = true
        
        shipReference = MotherShip.init(imageNamed: "spaceship")
        shipReference.setup()
        
        
        
        shipReference.position = self.gameplayHandler.earchReference.position
        self.addChild(shipReference)
         
         
        
     //   self.run(scifiwepsound)
        
        
        
        self.physicsWorld.speed = 5
        for star in self.gameplayHandler.starReference {
                star.isPaused = true
        }
        for node in self.children {
            if (node.name == "Enemigo") {
                node.isPaused = true
                node.physicsBody!.isDynamic = false 
            }
        }
        
        
        self.gameplayHandler.earchReference.isPaused = true
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
    
 
    
  


    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first, let initialLocation = initialTouchLocation {
            

            movevmeentreleaseLocation = touch.location(in: self)

            let forceVector = CGVector(dx: self.initialTouchLocation!.x - self.movevmeentreleaseLocation!.x, dy: self.initialTouchLocation!.y - self.movevmeentreleaseLocation!.y)
            
            shipReference.rotateBasedOnMovement(forceVector: forceVector)
            
         
            self.removeAction(forKey: "NodePattern")
           
            
            self.run(SKAction.repeatForever(SKAction.sequence([  SKAction.run {
                
                
                var color = UIColor.white
               
                
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
                
                
            
                node.physicsBody!.mass = 100
                
                
                node.position = self.shipReference.position
                node.alpha = 0.0
                node.run(SKAction.sequence([SKAction.wait(forDuration: 0.6), SKAction.run {
                   
                    if let nodo =  self.trajectoryLineManager.nodesArray.first {
                            node.removeFromParent()
                        self.trajectoryLineManager.nodesArray.removeFirst()
                    }
                    
                }]))
                self.trajectoryLineManager.nodesArray.append(node)
               
                self.applyForce(to: node, vector: forceVector)

            }, SKAction.wait(forDuration: 0.016)])), withKey: "NodePattern")
         }
    }

 
    
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
        
        
        for dot in self.trajectoryLineManager.nodesArray {
            dot.removeAllActions()
            dot.removeFromParent()
            
        }
        
        for dot in self.trajectoryLineManager.dotNodes {
            dot.removeFromParent()
        }
        
    
        self.trajectoryLineManager.nodesArray = []
        
         self.removeAction(forKey: "NodePattern")
        if let touch = touches.first, let initialLocation = initialTouchLocation {
            
            
         
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
                
            
          
        }
        
        for star in self.gameplayHandler.starReference {
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
        
        if (followShip && shipReference.position.y > SharedInfo.SharedInstance.safeAreaLayoutSize.height / 4  ) {
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
        
        if (shipReference.position.x > SharedInfo.SharedInstance.safeAreaLayoutSize.width  - 200 || shipReference.position.x < -SharedInfo.SharedInstance.safeAreaLayoutSize.width  + 200  ) {
            
            let amountInitial = shipReference.position.x / (SharedInfo.SharedInstance.safeAreaLayoutSize.width )
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
        
            self.gameplayHandler.planets = []

            for star in self.gameplayHandler.starReference {
                
                if star.parent!.name == "HolderNode"  {
                    
                    self.gameplayHandler.planets.append((position:  self.convert(star.position, from: star.parent!) , radius: 350, strength: 100))
                    
                } else  {
                
                    self.gameplayHandler.planets.append((position: CGPoint.init(x: star.position.x, y: star.position.y - 20) , radius: 350, strength: 100))
                }
            }
        
            
        
      
        if frameSkipper % 3 == 0 {
            
            
            self.trajectoryLineManager.updateTrajectory = true
            self.trajectoryLineManager.updateTrajectoryLine()
            if(!statisMode){
             
                self.dotGridManager.updateDotPositions(planets: self.gameplayHandler.planets, playerPos: shipReference.position)
            }
            frameSkipper = 0
            
        }
        frameSkipper = frameSkipper + 1
        
    }
    
    
    
}
