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
    
    enum blockType {
        case Blue,Red,Yellow , Green
    }
    
    var type :blockType?
    
    init(rect: CGRect, color:UIColor) {
        
        super.init()
        let blockCornerRadius : CGFloat = 0
        let pathOrigin = CGFloat(rect.size.width / -2)
        let pathSize = rect.size.width
        let positionX = rect.origin.x - pathOrigin
        let positionY = rect.origin.y - pathOrigin
        self.position = CGPointMake(positionX, positionY)
        setStyle(color , path: UIBezierPath(roundedRect: CGRectMake(pathOrigin, pathOrigin, pathSize, pathSize), cornerRadius: blockCornerRadius).CGPath)
    }
    
    func setStyle(color:UIColor , path:CGPathRef) {
        
        self.fillColor = color
        self.strokeColor = color
//        self.glowWidth = 5
//        self.alpha = 0.5
        self.path = path
        self.hidden = true

        switch color  {
        case UIColor.blueColor() :
            self.type = blockType.Blue
            break
        case UIColor.redColor():
            self.type = blockType.Red
            break
        case UIColor.yellowColor():
            self.type = blockType.Yellow
            break
        case UIColor.greenColor():
            self.type = blockType.Green
            break
        default :
            break
        }
        
//        let glowActionOn = SKAction.customActionWithDuration(2) { (SKNode, CGFloat) -> Void in
//            
//            self.glowWidth = 5 - CGFloat/2
//        }
//        
//        let glowActionOff = SKAction.customActionWithDuration(2) { (SKNode, CGFloat) -> Void in
//            
//            self.glowWidth = CGFloat/2 * 5
//        }
//        
//        let sequence = SKAction.sequence([glowActionOn,glowActionOff])
//        let repeatForever = SKAction.repeatActionForever(sequence)
//        self.runAction(repeatForever)
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func PopBlockAnimation(completion:()?) {
        
        self.hidden = false
        self.xScale = 0.1
        self.yScale = 0.1
        let scaleUpAction = SKAction.scaleTo(1.3, duration: 0.13)
        let scaleDownAction = SKAction.scaleTo(1, duration: 0.05)
        
        if (completion == nil) {
            
            self.runAction(SKAction.sequence([scaleUpAction,scaleDownAction]))

        } else {
        
            self.runAction(SKAction.sequence([scaleUpAction,scaleDownAction]), completion: { () -> Void in
                
                completion
            })
        }
    }
    
}