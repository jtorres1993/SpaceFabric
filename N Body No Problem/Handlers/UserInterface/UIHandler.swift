//
//  UIHandler.swift
//  N Body No Problem
//
//  Created by Jorge Torres on 8/11/24.
//

import Foundation
import SpriteKit

class UIHandler: SKNode {
    
    let bottomMenuBar = BottomMenuBar()
    var astros : [SKSpriteNode] = []
    var textbackgroundReferece = SKSpriteNode()
    var healthBar = SKSpriteNode()
    let shootByWireMenu = ShootByWireMenu()
    var getCurrentGameModeHandler: (()->GameModes)?
    
    let completion = LevelCompleteMenu()

    
    func setup(){
        
        
       
        let astro_outline = SKSpriteNode.init(imageNamed: "astro-outline")
        astro_outline.setScale(0.5)
        self.addChild(astro_outline)
        
        astro_outline.position.y = SharedInfo.SharedInstance.screenSize.height / 2 - astro_outline.size.height
        
        astro_outline.position.x = SharedInfo.SharedInstance.screenSize.width / 2 - ( astro_outline.size.width * 2 )
        
        astros.append(astro_outline)
        
        bottomMenuBar.setup()
        bottomMenuBar.zPosition = 100
        
        if(SharedInfo.SharedInstance.bottomMenuBarEnabled) {
            self.addChild(bottomMenuBar)
        }
    
        
        let commander = SKSpriteNode.init(imageNamed: "Commander")
        commander.position.y = -SharedInfo.SharedInstance.screenSize.height / 2
        + commander.size.height / 4
        
        commander.position.x = -SharedInfo.SharedInstance.screenSize.width / 2 + commander.size.width / 2 
        
       // self.addChild(commander)
        
        
        
        self.handleDialog()
        self.setupHealthBar()
        
        completion.setup()
        completion.alpha = 0.0
        completion.hide()
        self.addChild(completion)
        
        shootByWireMenu.setup()
        
        shootByWireMenu.position.y = -SharedInfo.SharedInstance.self.screenSize.height / 2 + (shootByWireMenu.movementJoystick.diameter * 1.3)
        
        shootByWireMenu.position.y =
        
        shootByWireMenu.position.y - SharedInfo.SharedInstance.screenSize.height
        self.addChild(shootByWireMenu)
        
    }
    
    func setupHealthBar(){
        
        healthBar = SKSpriteNode.init(color: .red, size: CGSize.init(width: SharedInfo.SharedInstance.screenSize.width , height: 10))
        
        
        
        healthBar.position.y =   (SharedInfo.SharedInstance.screenSize.height / 2) - healthBar.size.height - SharedInfo.SharedInstance.safeAreaInserts.top
        
        self.addChild(healthBar)
        healthBar.anchorPoint = CGPoint.init(x: 0, y: 0.5)
        
        healthBar.position.x = healthBar.position.x -  healthBar.size.width / 2
        
    }
    
    func playerTookHealthHit(percentage: CGFloat){
        
        healthBar.run(SKAction.scaleX(to: percentage, duration: 1.0))
    }
    
    func handleDialog(){
        textbackgroundReferece = SKSpriteNode.init(color: UIColor.gray, size: CGSize.init(width: SharedInfo.SharedInstance.screenSize.width , height: 200))
        
        textbackgroundReferece.position.y = -SharedInfo.SharedInstance.screenSize.height / 2 + textbackgroundReferece.size.height / 2
       // self.addChild(textbackgroundReferece)
    }
    
    func createDialogText(){
        
        
        
    }
    
    

    
    func runCapturedAstro( hasPassedLevel: Bool )
    {
        
        let astro = SKSpriteNode.init(imageNamed: "astro")
        astro.position = self.astros[0].position
        astro.alpha = 0.0
        self.addChild(astro)
        let initialfadein = SKAction.group([SKAction.scale(to: 0.5, duration: 0.25), SKAction.fadeAlpha(to: 1.0, duration: 0.25)])
        
        let popOut = SKAction.sequence([SKAction.scale(to: 0.8, duration: 0.05), SKAction.scale(to: 0.5, duration: 0.05) ])
        astro.run( SKAction.sequence([initialfadein, popOut]) )
        
        if(hasPassedLevel){
            
            //Present the completion screen and next level
            //Continue button only for now
            
            completion.show() 
        }
        
    }
    
    func shootByWireActivated() {
        
        shootByWireMenu.run(SKAction.moveBy(x: 0, y: SharedInfo.SharedInstance.screenSize.height, duration: 0.5))
        
    }
    
    func shootByWireDissmissed(){
        
        
        shootByWireMenu.run(SKAction.moveBy(x: 0, y: -SharedInfo.SharedInstance.screenSize.height, duration: 0.5))
    }
    
}
