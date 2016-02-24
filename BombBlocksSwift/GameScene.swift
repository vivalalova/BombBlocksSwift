//
//  GameScene.swift
//  BombBlocksSwift
//
//  Created by JackYeh on 2016/2/18.
//  Copyright (c) 2016年 MarriageKiller. All rights reserved.
//

import SpriteKit
import Foundation

class GameScene: SKScene , ButtonActionDelegate  , ScoreDelegate {
    
    var boardNode : BoardNode!
    var resetButtonNode : ButtonNode!
    var scoreNode : ScoreNode!
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = UIColor.blackColor()

        /* Create board layout */
        boardNode = BoardNode.init(posX: CGRectGetWidth(self.frame), posY: CGRectGetHeight(self.frame))
        boardNode.delegate = self
        self.addChild(boardNode!)

        /* Add reset buttons to Scene */
        resetButtonNode = ButtonNode(rect: CGRectMake(0, 0, 100, 50), cornerRadius: 10 , viewRect:self.frame , buttonText:"Reset")
        resetButtonNode.delegate = self
        self.addChild(resetButtonNode!)
        
        /* Set Score label */
        scoreNode = ScoreNode(nodeRect: CGRectMake(0, 0, 100, 50), cornerRadius: 10, viewRect: self.frame, initialScore: 0)
        self.addChild(scoreNode)
        
        /* Create random block node */
        boardNode!.popBlockNode()
        
        /* Add Swipe gesture recognizer */
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view?.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view?.addGestureRecognizer(swipeLeft)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeUp.direction = UISwipeGestureRecognizerDirection.Up
        self.view?.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view?.addGestureRecognizer(swipeDown)
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
 
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            decideMoveDirection(swipeGesture.direction)
        }
    }
    
    func decideMoveDirection(direction:UISwipeGestureRecognizerDirection) {
        
        let moveDuration = 0.2
        let count = boardNode!.blockNodeContainer.count - 1;
        
        switch direction {
        case UISwipeGestureRecognizerDirection.Right:
            for var nodeIndex :Int = count ; nodeIndex >= 0  ; nodeIndex-- {
                if (nodeIndex % 4 != 3) {
                    boardNode.moveBlockNode(withAction: SKAction.moveByX(CGFloat(boardNode!.blockSize + boardNode!.moveGap * 2), y: 0, duration: moveDuration), fromCurrent: nodeIndex , toNeighbour: nodeIndex + 1)
                }
            }
            break
        case UISwipeGestureRecognizerDirection.Down:
            for var nodeIndex :Int = count ; nodeIndex >= 0  ; nodeIndex-- {
                if (nodeIndex  < 12) {
                    boardNode.moveBlockNode(withAction: SKAction.moveByX(0, y: CGFloat((boardNode!.blockSize + boardNode!.moveGap * 2) * -1), duration: moveDuration), fromCurrent: nodeIndex , toNeighbour: nodeIndex + 4)
                }
            }
            break
        case UISwipeGestureRecognizerDirection.Left:
            for var nodeIndex :Int = 0 ; nodeIndex <= count ; nodeIndex++ {
                if (nodeIndex % 4 != 0) {
                    boardNode.moveBlockNode(withAction: SKAction.moveByX(CGFloat((boardNode!.blockSize + boardNode!.moveGap * 2) * -1), y: 0, duration: moveDuration), fromCurrent: nodeIndex , toNeighbour: nodeIndex - 1)
                }
            }
            break
        case UISwipeGestureRecognizerDirection.Up:
            for var nodeIndex :Int = 0 ; nodeIndex <= count ; nodeIndex++ {
                if (nodeIndex > 3) {
                    boardNode.moveBlockNode(withAction: SKAction.moveByX(0, y: CGFloat(boardNode!.blockSize + boardNode!.moveGap * 2), duration: moveDuration), fromCurrent: nodeIndex , toNeighbour: nodeIndex - 4)
                }
            }
            break
        default:
            break
        }
        
        // Pop new block after each swipe
        let delay = dispatch_time( DISPATCH_TIME_NOW, Int64(Double(moveDuration*2) * Double(NSEC_PER_SEC)) )
        dispatch_after(delay, dispatch_get_main_queue()) {
            self.boardNode!.popBlockNode()
        }
    }
    
    func resetGame() {
        scoreNode.resetScore()
        boardNode!.resetBoard()
    }
    
    func changeScore() {
        scoreNode.changeScore()
    }

}
