import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    
   
    
    
    let soundHandler = SoundHandler()
    
    
    
    let backgroundHandler = BackgroundHandler()
    
    
    let completion = LevelCompleteMenu()
    
   
    var dotGridManager = DotGridManager()
    let trajectoryLineManager = TrajectoryLineManager()
    
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
    var isCameraZoomToggled = false
    let cameraZoomSpeed = 0.05
    
    
    
    var initialEnemeyPosition : CGPoint = CGPoint.zero
    
    override func didMove(to view: SKView) {
        
        
        
        
        SharedInfo.SharedInstance.safeAreaLayoutSize = self.view!.safeAreaLayoutGuide.layoutFrame.size
        SharedInfo.SharedInstance.screenSize = self.size
        SharedInfo.SharedInstance.safeAreaInserts =  self.view!.safeAreaInsets
        
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
        
        gameplayHandler.sameLevelTriggered = self.sameLevelTriggered
        
        gameplayHandler.astroCapturedHandler = uiHandler.runCapturedAstro
        
        
        gameplayHandler.requiredAstrosToNextLevel = self.userData?["astrosRequiredForNextLevel"] as! Int
        
        gameplayHandler.playerTookHealthDamage = uiHandler.playerTookHealthHit
        
        gameplayHandler.playerDestroyed = self.playerDestroyed
        
        uiHandler.bottomMenuBar.missileButton?.action = gameplayHandler.missileModeToggled
        
        uiHandler.bottomMenuBar.shipButton?.action =
        gameplayHandler.shipModeToggled
        
        
        uiHandler.bottomMenuBar.lazerButton?.action = self.shootByWireButtonPressed
        
      
        
        uiHandler.shootByWireMenu.movementJoystick.trackingHandler =
        self.gameplayHandler.shootByWireJoystickHandleMovement
        
        uiHandler.shootByWireMenu.movementJoystick.beginHandler =
        self.gameplayHandler.shootByWireJoystickStarted
        
        uiHandler.shootByWireMenu.movementJoystick.stopHandler =
        self.gameplayHandler.shootByWireJoystickEnded
        
        uiHandler.shootByWireMenu.shootButton.startAction =
        self.gameplayHandler.shootByWireAttackButtonStarted
        
        uiHandler.shootByWireMenu.shootButton.endAction = self.gameplayHandler.shootByWireAttackButtonEnded
        
        
        uiHandler.getCurrentGameModeHandler = self.gameplayHandler.returnCurrentGameMode 
        
        uiHandler.bottomMenuBar.cameraButton?.action = self.catchButtonAction
        uiHandler.bottomMenuBar.settingsButton?.action = self.catchButtonAction
    }
    
  
    func catchButtonAction(button: JKButtonNode) {
        
        
    }
    func shootByWireButtonPressed(button: JKButtonNode ) {
        
        gameplayHandler.shootByWireActivated()
        self.uiHandler.shootByWireActivated()
        
    }
    
  
   
    func setSceneOptions(){
        self.view?.showsDrawCount = true
        self.scene?.view?.showsPhysics = SharedInfo.SharedInstance.showPhysics 
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
        
      
        (self.gameplayHandler.shipReference.childNode(withName: "trail") as! SKEmitterNode).removeAllChildren()
        (self.gameplayHandler.shipReference.childNode(withName: "trail") as! SKEmitterNode).removeFromParent()
        self.gameplayHandler.shipReference.removeAllChildren()
        self.gameplayHandler.shipReference.run(SKAction.fadeAlpha(to: 0.0, duration: 0.3))
        self.gameplayHandler.earchReference.alpha = 0.0
        
        self.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.run {
             
                scene!.scaleMode = .aspectFill
            self.view?.presentScene(scene!)
               
        }]))
        
        
    }
    
    func sameLevelTriggered(){
        
        self.self.gameplayHandler.shipReference.removeFromParent()
        
        print(self.name!)
        if let scene = SKScene(fileNamed: "Level" + self.name!)  {
               scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 1.0))
           }
    }
    
    
    func playerDestroyed(){
        
       /* gameplayHandler.speed = 0.005
        for children in gameplayHandler.children {
            
            children.speed = 0.005
            
            for child in children.children {
                child.speed = 0.005
            }
        }
        self.scene?.speed = 0.005
        self.physicsWorld.speed = 0.00
        self.cameraHandler.speed = 100
        //self.scene?.isPaused = true
        */
        
        let savedCameraPos = self.cameraHandler.position
       // self.gameplayHandler.shipReference.speed = 0.00001
      //  let savedRotation = self.gameplayHandler.shipReference.zRotation
        // self.gameplayHandler.shipReference.physicsBody?.isDynamic = false
        self.view?.scene?.physicsWorld.speed = 0.0001
      // self.gameplayHandler.shipReference.physicsBody?.pinned = true
        //self.gameplayHandler.shipReference.zRotation  = savedRotation
        self.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.15)
