//
//  ClassHelper.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/19.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit

extension UIImage {
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

extension String  {
    var md5: String! {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deallocate(capacity: digestLen)
        
        return String(format: hash as String)
    }
}


extension UIColor {
    
    static func naviBarTintColor(alpha: CGFloat) -> UIColor {
        return UIColor(red: 31/255.0, green: 31/255.0, blue: 31/255.0, alpha: alpha)
    }
    
    static var barTintColor: UIColor {
        return UIColor(red: 31/255.0, green: 31/255.0, blue: 31/255.0, alpha: 1.0)
    }

    static var background: UIColor {
        return UIColor(red: 239/255.0, green: 239/255.0, blue: 244/255.0, alpha: 1.0)
    }
    
    static var themeRed: UIColor {
        return UIColor(red: 255/255.0, green: 89/255.0, blue: 104/255.0, alpha: 1.0)
    }
    
    
    static var themeYellow: UIColor {
        return UIColor(red: 255/255.0, green: 214/255.0, blue: 0.0, alpha: 1.0)
    }

}

