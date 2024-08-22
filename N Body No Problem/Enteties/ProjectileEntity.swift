//
//  ProjectileEntity.swift
//  N Body No Problem
//
//  Created by Jorge Torres on 8/21/24.
//

import Foundation

import SpriteKit

class ProjectileEntity : SKSpriteNode {
    
    
    
    func rotateBasedOnMovement(forceVector: CGVector){
        
        let angle = atan2(forceVector.dy, forceVector.dx) - (CGFloat.pi / 2)
        self.zRotation = angle
    }
    
    func recreatePhysicsBody(){
        
        
    }
}
