//
//  Platform.swift
//  Treader
//
//  Created by Derik Flanary on 3/1/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import SpriteKit

class Platform: SKSpriteNode {
    
    init(color: UIColor, size: CGSize){
        super.init(texture: nil, color: color, size: size)
        
        zPosition = 15
        physicsBody = SKPhysicsBody(rectangleOfSize: size)
        physicsBody?.dynamic = false
        physicsBody?.restitution = 0.0
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = PhysicsCategory.Platform
        physicsBody?.collisionBitMask = PhysicsCategory.Player
        physicsBody?.allowsRotation = false

    }
    
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func move(totalWidth: CGFloat){
        let moveLeft = SKAction.moveToX(position.x - totalWidth - self.size.width, duration: 3)
        
        let move = SKAction.moveByX(-totalWidth - 500, y: 0, duration: 4)
        let die = SKAction.removeFromParent()
        runAction(SKAction.sequence([move, die]))

    }

}
