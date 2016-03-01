//
//  Player.swift
//  Treader
//
//  Created by Derik Flanary on 3/1/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import SpriteKit

class Player: SKSpriteNode {
    
    //MARK: - PROPERTIES
    var isJumping = false
    var changedGravity = false
    
    //MARK: - UPDATE MOVEMENT
    func update(delta: NSTimeInterval) {
        
        if physicsBody?.velocity.dy == 0{
            isJumping = false
        }
    }
    
    func collisionBoundingBox() -> CGRect {
        
        return CGRectInset(self.frame, 2, 0);
    }
    
    func jump(gravityDirection: GravityDirection){
        switch gravityDirection{
        case .Down:
            physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 250.0))
        case .Up:
            physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: -250.0))
        }
        
        isJumping = true
    }
    
}

