//
//  Block.swift
//  BombBlocksSwift
//
//  Created by JackYeh on 2016/3/1.
//  Copyright © 2016年 MarriageKiller. All rights reserved.
//

import SpriteKit

class Block:SKSpriteNode {
    
    enum MainType :Int {
        case Normal = 0 , Bomb = 1, Background = 2, Next = 3
    }
    
    enum SubType :Int {
        case Blue = 0 ,Red = 1,Yellow = 2, Green = 3 ,Black = 4 , AlphaWhite = 5
    }
    
    enum ExpandType {
        case Vertical , Horizontal , Square
    }
    
    enum AnimationDirection :Int {
        case Down = 0 , Left = 1 , Right = 2, Up = 3
    }

    var type :MainType!
    var subType :SubType!
    var bombCounter = 0
    var nextBlock :Block?
    var isAvailable = true
    var counterLabel : SKLabelNode?
    var toBeCancelled = false
    
    init(blockRect:CGRect , blockType:MainType) {
        
        super.init(texture: nil, color: UIColor.clearColor(), size: blockRect.size)
        setBlockType(blockType)
        position = CGPointMake( blockRect.origin.x + blockRect.size.width/2 , blockRect.origin.y + blockRect.size.width/2 )
    }
    
    /* Set bomb from next block node */
    init(blockRect:CGRect , blockType:MainType ,  blockSubType:SubType) {
        
        super.init(texture: nil, color: UIColor.clearColor(), size: blockRect.size)
        self.type = blockType
        self.subType = blockSubType
        self.texture = TextureStore.sharedInstance.bombTextures[self.subType.rawValue]
        self.zPosition = 3
        isAvailable = false
        addBombCounter()
        position = CGPointMake( blockRect.origin.x + blockRect.size.width/2 , blockRect.origin.y + blockRect.size.width/2 )
    }
    
    /* Set normal block from next block node */
    init(blockRect:CGRect , blockSubType:SubType) {
        
        super.init(texture: nil, color: UIColor.clearColor(), size: blockRect.size)
        self.type = MainType.Normal
        self.subType = blockSubType
        self.color = TextureStore.sharedInstance.blockColor[self.subType.rawValue]
        self.texture = TextureStore.sharedInstance.blockTextures[self.subType.rawValue]
        self.zPosition = 3
        position = CGPointMake( blockRect.origin.x + blockRect.size.width/2 , blockRect.origin.y + blockRect.size.width/2 )
    }
    
    init(nextNodeRect: CGRect, viewSize: CGSize) {
        
        super.init(texture: nil, color: UIColor.clearColor(), size: nextNodeRect.size)
        setBlockType(Block.MainType.Next)
        position =  CGPointMake( viewSize.width , viewSize.height)
        
        /* Next node content */
        let nextBlockSize :CGFloat = nextNodeRect.size.width-25
        nextBlock = Block(blockRect: CGRectMake(-(nextBlockSize)/2,-(nextBlockSize)/2,nextBlockSize,nextBlockSize), blockType: Block.MainType.Normal)
        addChild(nextBlock!)
        nextBlock!.PopBlockAnimation({})
    }
    
