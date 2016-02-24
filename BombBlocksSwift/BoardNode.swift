//
//  BoardNode.swift
//  BombBlocksSwift
//
//  Created by JackYeh on 2016/2/22.
//  Copyright © 2016年 MarriageKiller. All rights reserved.
//

//import Foundation
import SpriteKit

protocol ScoreDelegate {
    func changeScore()
}

class BoardNode:SKShapeNode {
    
    // MARK:Variables
    var matrix  = 4
    var blockGap = 5
    var cellSize  = 90
    var containerSize = 16
    var blockSize : Int
    var moveGap : Int
    var boardSize: CGFloat
    var blockNodeContainer = [BlockNode?](count: 16, repeatedValue: nil)
    var blockNodeCoordinates = [CGRect]()
    var delegate: ScoreDelegate?
    
    // MARK:INIT
    init(posX:CGFloat , posY:CGFloat) {
        let sizeModifer = 26;
        self.blockSize = cellSize - sizeModifer
        self.moveGap = blockGap + sizeModifer/2
        self.boardSize = CGFloat(matrix * 2 * blockGap + cellSize * matrix)
        super.init()
        self.drawBoard(posX, posY: posY)
        self.createBlockCoordinates()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:FUNCTIONS
    func drawBoard(posX:CGFloat , posY:CGFloat) {
        
        let pathToDraw : CGMutablePathRef = CGPathCreateMutable()
        CGPathAddPath(pathToDraw, nil, UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: boardSize, height: boardSize), cornerRadius: 0).CGPath)
        
        // Draw path for board inner outline
        let startY = matrix*cellSize+blockGap*(matrix*2);
        let startX = matrix*cellSize+blockGap*(matrix*2);
        
        for nodeIndex in 1...3 {
            let pointX = nodeIndex*(cellSize+blockGap*2);
            let pointY = nodeIndex*(cellSize+blockGap*2);
            
            CGPathMoveToPoint(pathToDraw, nil, CGFloat(pointX), 0)
            CGPathAddLineToPoint (pathToDraw, nil, CGFloat(pointX), CGFloat(startY) )
            
            CGPathMoveToPoint(pathToDraw, nil, 0, CGFloat(pointY))
            CGPathAddLineToPoint (pathToDraw, nil, CGFloat(startX), CGFloat(pointY) )
        }

