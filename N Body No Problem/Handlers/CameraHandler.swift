//
//  CameraHandler.swift
//  N Body No Problem
//
//  Created by Jorge Torres on 8/11/24.
//

import Foundation
import SpriteKit

class CameraHandler: SKCameraNode {
    
    var isCameraZoomToggled = false
    
    func zoomTogglePressed(_ button: JKButtonNode){
        
        
        if(isCameraZoomToggled){
           // cameraReference.run(SKAction.scale(to: 1.0, duration: cameraZoomSpeed))
            //cameraReference.run(SKAction.moveBy(x: 0, y: -self.size.height / 2, duration: cameraZoomSpeed))
            self.setScale(2.0)
           // cameraReference.position.y = cameraReference.position.y - self.size.height / 2
            isCameraZoomToggled = false
        } else {
           // cameraReference.run(SKAction.scale(to: 2.0, duration: cameraZoomSpeed))
            //cameraReference.run(SKAction.moveBy(x: 0, y: self.size.height / 2, duration: cameraZoomSpeed))
            
            self.setScale(1.0)
          //  cameraReference.position.y = cameraReference.position.y + self.size.height / 2
            isCameraZoomToggled = true
        }
    }
    
}
