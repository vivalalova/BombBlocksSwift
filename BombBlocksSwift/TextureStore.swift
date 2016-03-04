//
//  TextureContainer.swift
//  BombBlocksSwift
//
//  Created by JackYeh on 2016/3/4.
//  Copyright © 2016年 MarriageKiller. All rights reserved.
//

import Foundation
import SpriteKit

class TextureStore {
    
    static let  sharedInstance = TextureStore()
    
    var blockTextures = [SKTexture]()
    var bombTextures = [SKTexture]()

    var blockColor = [
        UIColor(red: 99/255, green: 173/255, blue: 244/255, alpha: 1) ,
        UIColor(red: 242/255, green: 110/255, blue: 134/255, alpha: 1),
        UIColor(red: 66/255, green: 168/255, blue: 129/255, alpha: 1),
        UIColor(red: 217/255, green: 186/255, blue: 95/255, alpha: 1),
        UIColor.blackColor(),
        UIColor(white: 0.15, alpha: 1)
    ]

    private init() {

    }
    
    func createStore(size:CGSize) {
        
        // Game
        for colorIndex in 0...blockColor.count-1 {

            blockTextures.append(createBlockTexture(size, color: blockColor[colorIndex],subImage: nil))

        }
        
        // Bomb
        for colorIndex in 0...3 {
            
            bombTextures.append(createBombTexture(size, color: blockColor[colorIndex]))
        }
    }
    
    private func createBlockTexture(size:CGSize , color:UIColor , subImage:UIImage?)->SKTexture {
        
        UIGraphicsBeginImageContext(size);
        color.setFill()
        let path = UIBezierPath(roundedRect: CGRectMake(0, 0, size.width, size.height), cornerRadius: size.width/4)
        path.fill()
        
        if let image = subImage {
            image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        }
        
        let baseImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return SKTexture(image: baseImage)
    }
    
    func createBombTexture(size:CGSize , color:UIColor)->SKTexture {
        
        let bombSizeModifer :CGFloat = CGFloat(16 * Int(UIScreen.mainScreen().bounds.width / 320))
        let bombOvalSize : CGFloat = size.width - bombSizeModifer
        
        UIGraphicsBeginImageContext(size);
        UIColor(white: 1, alpha: 0.7).setFill()
        let bombPath = UIBezierPath(ovalInRect: CGRectMake(bombSizeModifer/2, bombSizeModifer/2, bombOvalSize, bombOvalSize))
        let rectPath = UIBezierPath(roundedRect: CGRectMake((size.width - size.width/5)/2, bombSizeModifer/4, size.width/5, CGFloat(25 * Int(UIScreen.mainScreen().bounds.width / 320))), cornerRadius: size.width/5/4)
        bombPath.appendPath(rectPath)
        bombPath.fill()
        let bombImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
       
        return createBlockTexture(size, color:color , subImage: bombImage)

    }    
}
