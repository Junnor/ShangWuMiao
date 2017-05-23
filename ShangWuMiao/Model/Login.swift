//
//  Login.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/23.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit

class Login: NSObject {
    
}

extension Login {
    static func requestPhoneCode(for phone: String, callback: @escaping (_ status: Bool, _ info: String) -> ()) {
        
        for c in phone.characters {
            print("\(c)")
        }
        
        let count = phone.characters.count
        let str = phone[count-4...count-1]
        let codeString = phone[0...2] + phone[3..<7] + str
        let phoneCode = codeString.md5

        let loginSecret = kSecretKey + ActType.sendPhoneCode
        let token = loginSecret.md5
        let loginUrlString = kHeaderUrl + RequestURL.kCodeUrlString + "&token=" + token!
        
        let parameter = ["mobile": phone, "code": phoneCode, "type": "bind"]
        
        let url = URL(string: loginUrlString)
    }
}
