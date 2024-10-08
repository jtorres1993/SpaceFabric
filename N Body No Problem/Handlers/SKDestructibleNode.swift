//
//  SKDestructibleNode.swift
//  SKDestructibleNode
//
//  Created by Trent Sartain on 12/13/15.
//  Copyright © 2015 Trent Sartain. All rights reserved.
//

import SpriteKit

class SKDestructibleNode : SKSpriteNode {
    var pieces = Array<SKSpriteNode>()
    var isDestroyed = false
    var nodeScene : SKScene
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        nodeScene = SKScene()
        super.init(texture: texture, color: color, size: size)
    }
    
    convenience init(imageName: String, scene: SKScene, pieceSize : CGFloat){
        self.init(imageNamed: imageName)
        self.nodeScene = scene
        
        createRectPieces(imageName: imageName, rectSize: CGSize(width: pieceSize, height: pieceSize))
    }
    
    convenience init(imageName: String, scene: SKScene, rectSize : CGSize){
        self.init(imageNamed: imageName)
        self.nodeScene = scene
        
        createRectPieces(imageName: imageName, rectSize: rectSize)
    }
    
    func createRectPieces(imageName: String, rectSize : CGSize) {
        let xScale = (rectSize.width / self.size.width)
        let yScale = (rectSize.height / self.size.height)
        
        let numSquaresAcross = Int(self.size.width / rectSize.width) +  1
        let numSquaresUp = Int(self.size.height / rectSize.height) + 1
        
        let clone = SKSpriteNode(imageNamed: imageName)
        
        for i in 0 ..< numSquaresAcross {
            for j in 0 ..< numSquaresUp {
                let crop = SKCropNode()
                let mask = SKSpriteNode(color: UIColor.black, size: rectSize)
                mask.position = CGPoint(x: (CGFloat(i) * (rectSize.width)) + (rectSize.width/2) - self.size.width/2, y: (CGFloat(j) * (rectSize.height)) + (rectSize.height/2) - self.size.height/2)
                
                crop.addChild(clone)
                crop.maskNode = mask
                
                let spriteNode = SKSpriteNode(texture: nodeScene.view?.texture(from: crop), size: CGSize(width: rectSize.width / xScale, height: rectSize.height / yScale))
                spriteNode.physicsBody = SKPhysicsBody(texture: spriteNode.texture!, alphaThreshold: 0.01, size: spriteNode.size)
                
                //TODO: Images with no content fail to create physicsBodies.
                if spriteNode.physicsBody == nil { continue }
                
                pieces.append(spriteNode)
            }
        }
    }
    
    func destroy() -> Array<SKSpriteNode> {
        if isDestroyed { return Array<SKSpriteNode>() }
        isDestroyed = true
        
        var angularVelocity : CGFloat = 0
        if let body = self.physicsBody {
            angularVelocity = body.angularVelocity
        }
        
        for piece in pieces {
            piece.xScale = self.xScale
            piece.yScale = self.yScale
            piece.position = self.position
            piece.zRotation = self.zRotation
            piece.physicsBody?.angularVelocity = angularVelocity
            
            nodeScene.addChild(piece)
        }
        
        self.removeFromParent()
        return self.pieces
    }
    
    func destroyWithBoom(boomStrength : Float, atPoint : CGPoint) -> Array<SKSpriteNode> {
        let fieldNode = SKFieldNode.radialGravityField()
        fieldNode.strength = -boomStrength
        fieldNode.position = atPoint
        nodeScene.addChild(fieldNode)
        nodeScene.run(SKAction.sequence([SKAction.wait(forDuration: 0.01), SKAction.removeFromParent()]))
        
        return destroy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        nodeScene = SKScene()
        super.init(coder: aDecoder)
        
        
    }
}
