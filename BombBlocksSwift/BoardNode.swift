//
//  BoardNode.swift
//  BombBlocksSwift
//
//  Created by JackYeh on 2016/2/22.
//  Copyright © 2016年 MarriageKiller. All rights reserved.
//

//import Foundation
import SpriteKit

// MARK: BoardDelegate
protocol BoardDelegate {
    func changeScore(addScore:Double)
    func popNextNode()
    func getNextNodeBlockType()->Block.BlockType
    func gameOver()
    func gameRestart(completion:()->())
    func setUserInteraction(allowInteraction:Bool)
}

enum BlockCancelType {
    case Col , Row
}

// MARK: Class
class BoardNode:SKShapeNode {
    
    // MARK:Variables
    var matrix  = 4
    var blockGap = 5
    var cellSize = 0
    var containerSize = 16
    var blockSize : Int
    var moveGap : Int
    var boardSize: CGFloat
    var blockNodeContainer = [Block?](count: 16, repeatedValue: nil)
    var blockNodeCoordinates = [CGRect]()
    var delegate: BoardDelegate?
    var swipeDirection : UISwipeGestureRecognizerDirection
    var movableDistance : CGFloat = 0
    
    // MARK: Initialization
    init(posX:CGFloat , posY:CGFloat) {

        let sizeModifer = 8;
        cellSize = Int(UIScreen.mainScreen().bounds.width * CGFloat(0.25))
        blockSize = cellSize - sizeModifer
        moveGap = blockGap + sizeModifer/2
        boardSize = CGFloat(matrix * 2 * blockGap + cellSize * matrix)
        swipeDirection = UISwipeGestureRecognizerDirection.Down
        movableDistance = CGFloat(blockSize + moveGap * 2)
        super.init()
        drawBoard(posX, posY: posY)
        createBlockCoordinates()
        userInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawBoard(posX:CGFloat , posY:CGFloat) {
        
        let pathToDraw : CGMutablePathRef = CGPathCreateMutable()
        CGPathAddPath(pathToDraw, nil, UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: boardSize, height: boardSize), cornerRadius: boardSize/10).CGPath)
        self.path = pathToDraw
        self.strokeColor = UIColor(white: 0.15, alpha: 1)
        self.fillColor = UIColor(white: 0.15, alpha: 1)
        self.lineWidth = 26 * UIScreen.mainScreen().bounds.width/320
        self.position = CGPointMake((posX - boardSize)/2, (posY - boardSize)/2)
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
            if ( blockNodeIndex % matrix == 1) {
                gapModifier = 7 - (rowChangeModifer - 1) * 2
                coordinateY = blockSize * (matrix - rowChangeModifer) + gapModifier * moveGap
                columnChangeModifer += matrix
                rowChangeModifer++
            }
            
            // Column Change
            if (blockNodeIndex <= columnChangeModifer) {
                gapModifier = blockNodeIndex % matrix
                if (gapModifier == 0) {
                    gapModifier = matrix;
                }
                coordinateX = blockSize * (gapModifier - 1) + moveGap * (gapModifier * 2 - 1)
            }
            
