//
//  LevelCompleteMenu.swift
//  Foldobo
//
//  Created by Jorge Torres on 4/7/24.
//

import Foundation
import SpriteKit


class LevelCompleteMenu: Menu {
    
    var stars : [SKSpriteNode] = []
    let menu = SKSpriteNode.init(imageNamed: "levelcomplete")
    let routeLabel = SKLabelNode()
    let routeName = SKLabelNode()
    
    var achievementLabels : [SKLabelNode] = []
    var continueButton =  JKButtonNode(backgroundNamed: "ContinueButton")
    var continueDelegateMethod : (()->Void)? = nil
    var uiContinueDelegateMethod : (()->Void)? = nil
    
    override func setup(){
        
        
       
        self.addChild(menu)
    
        setupStars()
        
        setupLabels()
        
        continueButton.zPosition = 100
        continueButton.position.y = -(menu.size.height / 2 ) - continueButton.size.height / 2
        continueButton.action = self.continueButtonPressed
        self.addChild(continueButton)
        
        
        
    }
    
    func completaionTriggered(){
        
        self.show()
    }
    
    func continueButtonPressed(button: JKButtonNode){
        
        self.hide()
        if let _ = continueDelegateMethod {
            self.continueDelegateMethod!()
        }
        
        if let _ = uiContinueDelegateMethod {
            uiContinueDelegateMethod!()
        }
        
    }
    
    func setupLabels(){
        
      
        
        let achiveLabel1 = SKLabelNode()
        achiveLabel1.fontName = "Piksel"
        achiveLabel1.text = "Stars Found"
        achiveLabel1.fontSize = 30
        achiveLabel1.zPosition = 100
        achiveLabel1.verticalAlignmentMode = .top
        achiveLabel1.position.y = (menu.size.height / 2) - ( menu.size.height / 8)
        self.addChild(achiveLabel1)

        
        let achiveLabel2 = SKLabelNode()
        achiveLabel2.fontName = "Piksel"
        achiveLabel2.text = "Coins Collected"
        achiveLabel2.fontSize = 30
        achiveLabel2.zPosition = 100
        achiveLabel2.verticalAlignmentMode = .top
        achiveLabel2.position.y = achiveLabel1.position.y - (achiveLabel1.fontSize / 2 ) - 15
        self.addChild(achiveLabel2)
        
        
        let achiveLabel3 = SKLabelNode()
        achiveLabel3.fontName = "Piksel"
        achiveLabel3.text = "New Mons Encountered"
        achiveLabel3.fontSize = 30
        achiveLabel3.zPosition = 100
        achiveLabel3.verticalAlignmentMode = .top
        achiveLabel3.position.y = achiveLabel2.position.y - (achiveLabel2.fontSize / 2 ) - 15
        self.addChild(achiveLabel3)
        
        
        let achiveLabel4 = SKLabelNode()
        achiveLabel4.fontName = "Piksel"
        achiveLabel4.text = "New Mons Collected"
        achiveLabel4.fontSize = 30
        achiveLabel4.zPosition = 100
        achiveLabel4.verticalAlignmentMode = .top
        achiveLabel4.position.y = achiveLabel3.position.y - (achiveLabel3.fontSize / 2 ) - 15
        self.addChild(achiveLabel4)

        
    }
    
    
    
    func setupStars(){
        
        let star1 = SKSpriteNode.init(imageNamed: "star-black")
        star1.position.y = menu.size.height / 2
        star1.position.x = ((-menu.size.width / 2) / 3)
        star1.setScale(2.0)
        star1.zRotation = CGFloat(degreesToradians(30))
        star1.zPosition = 100
        stars.append(star1)
        self.addChild(star1)
        
        let star2 = SKSpriteNode.init(imageNamed: "star-black")
        star2.position.y = menu.size.height / 2
        star2.position.x = ((menu.size.width / 2) / 3)
        star2.setScale(2.0)
        star2.zRotation = CGFloat(degreesToradians(-30))
        star2.zPosition = 100
        stars.append(star2)
        self.addChild(star2)
        
        
        
        
        let star3 = SKSpriteNode.init(imageNamed: "star-black")
        star3.position.y = menu.size.height / 2 + star3.size.height
        star3.setScale(3.0)
        star3.zPosition = 100
        stars.append(star3)
        self.addChild(star3)
        
    }
    
}
