//
//  ButtonNode.swift
//  BombBlocksSwift
//
//  Created by JackYeh on 2016/2/23.
//  Copyright © 2016年 MarriageKiller. All rights reserved.
//

import SpriteKit

protocol ButtonActionDelegate {
    func resetGame()
}

class ButtonNode: SKShapeNode {
    
    var delegate: ButtonActionDelegate?
    
    init(rect: CGRect, cornerRadius: CGFloat , viewRect:CGRect , buttonText:String) {

        super.init()
        self.userInteractionEnabled = true
        self.path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).CGPath
        self.position = CGPointMake(
            (viewRect.size.width - rect.size.width)/2,
            (viewRect.size.height - rect.size.height)/16)
        self.fillColor = UIColor.whiteColor()
        self.strokeColor = UIColor.whiteColor()
        self.name = "resetButton"
        
        let buttonLabel = SKLabelNode(fontNamed:"TamilSangamMN-Bold")
        buttonLabel.text = buttonText;
        buttonLabel.fontSize = 30;
        buttonLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Baseline
        buttonLabel.position = CGPointMake(rect.size.width/2 , rect.size.height/2-10)
        buttonLabel.fontColor = UIColor.blackColor()
        self.addChild(buttonLabel)

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (self.name == "resetButton") {
            
            delegate?.resetGame()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
