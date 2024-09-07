
import SpriteKit
import GameplayKit

class IntroScreen: SKScene {

    let logoReference = SKSpriteNode.init(imageNamed: "CosmicSwingLogo")
    let tapToPlayReference = SKLabelNode()
    
    var startedGame = false
    
    override func didMove(to view: SKView) {
        
     
        self.addChild(logoReference)
        self.backgroundColor = .black
        
        tapToPlayReference.text = "TAP TO PLAY"
        
        
        
        tapToPlayReference.fontSize = 20
        tapToPlayReference.position.y = -self.size.height / 4
        tapToPlayReference.verticalAlignmentMode = .center
    
        tapToPlayReference.run(SKAction.repeatForever(SKAction.sequence([SKAction.scale(to: 1.3, duration: 0.1), SKAction.scale(to: 1.0, duration: 0.1), SKAction.wait(forDuration: 0.5)])))
        self.addChild(tapToPlayReference)
        
        
       
    }
    
    
  
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        
        if (startedGame == false ) {
            
            startedGame = true

            logoReference.run(SKAction.fadeAlpha(to: 0.0, duration: 0.4))
            tapToPlayReference.run(SKAction.fadeAlpha(to: 0.0, duration: 0.4))
            
            
            //let quote = SKLabelNode()

          //  let quote = MSKAnimatedLabel(text: "”Exploration is wired into our brains. If we can see the horizon, we want to know what’s beyond.” – Buzz Aldrin/")
            
            let quote = MSKAnimatedLabel(text: "”Exploration is wired into our brains. If we can see the horizon, we want to know what’s beyond.” – Buzz Aldrin",
                                         horizontalAlignment: .center,
                                         durationPerCharacter: 0.05,
                                         fontSize:  12,
                                         marginVertical:  15.0,
                                         fontColor:  .white,
                                         fontName:  "Heiti TC",
                                         skipSpaces: true,
                                         labelWidth: self.size.width - 100 ,
                                         finishTypingOnTouch:  false)
           // quote.text = "”Exploration is wired into our brains. If we can see the horizon, we want to know what’s beyond.” – Buzz Aldrin"
            
            
           // quote.fontName = "Heiti TC"
            
           // quote.lineBreakMode = .byWordWrapping
           // quote.numberOfLines = 10
           // quote.preferredMaxLayoutWidth = self.size.width - 100
            
           // quote.fontSize = 15
           // quote.position.y = -self.size.height / 4
           // quote.verticalAlignmentMode = .center
        
            quote.alpha = 0.0
            quote.run(SKAction.fadeAlpha(to: 1.0, duration: 0.8))
            
            self.addChild(quote)
            
            self.run(SKAction.wait(forDuration: 0.01), completion:
                        
                        {
                
                let scene = SKScene(fileNamed: "Level3" )
                    scene!.scaleMode = .aspectFill
                self.view?.presentScene(scene!)
                
            } )
            
            
        }
        
        
        
    }
    
 
    
  

    
    
    
}
