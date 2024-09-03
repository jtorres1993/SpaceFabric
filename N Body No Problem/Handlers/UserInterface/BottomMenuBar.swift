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

    
    var currentlySelectedButton : JKButtonNode? = nil
    var allButtons :  [JKButtonNode] = []
    
    
    let buttonGameModeMap: [String: GameModes] = [
        "camera": .camera,
        "missile": .missile,
        "ship": .ship,
        "shootByWire": .shootByWire,
        "settings" : .settings 
    ]


    func setup(){
        
    
        
        lazerButton = setupMenuItem(button: lazerButton, withImage: "lazerbutton-selected", withOffset: 0, withSettingsMenu: lazerButtonMenu)
        lazerButton?.name = "shootByWire"
        lazerButton?.menuCallback = self.modeMenuButtonPressed
        
        lazerButton?.highlightedBG = SKTexture.init(imageNamed: "lazerbutton")
        
        missileButton = setupMenuItem(button: missileButton, withImage: "missilebutton-selected", withOffset: 1, withSettingsMenu: missileButtonSprite)
        missileButton?.name = "missile"
        missileButton?.menuCallback = self.modeMenuButtonPressed
    
        missileButton?.highlightedBG = SKTexture.init(imageNamed: "missilebutton")
        
        
        
        
        shipButton = setupMenuItem(button: shipButton, withImage: "shipbutton-selected", withOffset: 2, withSettingsMenu: shipButtonSprite)
        
        let shipHighlightedTexture = SKTexture.init(imageNamed: "shipbutton")
        shipButton?.highlightedBG = shipHighlightedTexture
        
        shipButton?.name = "ship"
        shipButton?.enableSelectionState = true
        
        currentlySelectedButton = shipButton
        
        shipButton?.selected = .selected
        shipButton?.set(state: .highlighted)
        shipButton?.canChangeState = false
        shipButton?.menuCallback = self.modeMenuButtonPressed
        
        
   
        
        
        settingsButton = setupMenuItem(button: settingsButton, withImage: "Dronebutton-selected", withOffset: 3, withSettingsMenu: settingsMenu)
        settingsButton?.name = "settings"
        settingsButton?.menuCallback = self.modeMenuButtonPressed
        
        settingsButton?.highlightedBG = SKTexture.init(imageNamed: "Dronebutton")
        
        
        
        cameraButton = setupMenuItem(button: cameraButton, withImage: "camerabutton-selected", withOffset: 4, withSettingsMenu: cameraButtonMenu)
           
        cameraButton?.name = "camera"
        cameraButton?.menuCallback = self.modeMenuButtonPressed
        //setupIconForButton(iconImage: "sybdit", button: missileButton!)
        
        cameraButton?.highlightedBG = SKTexture.init(imageNamed: "camerabutton")
        
        
        
        allButtons.append(shipButton!)
        allButtons.append(lazerButton!)
        allButtons.append(missileButton!)
        allButtons.append(cameraButton!)
        allButtons.append(settingsButton!)
        
        
        
    }
    
    func modeMenuButtonPressed(button: JKButtonNode){
        
        if let currentlySelectedButton {
            
            if currentlySelectedButton != button {
                
                //Disallow the state change of the menu button so its not disabled
                button.shouldDisableChangeStateAfterPress = true
                
                self.currentlySelectedButton?.set(state: .normal)
                self.currentlySelectedButton = button
               
                for all_button in allButtons {
                    //Allow the other buttons to still be changed in state
                    if (all_button != button){
                        all_button.canChangeState = true
                        all_button.shouldDisableChangeStateAfterPress = false

                        
                    }
                }
                
                
            }
        }
        
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
