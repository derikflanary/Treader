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

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
//MARK: - UPDATE MOVEMENT
    func update(delta: NSTimeInterval) {
        
        guard isJumping else {return}
        
        if physicsBody?.velocity.dy == 0{
            
            isJumping = false
            delegate?.playerLanded()
        }
    }
    
    func jump(gravityDirection: GravityDirection){
        
        switch gravityDirection{
            
        case .Down:
            physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 350.0))
        case .Up:
            physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: -250.0))
        }
        
        isJumping = true
    }
    
}

protocol PlayerDelegate{
    
    func playerLanded()
}

