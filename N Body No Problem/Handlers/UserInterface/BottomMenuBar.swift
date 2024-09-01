//
//  BottomMenuBar.swift
//
//
//  Created by Jorge Torres on 2/27/24.
//

import Foundation
import SpriteKit

class BottomMenuBar: SKNode {
    
 
    
    var missileButton : JKButtonNode? = nil
    let missileButtonSprite = SKSpriteNode()

    var shipButton : JKButtonNode? = nil
    let shipButtonSprite = SKSpriteNode()

    
    var cameraButton : JKButtonNode? = nil
    let cameraButtonMenu = SKSpriteNode()
    
    var settingsButton : JKButtonNode? = nil
    let settingsMenu = SKSpriteNode()
   
    
    var lazerButton : JKButtonNode? = nil
    let lazerButtonMenu = SKSpriteNode()


    func setup(){
        
    
        
        shipButton = setupMenuItem(button: shipButton, withImage: "shipButton", withOffset: 2, withSettingsMenu: shipButtonSprite)
        
        let shipHighlightedTexture = SKTexture.init(imageNamed: "shipbutton-selected")
        shipButton?.highlightedBG = shipHighlightedTexture
        
        shipButton?.enableSelectionState = true
        shipButton?.selected = .selected
        shipButton?.set(state: .highlighted)

        missileButton = setupMenuItem(button: missileButton, withImage: "missilebutton", withOffset: 1, withSettingsMenu: missileButtonSprite)
        
     
        lazerButton = setupMenuItem(button: cameraButton, withImage: "lazerbutton", withOffset: 0, withSettingsMenu: lazerButtonMenu)
        
        
        settingsButton = setupMenuItem(button: settingsButton, withImage: "Dronebutton", withOffset: 3, withSettingsMenu: settingsMenu)
           
        
        cameraButton = setupMenuItem(button: cameraButton, withImage: "camerabutton", withOffset: 4, withSettingsMenu: cameraButtonMenu)
           
        
        
        //setupIconForButton(iconImage: "sybdit", button: missileButton!)
        
        
        
    }
    
    func setupMenuItem(button: JKButtonNode?, withImage: String, withOffset: Int , withSettingsMenu: SKSpriteNode )->JKButtonNode{
        
        let button = JKButtonNode.init(backgroundNamed: withImage)
    
        
       
        button.anchorPoint = CGPoint.init(x: 1, y: 0.0)
        
        let screenBorder = -SharedInfo.SharedInstance.screenSize.width / 2.0
        let buttonOffset = button.size.width * CGFloat(withOffset)
        let buttonMargin = 10 * withOffset + 50
       
        button.position.x = screenBorder  + 100 + (button.size.width
        ) + CGFloat(buttonOffset)
        button.position.y = -SharedInfo.SharedInstance.screenSize.height / 2 + 50
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
