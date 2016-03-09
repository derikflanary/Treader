//
//  GameScene.swift
//  Treader
//
//  Created by Derik Flanary on 3/1/16.
//  Copyright (c) 2016 Derik Flanary. All rights reserved.
//

import SpriteKit
import SceneKit

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

class GameScene: SKScene, SKPhysicsContactDelegate, PlayerDelegate {
  
//MARK: - PROPERTIES
    var previousUpdateTime = NSTimeInterval()
    let player = Player(color: UIColor.blueColor(), size: CGSizeMake(10, 40))
    var gravityDirection = GravityDirection.Down
    var platforms = [Platform]()
    var gravityChanged = false
    let cameraNode = SKCameraNode()
    var firstPlatform = true
    var touchStartTime = NSTimeInterval()
    var totalTouchTime = NSTimeInterval()
    
//MARK: - INIT
    override init(size: CGSize) {
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//MARK: - GAME SETUP
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        setupWorld()
        
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(cameraNode)
        camera = cameraNode
        
        let singleTap = UITapGestureRecognizer(target: self, action: "singleTapped")
        singleTap.numberOfTapsRequired = 1
//        view.addGestureRecognizer(singleTap)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipe.direction = .Up
        view.addGestureRecognizer(swipe)
        
        let swipe2 = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipe2.direction = .Down
        view.addGestureRecognizer(swipe2)
        
    }
    
    private func setupWorld() {
        self.anchorPoint = CGPointMake(0.0, 0.0)
        
        let stars = SKEmitterNode(fileNamed: "Stars")
        stars?.targetNode = self.scene
        stars?.advanceSimulationTime(NSTimeInterval(15))
        stars?.position = CGPointMake(frame.width/2, frame.height/2)
        stars?.particlePositionRange = CGVector(dx: frame.size.width, dy: frame.size.height)
        self.addChild(stars!)
        
        //setup world physics
        physicsWorld.gravity = CGVectorMake(0, -5)
        physicsWorld.contactDelegate = self
        
        self.backgroundColor = SKColor(CGColor: UIColor.blackColor().CGColor)
        
        player.position = CGPointMake(100, 110);
        player.delegate = self
        self.scene?.addChild(player)
        
        let floor = Platform(color: UIColor.darkGrayColor(), size: CGSizeMake(size.width - 100, 5))
        floor.position = CGPointMake(size.width/4, 50)
        self.addChild(floor)
        floor.move(size.width)
        
        spawnPlatforms()
        
    }
    
//MARK: - UPDATE FUNCTIONS
    override func update(currentTime: CFTimeInterval) {
        
        var delta : NSTimeInterval = currentTime - previousUpdateTime

        if (delta > 0.02) {
            delta = 0.02
        }

        previousUpdateTime = currentTime
        
        player.update(delta)
        
        //Gameover check
        if player.position.y > size.height + 100 || player.position.y < -100{
            
            self.removeAllChildren()
            self.removeAllActions()
            let gameScene = GameScene(size: self.size)
            let transition = SKTransition.flipVerticalWithDuration(2.0)
            gameScene.scaleMode = SKSceneScaleMode.AspectFill
            self.scene!.view?.presentScene(gameScene, transition: transition)
            
        }
        /* Called before each frame is rendered */
    }
    
    func spawnPlatforms(){
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addPlatform),
                SKAction.waitForDuration(1.2)
                ])
            ))
        
//        runAction(SKAction.scaleBy(1.5, duration: 1.0))
    }
    
    func addPlatform(){

        let platform = Platform(color: UIColor.darkGrayColor(), size: CGSizeMake(200, 5))
        
        // Determine where to spawn the platform along the Y axis
        var actualY = random(min: platform.size.height/2, max: size.height - platform.size.height/2)
        
        if firstPlatform{
            actualY = 200
            firstPlatform = false
        }
        // Position the platform slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        platform.position = CGPoint(x: (view?.bounds.width)! + platform.size.width, y: actualY)
        
        addChild(platform)
        
        platform.move(size.width)
        
        cameraNode.runAction(SKAction.scaleTo(1.2, duration: 1.0))
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
//MARK: - TOUCHES
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchStartTime = previousUpdateTime
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        touchStartTime = 0
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard touchStartTime != 0 else {return}
        totalTouchTime = previousUpdateTime - touchStartTime
        
        guard !player.isJumping else{return}
        player.jump(gravityDirection, timeHeld: totalTouchTime)
    }
//MARK: - GESTURE RECOGNIZER FUNCTIONS
    func swiped(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
         
            switchGravity(swipeGesture.direction)
        }
    }
    
    func singleTapped() {
        
        guard !player.isJumping else{return}
        
//        player.jump(gravityDirection)
    }
    
//MARK: - GRAVITY MANIPULATION
    private func switchGravity(swipedDirection: UISwipeGestureRecognizerDirection){
        
        guard !gravityChanged else {return}
        
        if swipedDirection == .Up && gravityDirection == .Down || swipedDirection == .Down && gravityDirection == .Up{
        
            physicsWorld.gravity.dy = physicsWorld.gravity.dy * -1
            gravityDirection.flip()
            gravityChanged = true
            player.isJumping = true
        }
    }
    
//MARK: - PLAYER DELEGATE
    func playerLanded() {
        
        gravityChanged = false
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
        }
        
    }
}
