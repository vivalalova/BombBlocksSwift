//
//  ScoreNode.swift
//  BombBlocksSwift
//
//  Created by JackYeh on 2016/2/24.
//  Copyright © 2016年 MarriageKiller. All rights reserved.
//

import SpriteKit

class ScoreNode: SKShapeNode {
    
    var score : Int
    var buttonLabel : SKLabelNode
    
    init(nodeRect: CGRect, cornerRadius: CGFloat , viewRect:CGRect , initialScore:Int) {
        self.score = initialScore

        buttonLabel = SKLabelNode(fontNamed:"AmericanTypewriter-Bold")
        buttonLabel.text = String(score);
        buttonLabel.fontSize = 90;
        buttonLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Baseline
        buttonLabel.position = CGPointMake(nodeRect.size.width/2 , nodeRect.size.height/2-(nodeRect.size.height - buttonLabel.fontSize))
        buttonLabel.fontColor = UIColor(white: 1, alpha: 0.8)
        
        super.init()
        self.path = UIBezierPath(roundedRect: nodeRect, cornerRadius: cornerRadius).CGPath
        self.position = CGPointMake(
            (viewRect.size.width - nodeRect.size.width)/2,
            (viewRect.size.height - nodeRect.size.height)-140)
        self.fillColor = UIColor.clearColor()
        self.strokeColor = UIColor.clearColor()
        self.addChild(buttonLabel)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeScore(addScore:Double) {
        
        let currentScore = self.score
        let actionDuration :NSTimeInterval = 0.5
        
        // Show
        let changeScore = SKAction.customActionWithDuration(actionDuration) { (SKNode, CGFloat) -> Void in
            // Change number
            self.score = currentScore + Int( addScore * (Double(CGFloat)/actionDuration) )
            self.buttonLabel.text = String(self.score)
        }
        self.runAction(changeScore)

    }
    
    func resetScore() {
        score = 0
        buttonLabel.text = String(score)
    }

}
