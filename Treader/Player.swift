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
    var delegate: PlayerDelegate?
    var previousYVelocity: CGFloat = 0

//MARK: - INIT
    init(color: UIColor, size: CGSize){
        super.init(texture: nil, color: color, size: size)
        
        zPosition = 15;
        physicsBody = SKPhysicsBody(rectangleOfSize: size)
        physicsBody?.dynamic = true
        physicsBody?.allowsRotation = false
        physicsBody?.restitution = 0.0
        physicsBody?.categoryBitMask = PhysicsCategory.Player
        physicsBody?.contactTestBitMask = PhysicsCategory.Platform
        physicsBody?.collisionBitMask = PhysicsCategory.Platform
        physicsBody?.usesPreciseCollisionDetection = true
        physicsBody?.mass = 1
        previousYVelocity = (physicsBody?.velocity.dy)!

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - UPDATE MOVEMENT
    func update(delta: NSTimeInterval) {
        
        if physicsBody?.velocity.dy > 0 || physicsBody?.velocity.dy < 0{

            isJumping = true
        }
        
        if physicsBody?.velocity.dy == 0 && previousYVelocity != 0 && isJumping{
            isJumping = false
            delegate?.playerLanded()
        }
        
        previousYVelocity = (physicsBody?.velocity.dy)!
        
    }
    
    func jump(gravityDirection: GravityDirection, timeHeld: NSTimeInterval){
        var jumpPwr: CGFloat = 250 * (CGFloat(timeHeld) * 1.75 + 1)
        if jumpPwr > 375{
            jumpPwr = 375
        }
        print(jumpPwr)
        switch gravityDirection{

        case .Down:
            physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: jumpPwr))
        case .Up:
            physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: -jumpPwr))
        }
        
        isJumping = true
    }
    
}

protocol PlayerDelegate{
    
    func playerLanded()
}

