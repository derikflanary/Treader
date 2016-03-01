//
//  GameScene.swift
//  Treader
//
//  Created by Derik Flanary on 3/1/16.
//  Copyright (c) 2016 Derik Flanary. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let Player: UInt32 = 0x00
    static let Star: UInt32 = 0x01
    static let Platform: UInt32 = 0x02
}

internal enum GravityDirection{
    case Up
    case Down
    
    mutating func flip() {
        switch self {
        case .Up:
            self = .Down
        case .Down:
            self = .Up
        }
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var previousUpdateTime = NSTimeInterval()
    let player = Player(color: UIColor.blueColor(), size: CGSizeMake(20, 50))
    var gravityDirection = GravityDirection.Down
    
    
    override init(size: CGSize) {
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.anchorPoint = CGPointMake(0.0, 0.0)

        //setup world physics
        physicsWorld.gravity = CGVectorMake(0, -2)
        physicsWorld.contactDelegate = self
        
        self.backgroundColor = SKColor(CGColor: UIColor.lightGrayColor().CGColor)
        
        player.position = CGPointMake(100, 110);
        player.zPosition = 15;
        player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
        player.physicsBody?.dynamic = true
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.restitution = 0.0
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Platform
        player.physicsBody?.collisionBitMask = PhysicsCategory.Platform
        player.physicsBody?.usesPreciseCollisionDetection = true
        player.physicsBody?.mass = 1
        self.scene?.addChild(player)
        
        let floor = Platform(color: UIColor.darkGrayColor(), size: CGSizeMake(400, 20))
        floor.position = CGPointMake(100, 50)
        self.addChild(floor)
        
        let roof = Platform(color: UIColor.darkGrayColor(), size: CGSizeMake(400, 20))
        roof.position = CGPointMake(100, 300)
        self.addChild(roof)
        
        let singleTap = UITapGestureRecognizer(target: self, action: "singleTapped")
        singleTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTap)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: "swiped")
        swipe.direction = .Up
        view.addGestureRecognizer(swipe)
        
        let swipe2 = UISwipeGestureRecognizer(target: self, action: "swiped")
        swipe2.direction = .Down
        view.addGestureRecognizer(swipe2)
        
    }
    
//MARK: - UPDATE FUNCTIONS
    override func update(currentTime: CFTimeInterval) {
        
        var delta : NSTimeInterval = currentTime - previousUpdateTime

        if (delta > 0.02) {
            delta = 0.02
        }

        previousUpdateTime = currentTime
        
        if player.isJumping{
            player.update(delta)
        }
        

        /* Called before each frame is rendered */
    }
//MARK: - GESTURE RECOGNIZER FUNCTIONS
    func swiped() {

        switchGravity()
    }
    
    func singleTapped() {
        
        guard !player.isJumping else{return}
        
        player.jump(gravityDirection)
    }
    
//MARK: - GRAVITY MANIPULATION
    private func switchGravity(){
        
        physicsWorld.gravity.dy = physicsWorld.gravity.dy * -1
        gravityDirection.flip()
    }
    
//MARK: - CONTANCT DELEGATE
    func didBeginContact(contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.Player != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Star != 0)) {
                player.isJumping = false
        }
        
    }
}
