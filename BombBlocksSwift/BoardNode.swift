//
//  BoardNode.swift
//  BombBlocksSwift
//
//  Created by JackYeh on 2016/2/22.
//  Copyright © 2016年 MarriageKiller. All rights reserved.
//

import Foundation
import SpriteKit

class BoardNode:SKShapeNode {
    
    var matrix :Int
    var blockGap : Int
    var blockSize : Int
    var boardSize: CGFloat
    var containerSize :Int = 16
    var blockNodeContainer = [SKShapeNode?](count: 16, repeatedValue: nil)
    var blockNodeCoordinates = [CGRect]()
    
    override init() {
        self.matrix = 4;
        self.blockSize = 90
        self.blockGap = 5
        self.boardSize = CGFloat(matrix * 2 * blockGap + blockSize * matrix)
        super.init()
    }
    
    func drawBoard(posX:CGFloat , posY:CGFloat) {
        
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

        self.path = pathToDraw
        self.position = CGPointMake( (posX - boardSize)/2, (posY - boardSize)/2 )
        self.strokeColor = UIColor.whiteColor()
        self.lineWidth = 3
        
    }
    
    func createBlockCoordinates() {
        
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
            
            // Create coordinates for each block
            if let x = coordinateX , y = coordinateY {
                let blockNodeRect = CGRectMake(CGFloat(x),CGFloat(y),  CGFloat(blockSize), CGFloat(blockSize))
                blockNodeCoordinates.append(blockNodeRect)
            }
        }
    }
    
    func popBlockNode() {
        
        var emptyNodeIndexContainer = [Int]()
        for var nodeIndex :Int = 0 ; nodeIndex < blockNodeContainer.count ; nodeIndex++ {
            let blockNode = blockNodeContainer[nodeIndex];
            if (blockNode == nil) {
                emptyNodeIndexContainer.append(nodeIndex)
            }
        }
        
        if (emptyNodeIndexContainer.count == 0) {
            print("Game Over")
        } else {
            /* Create random block node */
            // Get random index which has empty block node on board
            let randomIndex = Int(arc4random_uniform(UInt32(emptyNodeIndexContainer.count)))
            let emptyNodeIndex = emptyNodeIndexContainer[randomIndex]
            let blockNode = BlockNode(rect: blockNodeCoordinates[emptyNodeIndex], cornerRadius: CGFloat(blockSize/6))
            
            // Add new block to board
            self.addChild(blockNode);
            blockNodeContainer[emptyNodeIndex] = blockNode
        }
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}