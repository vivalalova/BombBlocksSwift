//
//  BoardNode.swift
//  BombBlocksSwift
//
//  Created by JackYeh on 2016/2/22.
//  Copyright © 2016年 MarriageKiller. All rights reserved.
//

//import Foundation
import SpriteKit

protocol BoardDelegate {
    func changeScore(addScore:Double)
    func popNextNode()
    func getNextNodeBlockType()->BlockNode.BlockType
    func gameOver()
    func gameRestart()
}

enum BlockCancelType {
    case Col , Row
}

class BoardNode:SKShapeNode {
    
    // MARK:Variables
    var matrix  = 4
    var blockGap = 5
    var cellSize  = 0
    var containerSize = 16
    var blockSize : Int
    var moveGap : Int
    var boardSize: CGFloat
    var blockNodeContainer = [BlockNode?](count: 16, repeatedValue: nil)
    var blockNodeCoordinates = [CGRect]()
    var delegate: BoardDelegate?
    var swipeDirection : UISwipeGestureRecognizerDirection
    var movableDistance : CGFloat = 0
    
    // MARK:INIT
    init(posX:CGFloat , posY:CGFloat) {
        let sizeModifer = 8;
        cellSize = Int(UIScreen.mainScreen().bounds.width * CGFloat(0.25))
        self.blockSize = cellSize - sizeModifer
        self.moveGap = blockGap + sizeModifer/2
        self.boardSize = CGFloat(matrix * 2 * blockGap + cellSize * matrix)
        self.swipeDirection = UISwipeGestureRecognizerDirection.Down
        super.init()
        self.drawBoard(posX, posY: posY)
        self.createBlockCoordinates()
        self.userInteractionEnabled = true
        movableDistance = CGFloat(blockSize + moveGap * 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func moveBlocks() {
        
        let moveDuration = 0.1
        let count = blockNodeContainer.count - 1;
        var isMoved = false
        
        switch swipeDirection {
        case UISwipeGestureRecognizerDirection.Right:
            for var nodeIndex :Int = count ; nodeIndex >= 0  ; nodeIndex-- {
                if (nodeIndex % 4 != 3) {
                        if moveBlockNode(withAction: SKAction.moveByX(movableDistance,y:0,duration: moveDuration), fromCurrent: nodeIndex , toNeighbour: nodeIndex + 1) {
                            isMoved = true
                        }
                }
            }
            break
        case UISwipeGestureRecognizerDirection.Down:
            for var nodeIndex :Int = count ; nodeIndex >= 0  ; nodeIndex-- {
                if (nodeIndex  < 12) {
                        if moveBlockNode(withAction: SKAction.moveByX(0,y:movableDistance * -1, duration: moveDuration), fromCurrent: nodeIndex , toNeighbour: nodeIndex + 4) {
                            isMoved = true
                        }
                }
            }
            break
        case UISwipeGestureRecognizerDirection.Left:
            for var nodeIndex :Int = 0 ; nodeIndex <= count ; nodeIndex++ {
                if (nodeIndex % 4 != 0) {
                    
                        if moveBlockNode(withAction: SKAction.moveByX(movableDistance * -1, y:0, duration: moveDuration), fromCurrent: nodeIndex , toNeighbour: nodeIndex - 1) {
                            isMoved = true
                        }
                }
            }
            break
        case UISwipeGestureRecognizerDirection.Up:
            for var nodeIndex :Int = 0 ; nodeIndex <= count ; nodeIndex++ {
                if (nodeIndex > 3) {
                        if moveBlockNode(withAction: SKAction.moveByX(0,y:movableDistance, duration: moveDuration), fromCurrent: nodeIndex , toNeighbour: nodeIndex - 4) {
                            isMoved = true
                        }
                }
            }
            break
        default:
            break
        }
        
        // Pop new block after each swipe
        if (isMoved) {
            let delay = dispatch_time( DISPATCH_TIME_NOW, Int64(Double(moveDuration*2) * Double(NSEC_PER_SEC)) )
            dispatch_after(delay, dispatch_get_main_queue()) {
                self.popBlockNode()
            }
        }
    }

    
    // MARK:FUNCTIONS
    func drawBoard(posX:CGFloat , posY:CGFloat) {
        
        let pathToDraw : CGMutablePathRef = CGPathCreateMutable()
        CGPathAddPath(pathToDraw, nil, UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: boardSize, height: boardSize), cornerRadius: boardSize/10).CGPath)
        
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
        self.strokeColor = UIColor(white: 0.15, alpha: 1)
        self.lineWidth = 26
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
        setupBackgroundNode()
    }
    