        self.path = pathToDraw
        self.position = CGPointMake( (posX - boardSize)/2, (posY - boardSize)/2 )
        self.strokeColor = UIColor.whiteColor()
        self.lineWidth = 2
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
                coordinateY = blockSize*(4 - rowChangeModifer) + gapModifier*moveGap
                columnChangeModifer += matrix
                rowChangeModifer++
            }
            
            // Column Change
            if (blockNodeIndex <= columnChangeModifer) {
                gapModifier = blockNodeIndex%4
                if (gapModifier == 0) {
                    gapModifier = matrix;
                }
                coordinateX = blockSize*(gapModifier-1) + moveGap*(gapModifier*2 - 1)
            }
            
            // Create coordinates for each block
            if let x = coordinateX , y = coordinateY {
                let blockNodeRect = CGRectMake(CGFloat(x),CGFloat(y),  CGFloat(blockSize), CGFloat(blockSize))
                blockNodeCoordinates.append(blockNodeRect)
            }
        }
    }
    
    func moveBlockNode(withAction action:SKAction , fromCurrent currentIndex:Int , toNeighbour neighbourIndex:Int) {
        
        if (blockNodeContainer[neighbourIndex] == nil && blockNodeContainer[currentIndex] != nil) {
            blockNodeContainer[currentIndex]!.runAction(action )
            swap(&blockNodeContainer[currentIndex], &blockNodeContainer[neighbourIndex])
        }
    }
    
    func popBlockNode() {
        
        /* Remove Check */
        removeBlockFromBoard()
        
        // Populate available cell to add new block node
        var emptyNodeIndexContainer = createEmptyNodeIndexContainer()
        
        if (emptyNodeIndexContainer.count != 0) {
        
            /* Create random block node */
            
            // Get random index which has empty block node on board
            let randomIndex = Int(arc4random_uniform(UInt32(emptyNodeIndexContainer.count)))
            let emptyNodeIndex = emptyNodeIndexContainer[randomIndex]
            
            let chooseNode = Int(arc4random_uniform(UInt32(4)))
            var blockNode : BlockNode?
            
            switch chooseNode {
            case 0 :
                blockNode = BlockNode(rect: blockNodeCoordinates[emptyNodeIndex],color: UIColor.blueColor())
                break
            case 1:
                blockNode = BlockNode(rect: blockNodeCoordinates[emptyNodeIndex],color: UIColor.redColor())
                break
            case 2:
                blockNode = BlockNode(rect: blockNodeCoordinates[emptyNodeIndex],color: UIColor.yellowColor())
                break
            case 3:
                blockNode = BlockNode(rect: blockNodeCoordinates[emptyNodeIndex],color: UIColor.greenColor())
                break
            default :
                break
            }
            
            /* Add new block to board */
            self.addChild(blockNode!);
            blockNodeContainer[emptyNodeIndex] = blockNode
            
            /* Animation when adding child */
            if (emptyNodeIndexContainer.count != 1) {
                blockNode?.PopBlockAnimation(nil)
                
            } else {
                
                /* Completion block to check if game is over when board is full of block nodes */
                blockNode?.PopBlockAnimation({ () -> Void in
                    removeBlockFromBoard()
                    if (createEmptyNodeIndexContainer().count == 0) {
                        // TODO: Game Over!
                        //resetBoard()
                    }
                    
                }())
            }
        }
    }
    
    func createEmptyNodeIndexContainer()->[Int] {
        var emptyNodeIndexContainer = [Int]()
        for var nodeIndex :Int = 0 ; nodeIndex < blockNodeContainer.count ; nodeIndex++ {
            let blockNode = blockNodeContainer[nodeIndex];
            if (blockNode == nil) {
                emptyNodeIndexContainer.append(nodeIndex)
            }
        }
        return emptyNodeIndexContainer
    }
    
    func blockTypeCheck(cancelBlocks:[BlockNode])->[BlockNode] {
        
        if cancelBlocks.count > 2 {
            
            var frequency: [BlockNode.blockType:Int] = [:]
            for frequencyNode in cancelBlocks {
                // set frequency based on block type occurrence
                frequency[frequencyNode.type!] = (frequency[frequencyNode.type!] ?? 0) + 1
                
                if (frequency[frequencyNode.type!] == 3) {
                    
                    // Check if blocks are consecutive
                    if (cancelBlocks[2].type != frequencyNode.type! || cancelBlocks[1].type != frequencyNode.type!) {
                        return []
                    }
                    
                    // Filter out blocks to be cancelled
                    return cancelBlocks.filter { (node) -> Bool in
                        node.type == frequencyNode.type!
                    }
                }
            }
            return []
        }
        return []
    }
    
    func blockCancelCheck(startIndex:Int , endIndex:Int , neighbourOffset:Int)->[BlockNode] {
    
        let neighbourIndex = startIndex + neighbourOffset
        if (startIndex == endIndex) {
            if  let blockNode = blockNodeContainer[startIndex] {
                return [blockNode]
            }
            return []
        } else {
            
            let neighbourBlockNodeArray =  blockCancelCheck(neighbourIndex,endIndex: endIndex,neighbourOffset: neighbourOffset)
            
            if let blockNode = blockNodeContainer[startIndex] {
                var _neighbourBlockNodeArray = neighbourBlockNodeArray
                _neighbourBlockNodeArray.append(blockNode)
                return _neighbourBlockNodeArray
                
            } else if neighbourBlockNodeArray.count > 2 {
                return neighbourBlockNodeArray
            }
            return []
        }
    }
    
    func removeBlockFromBoard() {
        
        /* Remove Check */
        var removeBlocks = [BlockNode]()
        for index in 0...3 {
            
            // Col Check
            var startIndex = index
            var endIndex = startIndex + 12
            var cancelBlocks = blockCancelCheck(startIndex, endIndex: endIndex, neighbourOffset: 4)
            removeBlocks += blockTypeCheck(cancelBlocks)
            
            // Row Check
            startIndex = index * 4
            endIndex = startIndex + 3
            cancelBlocks = blockCancelCheck(startIndex, endIndex: endIndex, neighbourOffset: 1)
            removeBlocks += blockTypeCheck(cancelBlocks)
        }
        
        let removeUniqueBlocks = Array(Set(removeBlocks))
        
        if (removeUniqueBlocks.count > 2) {
            for blockNode in removeUniqueBlocks {
                let removeIndex = blockNodeContainer.indexOf( {$0 == blockNode})
                blockNode.removeFromParent()
                blockNodeContainer[removeIndex!] = nil
            }
            delegate?.changeScore()
        }
    }
    
    func resetBoard() {
        
        self.removeAllChildren()
        blockNodeContainer = [BlockNode?](count: 16, repeatedValue: nil)
        popBlockNode()
    }
}