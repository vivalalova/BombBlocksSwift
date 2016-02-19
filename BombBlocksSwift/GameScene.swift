//
//  GameScene.swift
//  BombBlocksSwift
//
//  Created by JackYeh on 2016/2/18.
//  Copyright (c) 2016年 MarriageKiller. All rights reserved.
//

import SpriteKit
import Foundation

let matrix = 4
let containerSize = matrix * matrix
let blockGap = 5
let blockSize = 90
let boardSize: CGFloat = CGFloat(matrix * 2 * blockGap + blockSize * matrix)
var blockNodeContainer = [SKShapeNode?](count: containerSize, repeatedValue: nil)
var blockNodeCoordinates = [CGRect]()

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let screenWidth : CGFloat = CGRectGetWidth(self.frame)
        let screenHeight: CGFloat = CGRectGetHeight(self.frame)
        
        /* Create board layout */
        let boardNode = SKShapeNode()
        
        // Draw path for board outline
        let pathToDraw : CGMutablePathRef = CGPathCreateMutable()
        CGPathAddPath(pathToDraw, nil, UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: boardSize, height: boardSize), cornerRadius: CGFloat(blockSize/6)).CGPath)
        
        // Draw path for board inner outline
        let startY = matrix*blockSize+blockGap*(matrix*2);
        let startX = matrix*blockSize+blockGap*(matrix*2);
        
        for nodeIndex in 1...3 {
            let pointX = nodeIndex*(blockSize+blockGap*2);
            let pointY = nodeIndex*(blockSize+blockGap*2);
            
            CGPathMoveToPoint(pathToDraw, nil, CGFloat(pointX), 0)
            CGPathAddLineToPoint (pathToDraw, nil, CGFloat(pointX), CGFloat(startY) )
            
            CGPathMoveToPoint(pathToDraw, nil, 0, CGFloat(pointY))
            CGPathAddLineToPoint (pathToDraw, nil, CGFloat(startX), CGFloat(pointY) )
        }
        
        boardNode.path = pathToDraw
        boardNode.position = CGPointMake( (screenWidth - boardSize)/2, (screenHeight - boardSize)/2 )
        boardNode.strokeColor = UIColor.whiteColor()
        boardNode.lineWidth = 3
        
        // Add board to Scene
        self.addChild(boardNode)
        
        /* Create block node */
        var columnChangeModifer = 0
        var rowChangeModifer = 1
        var coordinateX : Int?
        var coordinateY : Int?
        
        for (blockNodeIndex) in 1...containerSize {
            
            var gapModifier : Int
 
            // Row Change
            if ( blockNodeIndex%4 == 1) {
                gapModifier = 7-(rowChangeModifer - 1)*2
                coordinateY = blockSize*(4 - rowChangeModifer) + gapModifier*blockGap
                columnChangeModifer += matrix
                rowChangeModifer++
            }
            
            // Column Change
            if (blockNodeIndex <= columnChangeModifer) {
                gapModifier = blockNodeIndex%4
                if (gapModifier == 0) {
                    gapModifier = matrix;
                }
                coordinateX = blockSize*(gapModifier-1) + blockGap*(gapModifier*2 - 1)
            }
            
            if let x = coordinateX , y = coordinateY {
                
                let blockNodeRect = CGRectMake(CGFloat(x),CGFloat(y),  CGFloat(blockSize), CGFloat(blockSize))
                blockNodeCoordinates.append(blockNodeRect)
            }
        }
        
        /* Create random block node */
        let randomBlockNodeIndex = Int(arc4random_uniform(15))
        let blockNode = SKShapeNode(rect: blockNodeCoordinates[randomBlockNodeIndex], cornerRadius: CGFloat(blockSize/6))
        blockNode.fillColor = UIColor.grayColor()
        blockNode.strokeColor = UIColor.grayColor()
        
        // Add block to board
        boardNode.addChild(blockNode);
        blockNodeContainer.insert(blockNode, atIndex: randomBlockNodeIndex)

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
        
//        for touch in touches {
//            let location = touch.locationInNode(self)
//            
//            let sprite = SKSpriteNode(imageNamed:"Spaceship")
//            
//            sprite.xScale = 0.5
//            sprite.yScale = 0.5
//            sprite.position = location
//            
//            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
//            
//            sprite.runAction(SKAction.repeatActionForever(action))
//            
//            self.addChild(sprite)
//        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            for (blockNode) in blockNodeContainer {
                
                if let block = blockNode {
                    let currentIndex = blockNodeContainer.indexOf {$0 == block}
                    var action : SKAction
                    let moveDuration = 0.2
                    let swapToIndex :Int?
                    
                    switch swipeGesture.direction {
                    case UISwipeGestureRecognizerDirection.Right:
                        if (currentIndex! % 4 < 3) {
                            action = SKAction.moveByX(CGFloat(blockSize + blockGap * 2), y: 0, duration: moveDuration)
                            block.runAction(action)
                            swapToIndex = currentIndex! + 1
                            swap(&blockNodeContainer[currentIndex!], &blockNodeContainer[swapToIndex!])
                        }
                    case UISwipeGestureRecognizerDirection.Down:
                        if (currentIndex < 12) {
                            action = SKAction.moveByX(0, y: CGFloat((blockSize + blockGap * 2) * -1), duration: moveDuration)
                            block.runAction(action)
                            swapToIndex = currentIndex! + 4
                            swap(&blockNodeContainer[currentIndex!], &blockNodeContainer[swapToIndex!])
                        }
                    case UISwipeGestureRecognizerDirection.Left:
                        if (currentIndex! % 4 > 0) {
                            action = SKAction.moveByX(CGFloat((blockSize + blockGap * 2) * -1), y: 0, duration: moveDuration)
                            block.runAction(action)
                            swapToIndex = currentIndex! - 1
                            swap(&blockNodeContainer[currentIndex!], &blockNodeContainer[swapToIndex!])
                        }
                    case UISwipeGestureRecognizerDirection.Up:
                        if (currentIndex > 3) {
                            action = SKAction.moveByX(0, y: CGFloat(blockSize + blockGap * 2), duration: moveDuration)
                            block.runAction(action)
                            swapToIndex = currentIndex! - 4
                            swap(&blockNodeContainer[currentIndex!], &blockNodeContainer[swapToIndex!])
                        }
                    default:
                        break
                    }

                }
                
            }
        }
    }

}
