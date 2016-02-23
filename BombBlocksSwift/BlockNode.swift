//
//  BlockNode.swift
//  BombBlocksSwift
//
//  Created by JackYeh on 2016/2/22.
//  Copyright © 2016年 MarriageKiller. All rights reserved.
//

import Foundation
import SpriteKit

class BlockNode:SKShapeNode {
    
    enum blockType {
        case Square,Circle,Triangle
    }
    
    var type :blockType?
    
    override init() {
        super.init()
    }
    
    convenience init(rect: CGRect, cornerRadius: CGFloat) {
        self.init()
        type = blockType.Square
        setStyle(UIColor.blueColor() , path: UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).CGPath)
    }
    
    convenience init(ovalInRec rect: CGRect) {
        self.init()
        type = blockType.Circle
        setStyle(UIColor.redColor(), path: UIBezierPath(ovalInRect:rect).CGPath)
    }
    
    convenience init(triangleInRec rect: CGRect) {
        self.init()
        type = blockType.Triangle
        let trianglePath = UIBezierPath()
        trianglePath.moveToPoint(CGPoint(x: rect.origin.x, y: rect.origin.y))
        trianglePath.addLineToPoint(CGPoint(x: rect.origin.x + CGRectGetWidth(rect)/2 , y: rect.origin.y + CGRectGetHeight(rect)))
        trianglePath.addLineToPoint(CGPoint(x: rect.origin.x + CGRectGetWidth(rect) , y: rect.origin.y))
        trianglePath.closePath()
        setStyle(UIColor.yellowColor() , path: trianglePath.CGPath)
    }
    
    func setStyle(color:UIColor , path:CGPathRef) {
        self.fillColor = color
        self.strokeColor = color
        self.glowWidth = 5
        self.alpha = 0.5
        self.path = path
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}