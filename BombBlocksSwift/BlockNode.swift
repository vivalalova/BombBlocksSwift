//
//  BlockNode.swift
//  BombBlocksSwift
//
//  Created by JackYeh on 2016/2/22.
//  Copyright © 2016年 MarriageKiller. All rights reserved.
//

//import Foundation
import SpriteKit

class BlockNode:SKShapeNode {
    
    enum BlockType :Int {
        case Blue = 0 ,Red = 1,Yellow = 2, Green = 3
    }
    
    enum ExpandType {
        case Vertical , Horizontal
    }
    
    var type :BlockType!
    var nextBlock :BlockNode?
    
    init(rect: CGRect) {
        
        super.init()
        let blockCornerRadius : CGFloat = 10
        let pathOrigin = CGFloat(rect.size.width / -2)
        let pathSizeWidth = rect.size.width
        let pathSizeHeight = rect.size.height
        let positionX = rect.origin.x - pathOrigin
        let positionY = rect.origin.y - pathOrigin
        self.position = CGPointMake(positionX, positionY)
        setStyle(UIBezierPath(roundedRect: CGRectMake(pathOrigin, pathOrigin, pathSizeWidth, pathSizeHeight), cornerRadius: blockCornerRadius).CGPath)
    }
    
    init(nextNodeRect: CGRect, viewSize: CGSize) {
        
        super.init()
        let blockCornerRadius : CGFloat = 10
        self.position =  CGPointMake( (viewSize.width - nextNodeRect.size.width) / 2 , (viewSize.height - nextNodeRect.size.height) / 10)
        self.path = UIBezierPath(roundedRect: nextNodeRect, cornerRadius: blockCornerRadius).CGPath
        self.hidden = false
        self.strokeColor = UIColor(white: 0.3, alpha: 1)
        self.lineWidth = 8
        self.fillColor = UIColor.clearColor()
        nextBlock = BlockNode(rect: CGRectMake(2,2,nextNodeRect.size.width-4,nextNodeRect.size.height-4))
        nextBlock!.hidden = false
        addChild(nextBlock!)
        nextBlock?.PopBlockAnimation({})
    }
    
    func setStyle(path:CGPathRef) {

        self.path = path
        self.hidden = true
        setBlockType(nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBlockType(blockType:BlockType?) {
        
        if let toType = blockType {
            type = toType
        } else {
            let randomBlockType = Int(arc4random_uniform(UInt32(4)))
            type = BlockType(rawValue: randomBlockType)
        }
        setColorByBlockType(self.type!)
    }
    
    func setColorByBlockType(type:BlockType) {
        
        var color : UIColor!
        
        switch type {
        case BlockType.Blue :
            color = UIColor(red: 99/255, green: 173/255, blue: 244/255, alpha: 1)
            break
        case BlockType.Red :
            color = UIColor(red: 242/255, green: 110/255, blue: 134/255, alpha: 1)
            break
        case BlockType.Green:
            color = UIColor(red: 66/255, green: 168/255, blue: 129/255, alpha: 1)
            break
        case BlockType.Yellow :
            color = UIColor(red: 217/255, green: 186/255, blue: 95/255, alpha: 1)
            break
        }
        
        self.fillColor = color
        self.strokeColor = color
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
    
    func expandBlockAnimation(createCancelBlock:()->() , expandType:ExpandType) {
        
        var action : SKAction!
        let interval : NSTimeInterval = 0.25
        switch expandType {
        case ExpandType.Vertical :
            action = SKAction.scaleXBy(0.25, y: 3, duration: interval)
            break
        case ExpandType.Horizontal :
            action = SKAction.scaleXBy(3, y: 0.25, duration: interval)
            break
        }
        self.runAction(action, completion: { () -> Void in
            createCancelBlock()
        })
    }
}