            // Create coordinates for each block
            if let x = coordinateX , y = coordinateY {
                let blockNodeRect = CGRectMake(CGFloat(x),CGFloat(y),  CGFloat(blockSize), CGFloat(blockSize))
                blockNodeCoordinates.append(blockNodeRect)
            }
        }
        setupBackgroundNode()
    }
    
    func setupBackgroundNode() {
        for nodeCoordinate in blockNodeCoordinates {
            let backgroundBlock = Block(emptyBlockRect: nodeCoordinate)
            self.addChild(backgroundBlock)
        }
    }

    func createEmptyNodeIndexContainer()->[Int] {
        var emptyNodeIndexContainer = [Int]()
        
        var startIndex = 0
        var endIndex = 15
        var multiplier = 1
        
        switch swipeDirection {
        case UISwipeGestureRecognizerDirection.Up :
            startIndex = 12
            break
        case UISwipeGestureRecognizerDirection.Down :
            endIndex = 3
            break
        case UISwipeGestureRecognizerDirection.Left :
            startIndex = 3
            multiplier = 4
            break
        case UISwipeGestureRecognizerDirection.Right :
            endIndex = 12
            multiplier = 4
            break
        default:
            break
        }
        
        while (startIndex <= endIndex) {
            
            let blockNode = blockNodeContainer[startIndex];
            if (blockNode == nil) {
                emptyNodeIndexContainer.append(startIndex)
            }
            startIndex += multiplier
        }
        return emptyNodeIndexContainer
    }
    
    // MARK: Block movements
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
                    if moveBlockNode(withAction: SKAction.moveByX(0,y:movableDistance * -1, duration: moveDuration), fromCurrent: nodeIndex , toNeighbour: nodeIndex + matrix) {
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
                    if moveBlockNode(withAction: SKAction.moveByX(0,y:movableDistance, duration: moveDuration), fromCurrent: nodeIndex , toNeighbour: nodeIndex - matrix) {
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
    
    func moveBlockNode(withAction action:SKAction , fromCurrent currentIndex:Int , toNeighbour neighbourIndex:Int)->Bool {
        
        if (blockNodeContainer[neighbourIndex] == nil && blockNodeContainer[currentIndex] != nil) {
            blockNodeContainer[currentIndex]!.runAction(action )
            swap(&blockNodeContainer[currentIndex], &blockNodeContainer[neighbourIndex])
            return true
        } else {
            return false
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
            let blockNode = Block(gameBlockRect: blockNodeCoordinates[emptyNodeIndex], newBlockType: (delegate?.getNextNodeBlockType())!)
        
            /* Add new block to board */
            self.addChild(blockNode);
            
            blockNodeContainer[emptyNodeIndex] = blockNode
            
            /* Animation when adding child */
            blockNode.PopBlockAnimation({ () -> () in
                
                /* Pop incoming block */
                self.delegate?.popNextNode()
                
                /* Check if any blocks can be removed */
                self.delegate?.setUserInteraction(false)

                self.cancelBlock({ () -> () in
                    
                    self.delegate?.setUserInteraction(true)

                    /* Call game over when board is full */
                    var index = self.containerSize
                    for block in self.blockNodeContainer {
                        if (block != nil) {
                            index--
                        }
                    }
                    if ( index == 0) {
                        self.delegate?.gameOver()
                    }
                })
            })
        }
    }
    
    // MARK: Block remove procedure
    func cancelBlock(completion:()->()) {
        
        var finalRemoveArray = [[Block]]()
        
        /* Remove Check */
        for index in 0...3 {
            
            /* Col remove check */
            var startIndex = index
            var endIndex = startIndex + 12
            let colCancelArray = executeBlockRemoval(startIndex, endIndex: endIndex , neighbourOffset: 4)
            if (colCancelArray.count > 0) {
                finalRemoveArray.append(colCancelArray)
            }
            
            /* Row remove Check */
            startIndex = index * 4
            endIndex = startIndex + 3
            let rowCancelArray = executeBlockRemoval(startIndex, endIndex: endIndex , neighbourOffset: 1)
            if (rowCancelArray.count > 0) {
                finalRemoveArray.append(rowCancelArray)
            }
        }
        
        /* Square remove check */
        for index in 0...10 {
            if (index != 3 && index != 7) {
                let squareCancelArray = executeBlockRemovalSquare(index)
                if (squareCancelArray.count > 0) {
                    finalRemoveArray.append(squareCancelArray)
                }
            }
        }
        
        if finalRemoveArray.count == 0 {
            
            completion()
            
        } else {
            
            /* Apply expand animation to new cancel blocks */
            for removeBlocks in finalRemoveArray {
                
                let finalIndex = finalRemoveArray.indexOf( {$0 == removeBlocks})
                
                /* Add new cancel blocks to board */
                var newCancelBlocksArray = [Block]()
                
                for blockNode in removeBlocks {
                    
                    let newCancelBlockNode = Block(gameBlockRect: blockNodeCoordinates[ blockIndex(blockNode)! ], newBlockType: blockNode.type)
                    addChild(newCancelBlockNode)
                    newCancelBlocksArray.append(newCancelBlockNode)
                    blockNode.removeFromParent()
                }
                
                let blocksCount = newCancelBlocksArray.count
                
                if (blocksCount > 2) {
                
                    var score : Double = 15
                    var expandType = Block.ExpandType.Horizontal
                    
                    if (blocksCount == 4 && blockIndex(removeBlocks[3])! - blockIndex(removeBlocks[0])! == 5 ) {
                        
                        score = 30
                        
                        for index in 0...3 {
                            
                            let animationDirection = Block.AnimationDirection(rawValue: index)
                            
                            newCancelBlocksArray[index].squareBlockAnimation({ () -> () in
                                
                                self.cancelBlockAnimation([newCancelBlocksArray[index]] , explodeColor: removeBlocks[index].color)
                                self.removeBlocksFromBoard([newCancelBlocksArray[index]])
                                
                                if finalIndex == finalRemoveArray.count - 1 {
                                    
                                    /* Execute completion closure after blocks are removed */
                                    completion()
                                }

                                }, direction: animationDirection!)
                        }
                        
                    } else {
                        
                        let expandTypeCheck = blockIndex(removeBlocks[0])! - blockIndex(removeBlocks[1])!
                        
                        if (expandTypeCheck > 3) {
                            expandType = Block.ExpandType.Vertical
                        }
                        
                        if (blocksCount == 4) {
                            score = 50
                            newCancelBlocksArray[1].expandBlockAnimation({} , expandType: expandType)
                        }
                        
                        newCancelBlocksArray[blocksCount - 2].expandBlockAnimation({ ()->() in
                            
                            /* Perform explode animation */
                            self.cancelBlockAnimation([ newCancelBlocksArray[0],newCancelBlocksArray[blocksCount - 1] ] , explodeColor: removeBlocks[0].color)
                            
                            self.removeBlocksFromBoard(newCancelBlocksArray)
                            
                            self.updateScore(score)
                            
                            if finalIndex == finalRemoveArray.count - 1 {
                                
                                /* Execute completion closure after blocks are removed */
                                completion()
                            }
                        
                            }, expandType: expandType)
                    }
                } 
            }
            /* Remove orignal cancel blocks from container*/
            self.removeOriginalCancelBlocksFromContainer(finalRemoveArray)
        }
    }
    
    func removeOriginalCancelBlocksFromContainer(finalRemoveArray:[[Block]]) {
        
        /* Get original unique blocks to be removed */
        var uniqueRemoveBlocks = [Block]()
        
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
    
    func executeBlockRemoval(startIndex:Int , endIndex:Int , neighbourOffset:Int)->[Block] {
        
        let cancelBlocks = blockCancelCheck(startIndex, endIndex: endIndex, neighbourOffset: neighbourOffset)
        let confirmedBlocksToCancel = blockTypeCheck(cancelBlocks)
        let confirmedBlocksToCancelCount = confirmedBlocksToCancel.count
        
        if (confirmedBlocksToCancelCount >= 3) {
            return confirmedBlocksToCancel
        } else {
            return []
        }
    }
    
    func executeBlockRemovalSquare(startIndex:Int)->[Block] {
        
        if let blockNode = blockNodeContainer[startIndex] {
            if let rightBlockNode = blockTypeCheck(startIndex + 1,blockType: blockNode.type) {
                if let bottomBlockNode = blockTypeCheck(startIndex + 4,blockType: blockNode.type) {
                    if let bottomRightBlockNode = blockTypeCheck(startIndex + 5,blockType: blockNode.type) {
                        
                        return [blockNode,rightBlockNode,bottomBlockNode,bottomRightBlockNode]

                    }
                    return []
                }
                return []
            }
            return []
        }
        return []
    }
    
    func blockTypeCheck(startIndex:Int , blockType:Block.BlockType)->Block? {
        
        if let blockNode = blockNodeContainer[startIndex] {
            
            if blockNode.type == blockType {
                return blockNode
            }
            return nil
        }
        return nil
    }
    
    func blockCancelCheck(startIndex:Int , endIndex:Int , neighbourOffset:Int)->[Block] {
        
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
    
    func blockTypeCheck(cancelBlocks:[Block])->[Block] {
        if cancelBlocks.count > 2 {
            var frequency: [Block.BlockType:Int] = [:]
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
    
    func cancelBlockAnimation(blocksToCancel:[Block] , explodeColor:UIColor) {
        for blockNode in blocksToCancel {
            let position = blockNode.frame.origin
            if let particles = SKEmitterNode(fileNamed: "ExplodeParticle.sks") {
                particles.position = CGPointMake(position.x + CGFloat(blockSize/2) , position.y + CGFloat(blockSize/2))
                particles.particleColor = explodeColor
                particles.particleColorBlendFactor = 1.0;
                particles.particleColorSequence = nil;
                particles.zPosition = 3
                
                self.addChild(particles)
            }
        }
    }
    
    func removeBlocksFromBoard(cancelBlocks:[Block]) {
        for blockNode in cancelBlocks {
            blockNode.removeFromParent()
        }
    }
    
    func blockIndex(blockNode:Block)->Int? {
        if let index = blockNodeContainer.indexOf( {$0 == blockNode}) {
            return index
        } else {
            return nil
        }
    }
    
    // MARK: Delegation
    func resetBoard() {
        self.removeAllChildren()
        self.blockNodeContainer = [Block?](count: 16, repeatedValue: nil)
        self.setupBackgroundNode()
        delegate?.gameRestart({ () -> () in
            self.popBlockNode()
        })
    }
    
    func updateScore(addScore:Double) {
        delegate?.changeScore(addScore)
    }

}