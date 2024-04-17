//
//  GameScene.swift
//  N Body No Problem
//
//  Created by Jorge Torres on 4/13/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    struct PhysicsCategory {
        static let none: UInt32 = 0
        static let all: UInt32 = UInt32.max
        static let gravityStar: UInt32 = 0b1// 1
        static let player: UInt32 = 0b10          // 2
        static let projective: UInt32 = 0b100  
        static let earthplanet: UInt32 = 0b1000// 4
        static let whip : UInt32 = 0b10000
    }
    
    
    
    var shipHasBeenPlaced = false
    var followShip = false
    var shipReference = SKSpriteNode.init()
    var cameraReference = SKCameraNode()
    var screenSizeReference = CGSize()
    var starReference : [SKSpriteNode] = []
    var planetPoints : [(position: CGPoint, radius: CGFloat)] = []

    var lineNode: SKShapeNode?
       var nodesArray: [SKNode] = []
    var earchReference = SKSpriteNode()
    var dots = [SKSpriteNode]()
    let dotSpacing: CGFloat = 50  // Space between dots
    let gridSize: CGSize = CGSize.init(width: 30, height: 100)          // Number of dots along width and height
    var planets = [(position: CGPoint, radius: CGFloat, strength: CGFloat)]()

    func updateLine() {
           let path = CGMutablePath()
           guard let firstNode = nodesArray.first else { return }
           path.move(to: firstNode.position)
           for node in nodesArray.dropFirst() {
               path.addLine(to: node.position)
           }
            
        lineNode!.path = nil
           lineNode?.path = path
       }
    
    func setupDots() {
        for x in 0..<Int(gridSize.width) {
            for y in 0..<Int(gridSize.height) {
                let initialPosition = CGPoint(x: CGFloat(x) * dotSpacing + self.frame.midX - dotSpacing * CGFloat(gridSize.width) / 2,
                                              y: CGFloat(y) * dotSpacing + self.frame.midY - dotSpacing * CGFloat(gridSize.height) / 2)
                let dot = DotNode(color: .gray, size: CGSize(width: 5, height: 5), initialPosition: initialPosition)
                addChild(dot)
                dots.append(dot)
                dot.lightingBitMask = 1
            }
        }
        
        
        
    }

    
    func setupPlanets() {
          // Example planets
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

    
   
        
      
      
    
    
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = CGVector(dx:0, dy: 0);
        self.physicsWorld.contactDelegate = self

              self.lineNode = SKShapeNode()
              self.lineNode?.strokeColor = .gray
              self.lineNode?.lineWidth = 4.0
              self.addChild(lineNode!)
                let pattern : [CGFloat] = [2.0, 2.0]
        shipReference = SKSpriteNode.init(imageNamed: "spaceship")
        
        shipReference.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize.init(width: 15, height: 30))
        shipReference.physicsBody?.fieldBitMask = PhysicsCategory.gravityStar
        shipReference.physicsBody!.categoryBitMask = PhysicsCategory.player
        shipReference.physicsBody!.mass = 100
        shipReference.physicsBody?.contactTestBitMask =  PhysicsCategory.gravityStar | PhysicsCategory.earthplanet
        
        self.view?.showsDrawCount = true
        screenSizeReference = self.view!.safeAreaLayoutGuide.layoutFrame.size
        self.backgroundColor = .black
        
        self.camera = cameraReference

        cameraReference.position.y = screenSizeReference.height / 4
        let background = SKSpriteNode.init(texture: nil, color: UIColor.black, size: CGSize.init(width: self.size.width, height: self.size.height * 3 ))
        background.lightingBitMask = 1
        background.zPosition = -1
        self.addChild(background)
        
        setupDots()
          setupPlanets()
        //setupBackground()
        
        var count = 0
        for node in self.children {
            if node.name == "gravitystar"
            {

                node.physicsBody!.categoryBitMask =  PhysicsCategory.gravityStar
              
                                        
                    starReference.append(node as! SKSpriteNode)
                  
                    planets.append((position: node.position, radius: 200, strength: 1500))
                
               // node.run(SKAction.repeatForever(SKAction.sequence([SKAction.moveBy(x: 400, y: 0, duration: 5), SKAction.moveBy(x: -400, y: 0, duration: 5)])))
                
                
                if let spark = SKEmitterNode(fileNamed: "spark") {
                         // fireParticles.position = CGPoint(x: size.width / 2, y: size.height / 2)
                    node.addChild(spark)
                    spark.targetNode = self
                      }
                
            } else if node.name == "earth" {
                
                earchReference = node as! SKSpriteNode
                node.physicsBody!.categoryBitMask =  PhysicsCategory.earthplanet

                
            }
        }
        
       
       // shipReference.position.x = self.size.width / 2
    }
    var gridBackground: SKSpriteNode!

    
    var planetPositions: [CGPoint] = []
    var planetRadii: [CGFloat] = []

    func predictTrajectory(initialPosition: CGPoint, initialVelocity: CGVector, timeStep: CGFloat, numSteps: Int) -> [CGPoint] {
        var points = [CGPoint]()
        var currentPosition = initialPosition
        var currentVelocity = initialVelocity

        for _ in 0..<numSteps {
            let acceleration = calculateGravitationalAcceleration(at: currentPosition)
            currentVelocity.dx += acceleration.dx * timeStep
            currentVelocity.dy += acceleration.dy * timeStep
            
            currentPosition.x += currentVelocity.dx * timeStep
            currentPosition.y += currentVelocity.dy * timeStep
            
            points.append(currentPosition)
        }
        
        return points
    }
    struct Planet {
        var position: CGPoint
        var mass: CGFloat  // Mass of the planet
    }
    
    var orbits: [Planet] = [
           Planet(position: CGPoint(x: 0, y: 221), mass: 10),  // Example planet
           Planet(position: CGPoint(x: 0, y: 600), mass: 10)   // Another example planet
       ]

    func calculateGravitationalAcceleration(at point: CGPoint) -> CGVector {
        // Constants
        let gravitationalConstant: CGFloat = 5000000 // m^3 kg^-1 s^-2
        var totalAcceleration = CGVector(dx: 0, dy: 0)
        for planet in orbits {
                  let dx = planet.position.x - point.x
                  let dy = planet.position.y - point.y
                  let distanceSquared = dx*dx + dy*dy
                  let distance = sqrt(distanceSquared)
                  
                  if distance != 0 {  // Prevent division by zero
                      let forceMagnitude = gravitationalConstant * planet.mass / distanceSquared
                      totalAcceleration.dx += forceMagnitude * (dx / distance)
                      totalAcceleration.dy += forceMagnitude * (dy / distance)
                  }
              }
              
              return totalAcceleration
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
            
        } else if ( secondBody.categoryBitMask == PhysicsCategory.player && firstBody.categoryBitMask == PhysicsCategory.earthplanet || secondBody.categoryBitMask == PhysicsCategory.earthplanet && firstBody.categoryBitMask == PhysicsCategory.player ) {
            
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
                    
                    var nodo = nodesArray.first
                    nodo?.removeAllActions()
                    nodo?.removeFromParent()
                    nodesArray.removeFirst()
                }}
        }
        
           
           
       }
    
    var initialTouchLocation: CGPoint?

    var savedVelocity : CGVector = CGVector(dx: 0, dy: 0)
    var savedAngularVelocity = 1.0
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        for star in starReference {
            star.isPaused = true
        }
        
        earchReference.isPaused = true
        
        shipReference.physicsBody?.fieldBitMask = PhysicsCategory.none
        savedVelocity = shipReference.physicsBody!.velocity
        savedAngularVelocity = shipReference.physicsBody!.angularVelocity
        
        shipReference.physicsBody?.isDynamic = false
        shipReference.run(SKAction.scale(to: 1.0, duration: 0.1))
        
        if let touch = touches.first {
            initialTouchLocation = touch.location(in: self)
            
            if (shipHasBeenPlaced == false) {
                
                shipReference.position =  initialTouchLocation!
                self.addChild(shipReference)
                let lightNode = SKLightNode()
                lightNode.categoryBitMask = 1
                lightNode.falloff = 4.5
                shipReference.addChild(lightNode)
                shipHasBeenPlaced = true
                if let fireParticles = SKEmitterNode(fileNamed: "Smoke") {
                         // fireParticles.position = CGPoint(x: size.width / 2, y: size.height / 2)
                    shipReference.addChild(fireParticles)
                    fireParticles.targetNode = self
                      }
                
                
            }
            
        }
        
        
        
        
    }
    
    var movevmeentreleaseLocation : CGPoint?

       override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
           if let touch = touches.first, let initialLocation = initialTouchLocation {
            
               
               
               if let firstnode = self.nodesArray.first {
               
                   firstnode.removeAllActions()
                   firstnode.removeFromParent()
                   self.nodesArray.removeFirst()
               }
               movevmeentreleaseLocation = touch.location(in: self)

               let forceVector = CGVector(dx: self.initialTouchLocation!.x - self.movevmeentreleaseLocation!.x, dy: self.initialTouchLocation!.y - self.movevmeentreleaseLocation!.y)
               drawTrajectory(withPosition: shipReference.position, withVelocity: forceVector)
               
               /*
               
               self.run(SKAction.repeatForever(SKAction.sequence([  SKAction.run {
                   
                   
                   let node = SKSpriteNode.init(texture: nil, color: UIColor.white, size: CGSize.init(width: 50, height: 50))
                   self.addChild(node)

                   node.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize.init(width: 15, height: 30))
                   node.physicsBody?.fieldBitMask = PhysicsCategory.gravityStar
                   node.physicsBody?.isDynamic = true
                   node.run(SKAction.scale(to: 0.05, duration: 0.1))
                   
                   node.physicsBody?.collisionBitMask = PhysicsCategory.none
                   node.physicsBody?.contactTestBitMask = PhysicsCategory.gravityStar | PhysicsCategory.earthplanet
                   node.physicsBody?.categoryBitMask = PhysicsCategory.whip
                   node.physicsBody!.mass = 100
                   node.physicsBody!.velocity = self.savedVelocity
                   node.physicsBody!.angularVelocity = self.savedAngularVelocity
                   node.position = self.shipReference.position
                   node.position.y = node.position.y + 10
                   
                   node.run(SKAction.repeatForever(SKAction.sequence([SKAction.fadeAlpha(to: 0.0, duration: 0.0),SKAction.wait(forDuration: 0.5), SKAction.fadeAlpha(to: 1.0, duration: 0.0), SKAction.wait(forDuration: 0.5)])))
                            
                   self.nodesArray.append(node)
                   node.run(SKAction.sequence([SKAction.wait(forDuration: 5), SKAction.run {
                       node.removeFromParent()
                       self.nodesArray.removeFirst()
                       
                   }]))
                   
                  
                 

                   self.applyForce(to: node, vector: forceVector)
                   
                 
                   
               }, SKAction.wait(forDuration: 0.1)])), withKey: "NodePattern")
               */

               
               
               

               
               // Optionally, update something on the screen to indicate the pull direction and force
           }
       }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.removeAction(forKey: "NodePattern")
        if let touch = touches.first, let initialLocation = initialTouchLocation {
            
            followShip = true
            let releaseLocation = touch.location(in: self)
            let forceVector = CGVector(dx: initialLocation.x - releaseLocation.x, dy: initialLocation.y - releaseLocation.y)
            
            shipReference.physicsBody?.fieldBitMask =  PhysicsCategory.gravityStar
            shipReference.physicsBody?.isDynamic = true
            shipReference.run(SKAction.scale(to: 0.05, duration: 0.1))
            
            shipReference.physicsBody!.velocity = savedVelocity
            shipReference.physicsBody!.angularVelocity = savedAngularVelocity
            
            applyForce(to: shipReference, vector: forceVector)
        }
        
        for star in starReference {
            star.isPaused = false
        }
        
        earchReference.isPaused = false
        
        
    }
    
    
    var trajectoryLine = SKShapeNode()
    func drawTrajectory(withPosition: CGPoint, withVelocity: CGVector) {
      
        let pathPoints = predictTrajectory(initialPosition: withPosition, initialVelocity: withVelocity, timeStep: 0.01, numSteps: 200)

        let path = CGMutablePath()
        path.move(to: withPosition)
        for point in pathPoints {
            path.addLine(to: point)
        }
        trajectoryLine.path = nil
        trajectoryLine = SKShapeNode(path: path)
        trajectoryLine.strokeColor = SKColor.green
        trajectoryLine.lineWidth = 2
        trajectoryLine.zPosition = 100
        self.addChild(trajectoryLine)
    }

    
    
    func applyForce(to sprite: SKSpriteNode, vector: CGVector, _ multipler: CGFloat = 100.0) {
        
        let impulseVector = CGVector(dx: vector.dx * multipler, dy: vector.dy * multipler ) // Adjust multiplier as needed
       // sprite.physicsBody?.isDynamic = true
        sprite.physicsBody?.applyImpulse(impulseVector)
    }
    
    var frameSkipper = 0
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        updateLine()
        
        
        
        updateDotPositions()
        if (followShip && shipReference.position.y > screenSizeReference.height / 4  ) {
            // Called before each frame is rendered
           
            cameraReference.position.y = shipReference.position.y
        }
        
        if (shipReference.position.x > screenSizeReference.width  - 200 || shipReference.position.x < -screenSizeReference.width  + 200  ) {
            
            var amount = shipReference.position.x / (screenSizeReference.width )
            if (amount < 0.0) {
                amount = amount * -1
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
        

        
    }
}
