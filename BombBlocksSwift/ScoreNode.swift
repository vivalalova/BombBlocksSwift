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
    
    init(nodeRect: CGRect, cornerRadius: CGFloat , viewSize:CGSize , initialScore:Int) {
        self.score = initialScore

        buttonLabel = SKLabelNode(fontNamed:"AmericanTypewriter-Bold")
        buttonLabel.text = String(score);
        buttonLabel.fontSize = 90;
        buttonLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Baseline
        buttonLabel.fontColor = UIColor(white: 1, alpha: 0.8)
        
        super.init()
        self.path = UIBezierPath(roundedRect: nodeRect, cornerRadius: cornerRadius).CGPath
        self.position = CGPointMake( viewSize.width, viewSize.height + 80)
        self.fillColor = UIColor.clearColor()
        self.strokeColor = UIColor.clearColor()
        self.addChild(buttonLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeScore(addScore:Double) {
        
        let currentScore = score
        let actionDuration :NSTimeInterval = 0.5
        score += Int(addScore)

        let changeScore = SKAction.customActionWithDuration(actionDuration) { (SKNode, CGFloat) -> Void in
            let updateScore = currentScore + Int( addScore * (Double(CGFloat)/actionDuration) )
            self.buttonLabel.text = String(updateScore)
        }
        self.runAction(changeScore)
    }
    
    func resetScore() {
        score = 0
        buttonLabel.text = String(score)
    }

}
