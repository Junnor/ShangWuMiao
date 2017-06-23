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
        let url = nonSignInUrl(forUrlType: .verifyCodeForRetrievePsw, actType: .verifyCodeForRetrievePsw)!
        
        let parameter = ["mobile": phone,
                         "code": verifyCode]
        
        Alamofire.request(url,
                          method: .post,
                          parameters: parameter,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { (response) in
                            switch response.result {
                            case .success(let jsonResponse):
                                let json = JSON(jsonResponse)
                                let status = json["status"].intValue
                                let info = json["info"].stringValue
                                completionHandler(status == 1, info)
                            case .failure(let error):
                                completionHandler(false, "网络发生错误")
                                printX("error: \(error)")
                            }
        }
    }
    
    static func resetPassword(by phoneNumber: String,
                              password: String,
                              repeatPassword: String,
                              completionHandler: @escaping (_ state: Bool, _ info: String) -> ()) {

        let url = nonSignInUrl(forUrlType: .retrievePasswordWithTelephone,
                               actType: .retrievePasswordWithTelephone)!
        
        let parameter = ["mobile": phoneNumber,
                         "password": password,
                         "repassword": repeatPassword]
        
        Alamofire.request(url,
                          method: .post,
                          parameters: parameter,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { (response) in
                            switch response.result {
                            case .success(let jsonResponse):
                                let json = JSON(jsonResponse)
                                let status = json["status"].intValue
                                let info = json["info"].stringValue
                                completionHandler(status == 1, info)
                            case .failure(let error):
                                completionHandler(false, "网络发生错误")
                                printX("error: \(error)")
                            }
        }
    }
    
    static func retrievePasswordWithEmail(_ email: String, completionHandler: @escaping (_ state: Bool, _ info: String) -> ()) {

        let url = nonSignInUrl(forUrlType: .retrievePasswordWithEmail,
                               actType: .retrievePasswordWithEmail)!


        let parameter = ["email": email]
        
        Alamofire.request(url,
                          method: .post,
                          parameters: parameter,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { (response) in
                            switch response.result {
                            case .success(let jsonResponse):
                                let json = JSON(jsonResponse)
                                let status = json["status"].intValue
                                let info = json["info"].stringValue
                                completionHandler(status == 1, info)
                            case .failure(let error):
                                completionHandler(false, "网络发生错误")
                                printX("error: \(error)")
                            }
        }
    }

}
