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

class ButtonNode: SKSpriteNode {
    
    var delegate: ButtonActionDelegate?
    
    init(rect: CGRect, viewRect:CGRect , buttonText:String) {
        
        let color = UIColor.whiteColor()
        UIGraphicsBeginImageContext(rect.size);
        color.setFill()
        let path = UIBezierPath(roundedRect: rect, cornerRadius: rect.size.width/2)
        path.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        let texture = SKTexture(image: image)
        super.init(texture: texture, color: color, size: rect.size)

        self.userInteractionEnabled = true
        self.position = CGPointMake( viewRect.size.width / 2 , (viewRect.size.height - rect.size.height)/2 - 90)
        self.name = "resetButton"
        
        let buttonLabel = SKLabelNode(fontNamed:"AmericanTypewriter-Bold")
        buttonLabel.text = buttonText;
        buttonLabel.fontSize = 50;
        buttonLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        buttonLabel.fontColor = UIColor.blackColor()
        buttonLabel.zPosition = 3
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
