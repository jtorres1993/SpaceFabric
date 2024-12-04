//
//  GameViewController.swift
//  N Body No Problem
//
//  Created by Jorge Torres on 4/13/24.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            
            let scene = IntroScreen(size: view.frame.size)
    
            scene.scaleMode = .aspectFill
            scene.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
            view.presentScene(scene)
            
         
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
