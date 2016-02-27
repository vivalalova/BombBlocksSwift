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
    var nextNode : BlockNode!
    var gameOverNode : SKShapeNode!
    var gameOverLabel : SKLabelNode!
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = UIColor.blackColor()

        /* Create board layout */
        boardNode = BoardNode.init(posX: CGRectGetWidth(self.frame), posY: CGRectGetHeight(self.frame))
        boardNode.delegate = self
        self.addChild(boardNode!)
        
        /* Add next node */
        nextNode = BlockNode(nextNodeRect: CGRectMake(0,0,50,50), viewSize: self.frame.size)
        self.addChild(nextNode)
        
        /* Set Score label */
        scoreNode = ScoreNode(nodeRect: CGRectMake(0, 0, 100, 50), cornerRadius: 10, viewRect: self.frame, initialScore: 0)
        self.addChild(scoreNode)
        
        /* Create random block node */
        boardNode!.popBlockNode()
        
        gameOverNode = SKShapeNode(rect: self.frame)
        gameOverNode.fillColor = UIColor.blackColor()
        gameOverNode.strokeColor = UIColor.blackColor()
        gameOverNode.alpha = 0.8
        gameOverNode.zPosition = 1
        gameOverNode.position = CGPointMake(0,self.frame.size.height)
        addChild(gameOverNode)
        
        /* Add reset buttons to Scene */
        resetButtonNode = ButtonNode(rect: CGRectMake(0,0,60,60), viewRect:self.frame , buttonText:"R")
        resetButtonNode.delegate = self
        resetButtonNode.zPosition = 2
        resetButtonNode.alpha = 0
        addChild(resetButtonNode!)

        /* Game over label node */
        gameOverLabel = SKLabelNode(fontNamed:"TamilSangamMN-Bold")
        gameOverLabel.text = "Game Over";
        gameOverLabel.fontSize = 75;
        gameOverLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Baseline
        gameOverLabel.position = CGPointMake(self.frame.size.width/2 , self.frame.size.height/2)
        gameOverLabel.fontColor = UIColor.whiteColor()
        gameOverLabel.zPosition = 2
        gameOverLabel.alpha = 0
        self.addChild(gameOverLabel)

        
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
    
    func changeScore() {
        scoreNode.changeScore()
    }
    
    func popNextNode() {
        
        nextNode.nextBlock?.setBlockType(nil)
        nextNode.nextBlock?.PopNextBlockAnimation()
    }
    
    func getNextNodeBlockType()->BlockNode.BlockType {
        
        return (nextNode.nextBlock?.type)!
    }
    
    func gameOver() {
        
        let fadeInAction = SKAction.fadeInWithDuration(0.3)
        gameOverNode.runAction(SKAction.moveByX(0, y: -self.frame.size.height, duration: 0.7)) { () -> Void in
            
            self.resetButtonNode.runAction(fadeInAction)
            self.gameOverLabel.runAction(fadeInAction)
        }
    }
    
    func gameRestart() {
        
        let fadeOutAction = SKAction.fadeOutWithDuration(0.3)
        self.resetButtonNode.runAction(fadeOutAction)
        self.gameOverLabel.runAction(fadeOutAction)
        gameOverNode.runAction(SKAction.moveByX(0, y: self.frame.size.height, duration: 0.7))
    }
}