    func addBombCounter() {
        
//        let position = CGPointMake(0, self.size.width/2 + 1)
//        if let particles = SKEmitterNode(fileNamed: "SparkParticle.sks") {
//            particles.position = position
//            particles.particleColor = self.color
//            particles.particleColorBlendFactor = 1.0;
//            particles.particleColorSequence = nil;
//            particles.zPosition = 3
//            self.addChild(particles)
//        }
        
        bombCounter = 10 + Int(arc4random_uniform(UInt32(10)))
        
        counterLabel = SKLabelNode(fontNamed:"AmericanTypewriter-bold")
        counterLabel?.text = String(bombCounter);
        counterLabel?.fontSize = 34 * UIScreen.mainScreen().bounds.width / 320
        counterLabel?.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        counterLabel?.fontColor = UIColor.blackColor()
        counterLabel?.position = CGPointMake(0, 0)
        counterLabel?.zPosition = 5
        self.addChild(counterLabel!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBlockType(blockType:MainType) {
        
        self.type = blockType

        switch blockType {
        case MainType.Normal :
            let randomBlockType = Int(arc4random_uniform(UInt32(4)))
            self.subType = SubType(rawValue: randomBlockType)
            self.texture = TextureStore.sharedInstance.blockTextures[randomBlockType]
            self.zPosition = 3
            break
        case MainType.Bomb :
            let randomBlockType = Int(arc4random_uniform(UInt32(4)))
            self.subType = SubType(rawValue: randomBlockType)
            self.texture = TextureStore.sharedInstance.bombTextures[randomBlockType]
            self.zPosition = 3
            isAvailable = false
            addBombCounter()
            break
        case MainType.Background :
            self.subType = SubType.Black
            self.texture = TextureStore.sharedInstance.blockTextures[4]
            self.zPosition = 2
            isAvailable = false
            break
        case MainType.Next :
            self.subType = SubType.AlphaWhite
            self.texture = TextureStore.sharedInstance.blockTextures[5]
            self.zPosition = 1
            break
        }
        self.color = TextureStore.sharedInstance.blockColor [self.subType.rawValue]
    }
    
    func PopBlockAnimation(gameOverBlock:()->()) {
        
        self.hidden = false
        self.xScale = 0.5
        self.yScale = 0.5
        let scaleUpAction = SKAction.scaleTo(1.4, duration: 0.12)
        let scaleDownAction = SKAction.scaleTo(1, duration: 0.04)
        self.runAction(SKAction.sequence([scaleUpAction,scaleDownAction]), completion: { () -> Void in
            gameOverBlock()
        })
    }
    
    func PopNextBlockAnimation() {
        
        self.hidden = false
        self.xScale = 1.15
        self.yScale = 1.15
        let scaleDownAction = SKAction.scaleTo(1, duration: 0.3)
        self.runAction(scaleDownAction)
    }
    
    func extendBlockAnimation(completion:()->() , direction:AnimationDirection) {
        
        let size :CGFloat = 22
        let actionDuration : NSTimeInterval = 0.2
        let pathWidth : CGFloat = self.size.width/3
        var pathNode : SKShapeNode!
        var action : SKAction!
        
        switch direction {
            
        case AnimationDirection.Down :
            pathNode = SKShapeNode(rect: CGRectMake(pathWidth / -2,(self.size.width) / -2,pathWidth,size))
            action = SKAction.moveByX(0, y: -size, duration: actionDuration)
            break
        case AnimationDirection.Up :
            pathNode = SKShapeNode(rect: CGRectMake(pathWidth / -2,self.size.width/2 - size,pathWidth,size))
            action = SKAction.moveByX(0, y: size, duration: actionDuration)
            break
        case AnimationDirection.Right :
            
            pathNode = SKShapeNode(rect: CGRectMake(self.size.width/2 - size,pathWidth / -2,size , pathWidth))
            action = SKAction.moveByX(size, y: 0, duration: actionDuration)
            break
        case AnimationDirection.Left :
            pathNode = SKShapeNode(rect: CGRectMake((self.size.width) / -2,pathWidth / -2,size,pathWidth))
            action = SKAction.moveByX(-size, y: 0, duration: actionDuration)
            break
        }
        pathNode.strokeColor = self.color
        pathNode.fillColor = self.color
        self.addChild(pathNode)
        pathNode.zPosition = -1
        pathNode.runAction(action, completion: { () -> Void in
            completion()
        })
    }
    
    func triggerBomb(completion:()->()) {
        
        let scaleUpAction = SKAction.scaleBy(1.5, duration: 0.2)
        let scaleBackAction = SKAction.scaleTo(1, duration: 0.2)
        let actionSequence = SKAction.sequence([scaleUpAction,scaleBackAction,scaleUpAction])
        self.runAction(actionSequence) { () -> Void in
            self.removeAllChildren()
            self.alpha = 0
            self.subType = SubType.Black
            completion()
        }
    }
    
    func sealBackground() {

        self.runAction(SKAction.scaleTo(0, duration: 0.5))
    }
    
    func decreaseBombCounter() {
        
        bombCounter--
        counterLabel?.text = String(bombCounter)
        
    }
    
    func updateBombCounter(counter:Int) {
        bombCounter = counter
        counterLabel?.text = String(bombCounter)

    }
    
}
