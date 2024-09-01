//
//  shootByWireMenu.swift
//  N Body No Problem
//
//  Created by Jorge Torres on 8/31/24.
//

import Foundation
import SpriteKit

class ShootByWireMenu : SKNode {
    
    
    
    
    let movementJoystick =  AnalogJoystick(diameter: 200, colors: (UIColor.darkGray, UIColor.white))
    
    let shootButton = JKButtonNode.init(backgroundNamed: "lazerbutton")
    
    
    func setup(){
        
        movementJoystick.position.x = (-SharedInfo.SharedInstance.screenSize.width / 2) + movementJoystick.diameter
        
        self.addChild(movementJoystick)
        
        
        self.addChild(shootButton)
        
        shootButton.position.x = (SharedInfo.SharedInstance.screenSize.width / 2) - (shootButton.size.width * 1.3  )
        
        
        
    }
    
    
}
