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
                                let status = json["status"].intValue
                                var info = ""
                                switch status {
                                case 101: info = "成功"
                                case 102: info = "失败"
                                case 103: info = "名称过长或过短"
                                case 104: info = "名称含有违禁词"
                                case 105: info = "名称已存在"
                                case 106: info = "该手机已绑定"
                                case 107: info = "密码不合格"
                                default: info = "未定义"
                                    break
                                }
                                
                                if status == 101 {
                                    let data = json["data"].dictionaryValue
                                    let dataJson = JSON(data)
                                    let uid = dataJson["uid"].stringValue
                                    let oauth_token = dataJson["oauth_token"].stringValue
                                    let oauth_token_secret = dataJson["oauth_token_secret"].stringValue
                                    
                                    User.shared.uid = uid
                                    User.shared.oauth_token = oauth_token
                                    User.shared.oauth_token_secret = oauth_token_secret
                                }
                                
                                callback(status == 101, info)
                            case .failure(let error):
                                callback(false, "注册错误")
                                print("register error: \(error)")
                            }
        }
    }
    
}
