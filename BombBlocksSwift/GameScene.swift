//
//  GameScene.swift
//  BombBlocksSwift
//
//  Created by JackYeh on 2016/2/18.
//  Copyright (c) 2016年 MarriageKiller. All rights reserved.
//

import SpriteKit
import Foundation

class GameScene: SKScene , ButtonActionDelegate  , BoardDelegate {
    
    var boardNode : BoardNode!
    var resetButtonNode : ButtonNode!
    var scoreNode : ScoreNode!
    var nextNode : Block!
    var gameOverNode : SKSpriteNode!
    var gameOverLabel : SKLabelNode!
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = UIColor.blackColor()
        
        /* Create board layout */
        boardNode = BoardNode.init(posX: CGRectGetWidth(self.frame), posY: CGRectGetHeight(self.frame))
        boardNode.delegate = self
        addChild(boardNode!)
        
        /* Add next node */
        let nextNodeSize = UIScreen.mainScreen().bounds.width * CGFloat(0.25)
        nextNode = Block(nextNodeRect: CGRectMake(0,0,nextNodeSize,nextNodeSize), viewSize: CGSizeMake(self.frame.size.width/2 , self.frame.size.height/2 - boardNode.boardSize/2 - 100))
        addChild(nextNode)
        
        /* Set Score label */
        scoreNode = ScoreNode(nodeRect: CGRectMake(0, 0, 100, 50), cornerRadius: 10, viewSize: CGSizeMake(self.frame.size.width/2 , self.frame.size.height/2 + boardNode.boardSize/2), initialScore: 0)
        addChild(scoreNode)
        
        /* Create random block node */
        boardNode!.popBlockNode()
        
        /* Game over node */
        gameOverNode = SKSpriteNode(color: UIColor.blackColor(), size: boardNode.frame.size)
        gameOverNode.alpha = 0
        gameOverNode.zPosition = 3
        gameOverNode.position = CGPointMake(self.frame.size.width/2 , self.frame.size.height/2)
        addChild(gameOverNode)
        
        /* Add reset buttons to Scene */
        resetButtonNode = ButtonNode(rect: CGRectMake(0,0,60,60), viewRect:self.frame , buttonText:"R")
        resetButtonNode.delegate = self
        resetButtonNode.zPosition = 3
        resetButtonNode.alpha = 0
        addChild(resetButtonNode!)

        /* Game over label node */
        gameOverLabel = SKLabelNode(fontNamed:"AmericanTypewriter-Bold")
        gameOverLabel.text = "Game Over";
        gameOverLabel.fontSize = 75;
        gameOverLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Baseline
        gameOverLabel.position = CGPointMake(self.frame.size.width/2 , self.frame.size.height/2)
        gameOverLabel.fontColor = UIColor.whiteColor()
        gameOverLabel.zPosition = 3
        gameOverLabel.alpha = 0
        addChild(gameOverLabel)
        
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
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            //decideMoveDirection(swipeGesture.direction)
            boardNode.swipeDirection = swipeGesture.direction
            boardNode.moveBlocks()
        }
    }
    
    // Mark: Delegation
    func resetGame() {
        scoreNode.resetScore()
        boardNode!.resetBoard()
    }
    
    func changeScore(addScore:Double) {
        scoreNode.changeScore(addScore)
    }
    
    func popNextNode() {
        
        nextNode.nextBlock?.setNextNode()
        nextNode.nextBlock?.PopNextBlockAnimation()
    }
    
    func getNextNodeBlockType()->Block.BlockType {
        
        return (nextNode.nextBlock?.type)!
    }
    
    func gameOver() {
        
        let fadeInAction = SKAction.fadeInWithDuration(0.3)
        gameOverNode.runAction(SKAction.fadeAlphaTo(0.8, duration: 0.3)) { () -> Void in
            self.resetButtonNode.runAction(fadeInAction)
            self.gameOverLabel.runAction(fadeInAction)
        }
    }
    
    func gameRestart(completion:()->()) {
        
        let fadeOutAction = SKAction.fadeOutWithDuration(0.3)
        self.resetButtonNode.runAction(fadeOutAction)
        self.gameOverLabel.runAction(fadeOutAction)
        gameOverNode.runAction(fadeOutAction) { () -> Void in
            completion()
        }
    }
    
    func setUserInteraction(allowInteraction:Bool) {
        userInteractionEnabled = allowInteraction
    }
}
