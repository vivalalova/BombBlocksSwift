//
//  Block.swift
//  BombBlocksSwift
//
//  Created by JackYeh on 2016/3/1.
//  Copyright © 2016年 MarriageKiller. All rights reserved.
//

import SpriteKit

class Block:SKSpriteNode {
    
    enum BlockType :Int {
        case Blue = 0 ,Red = 1,Yellow = 2, Green = 3 , Background = 4
    }
    
    enum ExpandType {
        case Vertical , Horizontal , Square
    }
    
    enum AnimationDirection :Int {
        case Down = 0 , Left = 1 , Right = 2, Up = 3
    }

    var type :BlockType!
    var nextBlock :Block?
    var blockColor:UIColor!
    
    init(emptyBlockRect: CGRect) {

        super.init(texture: nil, color: UIColor.clearColor(), size: emptyBlockRect.size)
        setBlockType(BlockType.Background)
        createBlockTexture(emptyBlockRect.size)
        position = CGPointMake( emptyBlockRect.origin.x + emptyBlockRect.size.width/2 , emptyBlockRect.origin.y + emptyBlockRect.size.width/2 )
        zPosition = 1
    }
    
    init(nextNodeRect: CGRect, viewSize: CGSize) {
        
        super.init(texture: nil, color: UIColor.clearColor(), size: nextNodeRect.size)
        color = UIColor(white: 0.15, alpha: 1)
        createBlockTexture(nextNodeRect.size)
        position =  CGPointMake( viewSize.width , viewSize.height)
        nextBlock = Block(nextBlockRect: CGRectMake(0,0,nextNodeRect.size.width-25,nextNodeRect.size.height-25))
        addChild(nextBlock!)
        nextBlock!.PopBlockAnimation({})
    }
    
    init(gameBlockRect: CGRect , newBlockType:BlockType) {
        
        super.init(texture: nil, color: UIColor.clearColor(), size: gameBlockRect.size)
        setBlockType(newBlockType)
        createBlockTexture(gameBlockRect.size)
        position = CGPointMake( gameBlockRect.origin.x + gameBlockRect.size.width/2 , gameBlockRect.origin.y + gameBlockRect.size.width/2 )
        zPosition = 2
    }
    
    init(nextBlockRect: CGRect) {
        
        super.init(texture: nil, color: UIColor.clearColor(), size: nextBlockRect.size)
        setBlockType(nil)
        createBlockTexture(nextBlockRect.size)
        position = CGPointMake( nextBlockRect.origin.x  , nextBlockRect.origin.y  )
        zPosition = 1
    }
    
    func createBlockTexture(size:CGSize) {
        
        UIGraphicsBeginImageContext(size);
        self.color.setFill()
        let path = UIBezierPath(roundedRect: CGRectMake(0, 0, size.width, size.height), cornerRadius: size.width/4)
        path.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        texture = SKTexture(image: image)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBlockType(blockType:BlockType?) {
        
        if let toType = blockType {
            self.type = toType
        } else {
            let randomBlockType = Int(arc4random_uniform(UInt32(3)))
            self.type = BlockType(rawValue: randomBlockType)
        }
        setColorByBlockType(self.type!)
    }
    
    func setColorByBlockType(type:BlockType) {
        
        var newColor : UIColor!
        
        switch type {
        case BlockType.Blue :
            newColor = UIColor(red: 99/255, green: 173/255, blue: 244/255, alpha: 1)
            break
        case BlockType.Red :
            newColor = UIColor(red: 242/255, green: 110/255, blue: 134/255, alpha: 1)
            break
        case BlockType.Green:
            newColor = UIColor(red: 66/255, green: 168/255, blue: 129/255, alpha: 1)
            break
        case BlockType.Yellow :
            newColor = UIColor(red: 217/255, green: 186/255, blue: 95/255, alpha: 1)
            break
        case BlockType.Background :
            newColor = UIColor.blackColor()
        }
        
        self.color = newColor
    }
    
    func setNextNode() {
        setBlockType(nil)
        createBlockTexture(self.size)
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
    
    func expandBlockAnimation(completion:()->(), expandType:ExpandType) {
        
        var action : SKAction!
        let interval : NSTimeInterval = 0.2
        switch expandType {
        case ExpandType.Vertical :
            action = SKAction.scaleXBy(0.25, y: 3, duration: interval)
            break
        case ExpandType.Horizontal :
            action = SKAction.scaleXBy(3, y: 0.25, duration: interval)
            break
        default :
            break
        }
        self.runAction(action, completion: { () -> Void in
            completion()
        })
    }
    
    func squareBlockAnimation(completion:()->() , direction:AnimationDirection) {
        
        let size = self.size.width/2
        let actionDuration : NSTimeInterval = 0.2
        let pathWidth : CGFloat = size/1.5
        var pathNode : SKShapeNode!
        var action : SKAction!
        
        switch direction {
            
        case AnimationDirection.Down :
            pathNode = SKShapeNode(rect: CGRectMake(0,0,pathWidth,size))
            pathNode.position = CGPointMake(pathWidth/2 * -1, -size)
            action = SKAction.moveByX(0, y: -size, duration: actionDuration)
            break
        case AnimationDirection.Up :
            pathNode = SKShapeNode(rect: CGRectMake(0,0,pathWidth,size))
            pathNode.position = CGPointMake(pathWidth/2 * -1, 0)
            action = SKAction.moveByX(0, y: size, duration: actionDuration)
            break
        case AnimationDirection.Right :
            pathNode = SKShapeNode(rect: CGRectMake(0,0,size, pathWidth))
            pathNode.position = CGPointMake(0,pathWidth/2 * -1)
            action = SKAction.moveByX(size, y: 0, duration: actionDuration)
            break
        case AnimationDirection.Left :
            pathNode = SKShapeNode(rect: CGRectMake(0,0,-size, pathWidth))
            pathNode.position = CGPointMake(0,pathWidth/2 * -1)
            action = SKAction.moveByX(-size, y: 0, duration: actionDuration)
            break
        }
        
        pathNode.strokeColor = self.color
        pathNode.fillColor = self.color
        self.addChild(pathNode)
//        pathNode.zPosition = 3
        pathNode.runAction(action, completion: { () -> Void in
            completion()
        })
        
    }
}
