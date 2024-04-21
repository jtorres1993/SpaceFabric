//
//  BottomMenuBar.swift
//
//
//  Created by Jorge Torres on 2/27/24.
//

import Foundation
import SpriteKit

class BottomMenuBar: SKNode {
    
 
    
    var settingsButton : JKButtonNode? = nil
    let settingsMenu = SKSpriteNode()

    var missileButton : JKButtonNode? = nil
    let missileMenu = SKSpriteNode()
    
   


    func setup(){
        
    
        settingsButton = setupMenuItem(button: settingsButton, withImage: "MenuBottomBackgroundButton", withOffset: 0, withSettingsMenu: settingsMenu)
        setupIconForButton(iconImage: "sybdit", button: settingsButton!)
        
     
        missileButton = setupMenuItem(button: missileButton, withImage: "MenuBottomBackgroundButton", withOffset: 1, withSettingsMenu: missileMenu)
        setupIconForButton(iconImage: "sybdit", button: missileButton!)
        
        
        
    }
    
    func setupMenuItem(button: JKButtonNode?, withImage: String, withOffset: Int , withSettingsMenu: SKSpriteNode )->JKButtonNode{
        
        let button = JKButtonNode.init(backgroundNamed: withImage)
    
        
       
        button.anchorPoint = CGPoint.init(x: 1, y: 0.0)
        
        let screenBorder = SharedInfo.SharedInstance.screenSize.width / 2.0
        let buttonOffset = button.size.width * CGFloat(withOffset)
        var buttonMargin = 10 * withOffset + 10
       
        button.position.x = screenBorder - buttonOffset - CGFloat(buttonMargin) - (button.size.width / 2)
        button.position.y = -SharedInfo.SharedInstance.screenSize.height / 2 
        self.addChild(button)
        button.zPosition = 10
        self.addChild(withSettingsMenu)
                                       
        return button
        
    }
    
    func show(){
        self.run(SKAction.fadeAlpha(to: 1.0, duration: 0.2))
    }
    
    func hide(){
        self.run(SKAction.fadeAlpha(to: 0.0, duration: 0.2))
    }
    
    func setupIconForButton(iconImage: String , button: JKButtonNode){
        
        let icon = SKSpriteNode.init(imageNamed: iconImage)
        icon.zPosition = 11
        
        icon.position.x = -button.size.width / 2
        icon.position.y = button.size.height / 2
        button.addChild(icon)
        
    }
}