    func moveBlockNode(withAction action:SKAction , fromCurrent currentIndex:Int , toNeighbour neighbourIndex:Int)->Bool {
        
        if (blockNodeContainer[neighbourIndex] == nil && blockNodeContainer[currentIndex] != nil) {
            blockNodeContainer[currentIndex]!.runAction(action )
            swap(&blockNodeContainer[currentIndex], &blockNodeContainer[neighbourIndex])
            return true
        } else {
            return false
        }
    }
    
    func tempMoveBlockNode(withAction action:SKAction , fromCurrent currentIndex:Int , toNeighbour neighbourIndex:Int) {
        
        if (blockNodeContainer[neighbourIndex] == nil && blockNodeContainer[currentIndex] != nil) {
            blockNodeContainer[currentIndex]!.runAction(action )
        }
    }
    
    // Mark: Pop block
    func popBlockNode() {
        
        /* Populate available cell to add new block node */
        var emptyNodeIndexContainer = createEmptyNodeIndexContainer()
        
        if (emptyNodeIndexContainer.count != 0) {
        
            /* Create random block node */
            let randomIndex = Int(arc4random_uniform(UInt32(emptyNodeIndexContainer.count)))
            let emptyNodeIndex = emptyNodeIndexContainer[randomIndex]
            let blockNode = BlockNode(rect: blockNodeCoordinates[emptyNodeIndex])
            blockNode.setBlockType(delegate?.getNextNodeBlockType())
        
            /* Add new block to board */
            self.addChild(blockNode);
            blockNodeContainer[emptyNodeIndex] = blockNode
            
            /* Animation when adding child */
            blockNode.PopBlockAnimation({ () -> () in
                
                /* Pop incoming block */
                self.delegate?.popNextNode()
                
                /* Check if any blocks can be removed */
                self.cancelBlock({ () -> () in
                    /* Call game over when board is full */

                    if (self.createEmptyNodeIndexContainer().count == 0) {
                        
                        self.delegate?.gameOver()
                    }

                })
            })
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
    
    // MARK: Block remove procedure
    func cancelBlock(completion:()->()) {
        
        var finalRemoveArray = [[BlockNode]]()
        
        /* Remove Check */
        for index in 0...3 {
            
            // Col Check
            var startIndex = index
            var endIndex = startIndex + 12
            finalRemoveArray.append( executeBlockRemoval(startIndex, endIndex: endIndex , neighbourOffset: 4) )
            
            // Row Check
            startIndex = index * 4
            endIndex = startIndex + 3
            finalRemoveArray.append( executeBlockRemoval(startIndex, endIndex: endIndex , neighbourOffset: 1) )
            
        }
        
        /* Apply expand animation to new cancel blocks */
        for removeBlocks in finalRemoveArray {
            
            /* Add new cancel blocks to board */
            var newCancelBlocksArray = [BlockNode]()
            
            for blockNode in removeBlocks {
                
                let newCancelBlockNode = BlockNode(rect: blockNodeCoordinates[ blockIndex(blockNode)! ])
                newCancelBlockNode.setBlockType(blockNode.type)
                newCancelBlockNode.hidden = false
                addChild(newCancelBlockNode)
                newCancelBlocksArray.append(newCancelBlockNode)
                blockNode.removeFromParent()
            }

            let blocksCount = newCancelBlocksArray.count
            
            if (blocksCount == 3) {
                
                var expandType = BlockNode.ExpandType.Horizontal
                let expandTypeCheck = blockIndex(removeBlocks[0])! - blockIndex(removeBlocks[1])!
                
                if ( expandTypeCheck > 3) {
                    expandType = BlockNode.ExpandType.Vertical
                }
                
                newCancelBlocksArray[1].expandBlockAnimation({ () -> () in
                    
                    /* Perform explode animation */
                    self.cancelBlockAnimation(newCancelBlocksArray , explodeColor: removeBlocks[0].fillColor)
                    
                    self.removeBlocksFromBoard(newCancelBlocksArray)
                    
                    self.updateScore(15)

                    }, expandType: expandType)
                
            } else if (blocksCount == 4) {
                
                var expandType = BlockNode.ExpandType.Horizontal
                
                let expandTypeCheck = blockIndex(removeBlocks[0])! - blockIndex(removeBlocks[1])!
                
                if ( expandTypeCheck > 3) {
                
                    expandType = BlockNode.ExpandType.Vertical
                }

                newCancelBlocksArray[1].expandBlockAnimation({} , expandType: expandType)
                newCancelBlocksArray[2].expandBlockAnimation({ ()->() in
                    
                    /* Perform explode animation */
                    self.cancelBlockAnimation(newCancelBlocksArray , explodeColor: removeBlocks[0].fillColor)
                    
                    self.removeBlocksFromBoard(newCancelBlocksArray)
                    
                    self.updateScore(25)
                    
                    }, expandType: expandType)
            }
        }
        
        /* Remove orignal cancel blocks from container*/
        self.removeOriginalCancelBlocksFromContainer(finalRemoveArray)
        
        completion()
    }
    
    func removeOriginalCancelBlocksFromContainer(finalRemoveArray:[[BlockNode]]) {
        
        /* Get original unique blocks to be removed */
        var uniqueRemoveBlocks = [BlockNode]()
        
        for removeBlocks in finalRemoveArray {
            uniqueRemoveBlocks += removeBlocks
        }
        
        uniqueRemoveBlocks = Array(Set(uniqueRemoveBlocks))

        /* Remove original cancelBlocks from container */
        for blockNode in uniqueRemoveBlocks {
            
            if let removeIndex = blockIndex(blockNode) {
                blockNodeContainer[removeIndex] = nil
            }
        }
    }
    
    func executeBlockRemoval(startIndex:Int , endIndex:Int , neighbourOffset:Int)->[BlockNode] {
        
        let cancelBlocks = blockCancelCheck(startIndex, endIndex: endIndex, neighbourOffset: neighbourOffset)
        let confirmedBlocksToCancel = blockTypeCheck(cancelBlocks)
        let confirmedBlocksToCancelCount = confirmedBlocksToCancel.count
        
        if (confirmedBlocksToCancelCount >= 3) {
            return confirmedBlocksToCancel
        } else {
            return []
        }
    }
    
    func blockCancelCheck(startIndex:Int , endIndex:Int , neighbourOffset:Int)->[BlockNode] {
        
        let neighbourIndex = startIndex + neighbourOffset
        if (startIndex == endIndex) {
            if let blockNode = blockNodeContainer[startIndex] {
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
    
    func blockTypeCheck(cancelBlocks:[BlockNode])->[BlockNode] {
        
        if cancelBlocks.count > 2 {
            
            var frequency: [BlockNode.BlockType:Int] = [:]
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
    
    func cancelBlockAnimation(blocksToCancel:[BlockNode] , explodeColor:UIColor) {
        
        for blockNode in blocksToCancel {
                
            let position = blockNode.frame.origin
            
            if let particles = SKEmitterNode(fileNamed: "ExplodeParticle.sks") {
                particles.position = CGPointMake(position.x + CGFloat(blockSize/2) , position.y + CGFloat(blockSize/2))
                particles.particleColor = explodeColor
                particles.particleColorBlendFactor = 1.0;
                particles.particleColorSequence = nil;
                self.addChild(particles)
            }
        }
    }
    
    func removeBlocksFromBoard(cancelBlocks:[BlockNode]) {
        
        for blockNode in cancelBlocks {
            blockNode.removeFromParent()
        }
    }
    
    func updateScore(addScore:Double) {
        delegate?.changeScore(addScore)
    }
    
    func setupBackgroundNode() {
        for nodeCoordinate in blockNodeCoordinates {
            let backgroupdBlock = BlockNode(rect: nodeCoordinate)
            backgroupdBlock.setBlockType(BlockNode.BlockType.Background)
            backgroupdBlock.hidden = false
            self.addChild(backgroupdBlock)
        }
    }
    
    // Mark: Reset
    func resetBoard() {
        
        delegate?.gameRestart()
        self.removeAllChildren()
        blockNodeContainer = [BlockNode?](count: 16, repeatedValue: nil)
        setupBackgroundNode()
        popBlockNode()
    }
    
    func blockIndex(blockNode:BlockNode)->Int? {
        
        if let index = blockNodeContainer.indexOf( {$0 == blockNode}) {
            return index
        } else {
            return nil
        }
    }
    
}