//
//  SoundHandler.swift
//  N Body No Problem
//
//  Created by Jorge Torres on 5/24/24.
//

import Foundation
import SpriteKit

class SoundHandler: SKSpriteNode {
    
    func playInitialSound(){
        
          let scifiwepsound = SKAction.playSoundFileNamed("Galactic Swing (Singularity Mix)", waitForCompletion: false)
         
         run(scifiwepsound)
        
    }
    
}