,
            SKAction.run {
              
                
                self.cameraHandler.run(
                    
                    SKAction.sequence([
                    SKAction.group([
                        SKAction.scale(to: 0.75, duration: 0.10),
                    SKAction.move(to: self.gameplayHandler.shipReference.position, duration: 0.10)
                    ]),
                    
                    SKAction.run {
                        self.shakeCamera(duration: 0.16)
                    },
                    
                    SKAction.group([
                        SKAction.scale(to: 1.00, duration: 0.05),
                    SKAction.move(to: savedCameraPos, duration: 0.05)
                    ])
                    
                    ])
                )
                
               
                
                self.run(SKAction.repeat(SKAction.sequence([SKAction.run {
                    (self.gameplayHandler.shipReference.childNode(withName: "trail") as! SKEmitterNode).advanceSimulationTime(1)
                }, SKAction.wait(forDuration: 0.05)]), count: 10), withKey: "AdvanceSim")
               

                
            },
            SKAction.wait(forDuration: 0.05)
            ,
            
            SKAction.run {
                
                //Game Over, ship health is at 0
            
                if let fireParticles = SKEmitterNode(fileNamed: "Sparko") {
                    
                    
                    fireParticles.name = "trail"
                    
                    fireParticles.position = self.gameplayHandler.shipReference.position
                    
                    self.gameplayHandler.addChild(fireParticles)
                    
                    
                    fireParticles.targetNode = self
                }
                
                self.gameplayHandler.shipReference.removeFromParent()
                self.gameplayHandler.shipReference.removeAllActions()
            }
        ]))
        
        
    }
    
    func shakeCamera(duration:Float) {
        
           let amplitudeX:Float = 25;
           let amplitudeY:Float = 25;
           let numberOfShakes = duration / 0.02;
           var actionsArray: [SKAction] = [];
        
           for index in 1...Int(numberOfShakes) {
               // build a new random shake and add it to the list
               let moveX = Float(arc4random_uniform(UInt32(amplitudeX))) - amplitudeX / 2;
               let moveY = Float(arc4random_uniform(UInt32(amplitudeY))) - amplitudeY / 2;
               let shakeAction = SKAction.moveBy(x: CGFloat(moveX), y: CGFloat(moveY), duration: 0.02);
               shakeAction.timingMode = SKActionTimingMode.easeOut;
               actionsArray.append(shakeAction);
               actionsArray.append(shakeAction.reversed());
           }

           let actionSeq = SKAction.sequence(actionsArray);
            self.cameraHandler.run(actionSeq);
       }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        self.gameplayHandler.touchesBeganPassthrough(touches, with: event)
        
        
        savedVelocity = self.gameplayHandler.currentSelectedEntity.physicsBody!.velocity
        savedAngularVelocity = self.gameplayHandler.currentSelectedEntity.physicsBody!.angularVelocity
        
   
        self.gameplayHandler.statisMode = true
        

        self.physicsWorld.speed = 5
      
            
        for node in self.children {
            if (node.name == "Enemigo") {
                node.isPaused = true
                node.physicsBody!.isDynamic = false 
            }
        }
        

        if let touch = touches.first {
            initialTouchLocation = touch.location(in: self)

           }
        
    }
    
    
 
    
  


    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        
     
            if let touch = touches.first, let initialLocation = initialTouchLocation {
                
                
                movevmeentreleaseLocation = touch.location(in: self)
                
                let forceVector = CGVector(dx: self.initialTouchLocation!.x - self.movevmeentreleaseLocation!.x, dy: self.initialTouchLocation!.y - self.movevmeentreleaseLocation!.y)
                
                self.gameplayHandler.currentSelectedEntity.rotateBasedOnMovement(forceVector: forceVector)
                
                print(self.gameplayHandler.shipReference.position)
                print(self.gameplayHandler.currentSelectedEntity.position)
                
                
                
                
                
                
                
                trajectoryLineManager.activateTrajectoryLine(savedVelocity: savedVelocity, forceVector: forceVector, savedAngularVelocity: savedAngularVelocity, nodeReference:  self.gameplayHandler.currentSelectedEntity, sceneReference: self)
                
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
        
        self.trajectoryLineManager.removeTrajectoryLine()
        
        self.gameplayHandler.statisMode = false

        self.physicsWorld.speed = 0.25
        
        
        if let touch = touches.first, let initialLocation =
            initialTouchLocation {
            
            
         
            followShip = true
            
            let releaseLocation = touch.location(in: self)
            forceVector = CGVector(dx: initialLocation.x - releaseLocation.x, dy: initialLocation.y - releaseLocation.y)
            
            
            self.gameplayHandler.touchesEndedPassthrough(savedVelocity: savedVelocity, savedAngularVelocity: savedAngularVelocity)
            
            
            applyForce(to: self.gameplayHandler.currentSelectedEntity, vector: forceVector)
                
            
          
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
        self.gameplayHandler.update(currentTime)
        
        if (followShip && self.gameplayHandler.shipReference.position.y > SharedInfo.SharedInstance.safeAreaLayoutSize.height / 4  ) {
            // Called before each frame is rendered
           
          //  cameraReference.position.y = self.gameplayHandler.shipReference.position.y
        }
        
        if (!self.gameplayHandler.statisMode) {
            self.gameplayHandler.handleSelectedObjectsZRotation()
        }
        
        if (self.gameplayHandler.shipReference.position.x > SharedInfo.SharedInstance.safeAreaLayoutSize.width  - 200 || self.gameplayHandler.shipReference.position.x < -SharedInfo.SharedInstance.safeAreaLayoutSize.width  + 200  ) {
            
            let amountInitial = self.gameplayHandler.shipReference.position.x / (SharedInfo.SharedInstance.safeAreaLayoutSize.width )
            var amount = 0.0
            if (amountInitial < 0.0) {
                amount = amountInitial * -1
            } else {
                amount = amountInitial
            }
                cameraHandler.removeAllActions()
            cameraHandler.setScale( amount + 0.5)
            
        } else {
             
            cameraHandler.run(SKAction.scale(to: 1.0, duration: 1))
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
            if(!self.gameplayHandler.statisMode){
             
                self.dotGridManager.updateDotPositions(planets: self.gameplayHandler.planets, playerPos: self.gameplayHandler.shipReference.position)
            }
            frameSkipper = 0
            
        }
        frameSkipper = frameSkipper + 1
        
    }
    
 
 
    
}
