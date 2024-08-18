//
//  Menu.swift
//  Foldobo
//
//  Created by Jorge Torres on 3/1/24.
//

import Foundation
import SpriteKit

class Menu : SKNode {
    
    var showing = false
    let menuSpeed = 0.1
    
    func setup () {
        
    }
    
    func show(){
        showing = true
        self.run(SKAction.move(to: CGPoint.zero, duration: menuSpeed))
   
    }
    
    func hide(){
        showing = false
        self.run(SKAction.move(to: CGPoint.init(x: 0, y: -SharedInfo.SharedInstance.screenSize.height * 2), duration: menuSpeed))
    
    }
    
     func toggle(button: JKButtonNode){
        if (showing) {
            hide()
        } else {
            show()
        }
    }
}
