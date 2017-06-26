//
//  ClassHelper.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/19.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit


extension UIStoryboard {
    
    static var Main: String {
        return "Main"
    }
    
    static var Me: String {
        return "Me"
    }
    
    static var Exhibition: String {
        return "Exhibition"
    }
    
//    enum StoryboardName: String {
//        case main = "Main"
//        case me = "Me"
//        case exhibition = "Exhibition"
//    }
 }

extension UIViewController {
    static var itentifier: String {
        return self.description()
    }
}

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
        
    subscript(pos: Int) -> String {
        precondition(pos >= 0, "character position can't be negative")
        return self[pos...pos]
    }
    subscript(range: Range<Int>) -> String {
        precondition(range.lowerBound >= 0, "range lowerBound can't be negative")
        let lowerIndex = index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex) ?? endIndex
        return self[lowerIndex..<(index(lowerIndex, offsetBy: range.count, limitedBy: endIndex) ?? endIndex)]
    }
    subscript(range: ClosedRange<Int>) -> String {
        precondition(range.lowerBound >= 0, "range lowerBound can't be negative")
        let lowerIndex = index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex) ?? endIndex
        return self[lowerIndex..<(index(lowerIndex, offsetBy: range.count, limitedBy: endIndex) ?? endIndex)]
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
    
    static var mainTextColor: UIColor {
        return UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0)
    }

    // For Share

    static var sinaBGColor: UIColor {
        return UIColor(red: 252/255.0, green: 36/255.0, blue: 34/255.0, alpha: 1.0)
    }
    
    static var qqBGColor: UIColor {
        return UIColor(red: 50/255.0, green: 172/255.0, blue: 252/255.0, alpha: 1.0)
    }
    
    static var qqZoneBGColor: UIColor {
        return UIColor(red: 253/255.0, green: 187/255.0, blue: 99/255.0, alpha: 1.0)
    }
    static var wechatBGColor: UIColor {
        return UIColor(red: 101/255.0, green: 189/255.0, blue: 66/255.0, alpha: 1.0)
    }
    static var wechatFriendBGColor: UIColor {
        return UIColor(red: 253/255.0, green: 126/255.0, blue: 61/255.0, alpha: 1.0)
    }
    
    static var wechatStoreBGColor: UIColor {
        return wechatBGColor
    }
    static var grayBGColor: UIColor {
        return UIColor(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha: 1.0)
    }

}

extension UIScrollView {
    
    // Insert scroll view in uiview
    func nyato_keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            var endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                let contentInset:UIEdgeInsets = UIEdgeInsets.zero
                self.contentInset = contentInset
            } else {
                endFrame = self.superview?.convert(endFrame!, from: nil)
                var contentInset:UIEdgeInsets = self.contentInset
                contentInset.bottom = endFrame!.size.height
                self.contentInset = contentInset
            }
            
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.superview?.layoutIfNeeded() },
                           completion: nil)
        }
    }

}
