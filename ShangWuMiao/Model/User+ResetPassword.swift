//
//  User+ResetPassword.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/16.
//  Copyright © 2017年 moelove. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension User {
    
    static func verifyCodeForRetrievePswPhone(_ phone: String,
                                              verifyCode: String,
                                              completionHandler: @escaping (_ state: Bool, _ info: String) -> ()) {
        let secret = kSecretKey + ActType.verifyCodeForRetrievePsw
        let token = secret.md5
        let urlString = kHeaderUrl + RequestURL.kVerifyCodeForRetrievePswUrlString + "&token=" + token!
        let url = URL(string: urlString)
        
        let parameter = ["mobile": phone,
                         "code": verifyCode]
        
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameter,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { (response) in
                            switch response.result {
                            case .success(let jsonResponse):
                                let json = JSON(jsonResponse)
                                print(".....verify code json: \(json)")
                                let status = json["status"].intValue
                                let info = json["info"].stringValue
                                completionHandler(status == 1, info)
                            case .failure(let error):
                                completionHandler(false, "网络发生错误")
                                print("verify code error: \(error)")
                            }
        }
    }
    
    static func resetPassword(by phoneNumber: String,
                              password: String,
                              repeatPassword: String,
                              completionHandler: @escaping (_ state: Bool, _ info: String) -> ()) {
        
        let secret = kSecretKey + ActType.retrievePasswordWithTelephone
        let token = secret.md5
        let loginUrlString = kHeaderUrl + RequestURL.kRetrievePasswordWithTelephoneUrlString + "&token=" + token!
        let url = URL(string: loginUrlString)
        
        let parameter = ["mobile": phoneNumber,
                         "password": password,
                         "repassword": repeatPassword]
        
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameter,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { (response) in
                            switch response.result {
                            case .success(let jsonResponse):
                                let json = JSON(jsonResponse)
                                print(".....verify telephone json: \(json)")
                                let status = json["status"].intValue
                                let info = json["info"].stringValue
                                completionHandler(status == 1, info)
                            case .failure(let error):
                                completionHandler(false, "网络发生错误")
                                print("verify telephone  error: \(error)")
                            }
        }
    }
    
    static func retrievePasswordWithEmail(_ email: String, completionHandler: @escaping (_ state: Bool, _ info: String) -> ()) {
        let emailSecret = kSecretKey + ActType.retrievePasswordWithEmail
        let token = emailSecret.md5
        let loginUrlString = kHeaderUrl + RequestURL.kRetrievePasswordWithEmailUrlString + "&token=" + token!
        let url = URL(string: loginUrlString)

        let parameter = ["email": email]
        
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameter,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { (response) in
                            switch response.result {
                            case .success(let jsonResponse):
                                let json = JSON(jsonResponse)
//                                print(".....verify email json: \(json)")
                                let status = json["status"].intValue
                                let info = json["info"].stringValue
                                completionHandler(status == 1, info)
                            case .failure(let error):
                                completionHandler(false, "网络发生错误")
                                print("verify email error: \(error)")
                            }
        }
    }

}
