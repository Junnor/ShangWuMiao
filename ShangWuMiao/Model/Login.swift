//
//  Login.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/23.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class Login: NSObject {
    
}

extension Login {
    
    // MARK: - 获取验证码
    static func requestPhoneCode(for phone: String, callback: @escaping (_ status: Bool, _ info: String) -> ()) {
        let count = phone.characters.count
        let value1 = Int(phone[0...2])!
        let value2 = Int(phone[3..<7])!
        let value3 = Int(phone[count-4...count-1])!
        let result = value1 + value2 + value3
        let codeString = String(result) + "nyato"
        let phoneCode = codeString.md5!

        let codeSecret = kSecretKey + ActType.sendPhoneCode
        let token = codeSecret.md5
        let loginUrlString = kHeaderUrl + RequestURL.kCodeUrlString + "&token=" + token!
        let url = URL(string: loginUrlString)

        let parameter = ["mobile": phone, "code": phoneCode, "type": "reg"]

        Alamofire.request(url!,
                          method: .post,
                          parameters: parameter,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { (response) in
                            switch response.result {
                            case .success(let jsonSource):
                                let json = JSON(jsonSource)
                                print("code json: \(json)")
                                let info = json["info"].stringValue
                                let status = json["status"].intValue
                                callback(status == 1, info)
                            case .failure(let error):
                                callback(false, "获取验证码失败")
                                print("get code error: \(error)")
                            }
        }
    }
    
    
    // MARK: - 注册
    static func register(forUser user: String, password: String, mobile: String, code: String, callback: @escaping (_ status: Bool, _ info: String) -> ()) {
        let registerSecret = kSecretKey + ActType.register
        let token = registerSecret.md5
        let loginUrlString = kHeaderUrl + RequestURL.kRegisterUrlString + "&token=" + token!
        
        let parameter = ["uname": user,
                         "password": password,
                         "mobile": mobile,
                         "code": code]
        
        print("...register parameter: \(parameter)")
        
        let url = URL(string: loginUrlString)

        Alamofire.request(url!,
                          method: .post,
                          parameters: parameter,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { (response) in
                            switch response.result {
                            case .success(let jsonSource):
                                let json = JSON(jsonSource)
                                print("register json: \(json)")
                                let info = json["info"].stringValue
                                let status = json["status"].intValue
                                callback(status == 1, info)
                            case .failure(let error):
                                callback(false, "注册错误")
                                print("register error: \(error)")
                            }
        }
    }
    
}
