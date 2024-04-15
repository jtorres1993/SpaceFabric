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
        static let gravityStar: UInt32 = 0b1       // 1
        static let player: UInt32 = 0b10          // 2
        static let projective: UInt32 = 0b100           // 4
    }
    
    
    
    var shipHasBeenPlaced = false
    var followShip = false
    var shipReference = SKSpriteNode.init()
    var cameraReference = SKCameraNode()
    var screenSizeReference = CGSize()
    var starReference : [SKSpriteNode] = []
    var planetPoints : [(position: CGPoint, radius: CGFloat)] = []

    
    var dots = [SKSpriteNode]()
    let dotSpacing: CGFloat = 30.0  // Space between dots
    let gridSize: Int = 70          // Number of dots along width and height
    var planets = [(position: CGPoint, radius: CGFloat, strength: CGFloat)]()

    
    func setupDots() {
        for x in 0..<gridSize {
            for y in 0..<gridSize {
                let initialPosition = CGPoint(x: CGFloat(x) * dotSpacing + self.frame.midX - dotSpacing * CGFloat(gridSize) / 2,
                                              y: CGFloat(y) * dotSpacing + self.frame.midY - dotSpacing * CGFloat(gridSize) / 2)
                let dot = DotNode(color: .white, size: CGSize(width: 2, height: 2), initialPosition: initialPosition)
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
                    dot.alpha = 100
                    // Apply the calculated shift from the original position
                    dot.position = CGPoint(x: dot.originalPosition.x + totalShift.dx,
                                           y: dot.originalPosition.y + totalShift.dy)
                    
                }}

         
        }
    }

    
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = CGVector(dx:0, dy: 0);
        self.physicsWorld.contactDelegate = self

        
        shipReference = SKSpriteNode.init(imageNamed: "spaceship")
        
        shipReference.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize.init(width: 15, height: 30))
        shipReference.physicsBody?.fieldBitMask = PhysicsCategory.gravityStar
        shipReference.physicsBody!.categoryBitMask = PhysicsCategory.player
        shipReference.physicsBody!.mass = 100
        shipReference.physicsBody?.contactTestBitMask =  PhysicsCategory.gravityStar
        
        screenSizeReference = self.view!.safeAreaLayoutGuide.layoutFrame.size
        
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
              
                        
                    print(node.position)
                    
                    starReference.append(node as! SKSpriteNode)
                  
                    planets.append((position: node.position, radius: 200, strength: 1500))
                
               // node.run(SKAction.repeatForever(SKAction.sequence([SKAction.moveBy(x: 400, y: 0, duration: 5), SKAction.moveBy(x: -400, y: 0, duration: 5)])))
                
                
            }
        }
        
       
       // shipReference.position.x = self.size.width / 2
    }
    var gridBackground: SKSpriteNode!

    
    var planetPositions: [CGPoint] = []
    var planetRadii: [CGFloat] = []


       
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
            
            if let scene = SKScene(fileNamed: "GameScene") {
                   scene.scaleMode = .aspectFill
                   view?.presentScene(scene, transition: SKTransition.fade(withDuration: 1.0))
               }
            
        } else {
            print("OP")
        }
        
           
           
       }
    
    var initialTouchLocation: CGPoint?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        
        
        shipReference.physicsBody?.fieldBitMask = PhysicsCategory.none
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
    

       override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
           if let touch = touches.first, let initialLocation = initialTouchLocation {
               let currentLocation = touch.location(in: self)
               let vector = CGVector(dx: initialLocation.x - currentLocation.x, dy: initialLocation.y - currentLocation.y)
               // Optionally, update something on the screen to indicate the pull direction and force
           }
       }

       override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
           if let touch = touches.first, let initialLocation = initialTouchLocation {
               
               followShip = true
               let releaseLocation = touch.location(in: self)
               let forceVector = CGVector(dx: initialLocation.x - releaseLocation.x, dy: initialLocation.y - releaseLocation.y)
               
               shipReference.physicsBody?.fieldBitMask =  PhysicsCategory.gravityStar
               shipReference.physicsBody?.isDynamic = true
               shipReference.run(SKAction.scale(to: 0.3, duration: 0.1))

               
               
               applyForce(to: shipReference, vector: forceVector)
           }
       }
    
    func applyForce(to sprite: SKSpriteNode, vector: CGVector) {
        let multipler = 100.0
        let impulseVector = CGVector(dx: vector.dx * multipler, dy: vector.dy * multipler ) // Adjust multiplier as needed
       // sprite.physicsBody?.isDynamic = true
        sprite.physicsBody?.applyImpulse(impulseVector)
    }
    
    var frameSkipper = 0
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        updateDotPositions()
        if (followShip && shipReference.position.y > screenSizeReference.height / 4  ) {
            // Called before each frame is rendered
           
            cameraReference.position.y = shipReference.position.y
        } else { }
        
  
            planets = []

            for star in starReference {
        
                planets.append((position: star.position, radius: 350, strength: 250))

            
          
            }
            
           // applyGravityWellEffects(planets: planetPoints)
        

        
    }
}
