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
    
    override init() {
        super.init()
    }
    
    convenience init(rect: CGRect, cornerRadius: CGFloat) {
        self.init()
        self.path =  UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).CGPath
        self.fillColor = UIColor.grayColor()
        self.strokeColor = UIColor.grayColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}