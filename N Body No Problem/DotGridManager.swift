//
//  DotGridManager.swift
//  N Body No Problem
//
//  Created by Jorge Torres on 4/21/24.
//

import Foundation
import SpriteKit

class DotGridManager {
    
    
    var dots = [SKSpriteNode]()
    let dotSpacing: CGFloat = 40
    let gridSize: CGSize = CGSize.init(width: 50, height: 110)
    let dotSize = CGSize(width: 5, height: 5)
    
    func setupDots( scene: SKScene, withCameraPos: CGPoint) {
        
        let coreWidth = 800.0
        let coreHeight = 2000.0
        
            // Clear existing dots from the parent node
            for dot in dots {
                dot.removeFromParent()
            }
            
            dots.removeAll()
            
            let centerX = scene.frame.midX
            let centerY = scene.frame.midY
            let numDotsX = Int(gridSize.width)
            let numDotsY = Int(gridSize.height)
            
            // Define the boundaries within which dots will have uniform spacing
            let halfCoreWidth = coreWidth / 2.0
            let halfCoreHeight = coreHeight / 2.0
            
            // Define the exponential growth rate and the width of the transition area
            let growthRate: CGFloat = 0.2  // This is the base growth rate
            let transitionWidth: CGFloat = 50.0  // Width of the gradual transition area

            for x in 0..<numDotsX {
                for y in 0..<numDotsY {
                    // Position index starting from the middle of the grid
                    let deltaX = CGFloat(x - numDotsX / 2)
                    let deltaY = CGFloat(y - numDotsY / 2)
                    
                    let absDeltaX = abs(deltaX)
                    let absDeltaY = abs(deltaY)
                    
                    // Determine if the dot is outside the core area and in the transition area
                    let distanceOutsideCoreX = max(0, absDeltaX - halfCoreWidth / dotSpacing)
                    let distanceOutsideCoreY = max(0, absDeltaY - halfCoreHeight / dotSpacing)
                    
                    let factorX = distanceOutsideCoreX / transitionWidth
                    let factorY = distanceOutsideCoreY / transitionWidth
                    
                    // Smooth transition factor using a sigmoid-like function (tanh)
                    let smoothFactorX = tanh(factorX)
                    let smoothFactorY = tanh(factorY)
                    
                    // Apply exponential factor gradually transitioning to full growth rate
                    let expFactorX = exp(growthRate * smoothFactorX * distanceOutsideCoreX)
                    let expFactorY = exp(growthRate * smoothFactorY * distanceOutsideCoreY)
                    
                    // Calculate final positions
                    let finalX = centerX + deltaX * dotSpacing * expFactorX
                    let finalY = centerY + deltaY * dotSpacing * expFactorY
                    
                    // Create the dot node and add to the scene
                    let dot = DotNode(color: SharedInfo.SharedInstance.dotColor, size: dotSize, initialPosition: CGPoint(x: finalX, y: finalY), withCameraPos: withCameraPos)
                        scene.addChild(dot)
                    
                    dots.append(dot)
                   
                }
            }
        }
    
    
    func vector(from startPoint: CGPoint, to endPoint: CGPoint) -> CGVector {
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        return CGVector(dx: dx, dy: dy)
    }
    
    
    func hyperSpaceNextLevelTransition(withCameraPos: CGPoint){
        for dot in dots {
          
            
            
            let randWaitTIme = Double.random(in: 0.0 ... 0.5)

            let randSpeedTIme = Double.random(in: 0.0 ... 0.5)
            
            let movementVector = vector(from: withCameraPos, to: dot.position)

            
            dot.run(SKAction.sequence([
                SKAction.wait(forDuration: randWaitTIme),
                SKAction.group([ SKAction.fadeAlpha(to: 0.0, duration: randSpeedTIme),             SKAction.move(by: CGVector.init(dx: movementVector.dx * 20, dy: movementVector.dy * 20), duration: randSpeedTIme), SKAction.scale(to: 3.0, duration: randSpeedTIme) ])
    
            ,  SKAction.run {
                dot.removeFromParent()
            }]))
            
            
            
        }
        
        dots = []
    }
    
    func updateDotPositions(planets: [(position: CGPoint, radius: CGFloat, strength: CGFloat)]) {
        for dot in dots as! [DotNode] {
            
            if let ogDotPosition = dot.originalPosition {
            var totalShift = CGVector(dx: 0, dy: 0)
            
            var totalDisplacement = 0.0
            for planet in planets {
                let dx = planet.position.x - ogDotPosition.x
                let dy = planet.position.y - ogDotPosition.y
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
            dot.position = CGPoint(x: ogDotPosition.x + totalShift.dx,
                                   y: ogDotPosition.y + totalShift.dy)

            }
        }
    }


    
    
}
