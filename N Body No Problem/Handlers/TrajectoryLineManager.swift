//
//  TrajectoryLineManager.swift
//  N Body No Problem
//
//  Created by Jorge Torres on 8/11/24.
//

import Foundation
import SpriteKit

class TrajectoryLineManager: SKNode {
    
    var nodesArray: [SKNode] = []
    var dotNodes: [SKSpriteNode] = []
    var updateTrajectory = false
    let lineSegmentWidth = 10
    let lineSegmentHeight = 5
    func updateTrajectoryLine() {
        let path = CGMutablePath()
        guard let firstNode = self.nodesArray.first else { return }
        path.move(to: firstNode.position)
        
        if updateTrajectory {
               // Clear existing dots from the scene
            for dot in self.dotNodes {
                   dot.removeFromParent()
               }
            self.dotNodes = []

               // Prepare to collect new dots
               var nextNode: SKNode? = nil  // This will be the node each dot points to

            for (index, node) in self.nodesArray.enumerated().reversed() {
                   if self.dotNodes.count < 20 {
                       if self.nodesArray.indices.contains(index - 1 ) {
                           nextNode = self.nodesArray[index - 1]
                       }
                       let dot = self.addTrajectoryPathDot(at: node.position, nextNode:  nextNode ?? node)
                       self.dotNodes.append(dot)
                   }
                   nextNode = node  // Update nextNode to the current node for the next iteration
               }

            updateTrajectory = false
           }
      
       }
    
    
    func trajectoryLineIntersectedWithStar(dotNode: SKNode?){
        
        
        print("dot collision")
        var count = 0
        for nodo in self.nodesArray {
            if let second = dotNode
            {
            if (nodo == dotNode){
                
                self.nodesArray.remove(at: count)
                nodo.removeAllActions()
                nodo.removeFromParent()
                break
                
            }
            
            count = count + 1
            }
        }
        if count > 0 {
            for currentIndex in 0...count  {
                
                if let nodo = self.nodesArray.first {
                nodo.removeAllActions()
                nodo.removeFromParent()
                self.nodesArray.removeFirst()
                }
            }}
        
    }
    
    func addTrajectoryPathDot(at position: CGPoint, nextNode: SKNode) -> SKSpriteNode {
        let dot = SKSpriteNode(color: .white, size: CGSize(width: lineSegmentWidth, height: lineSegmentHeight))  // Appearance as a line
        dot.position = position
        dot.lightingBitMask = 1
        let dx = nextNode.position.x - position.x
        let dy = nextNode.position.y - position.y
        let angle = atan2(dy, dx)
        dot.zRotation = angle  // Set rotation to point towards the next node

        addChild(dot)
        return dot
    }
    
}