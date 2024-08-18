//
//  LongRangeMissile.swift
//  N Body No Problem
//
//  Created by Jorge Torres on 8/18/24.
//

import Foundation
import SpriteKit

class LongRangeMissile : SKSpriteNode {
    
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        
        let texture = SKTexture(imageNamed: "LRM")
        
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        
        
        
        
    }
    
}
