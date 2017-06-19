//
//  User+Setting.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/16.
//  Copyright © 2017年 moelove. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


extension User {
    
    // MARK: - Me reset password
    static func meResetPassword(_ password: String,
                                repassword: String,
                                original: String,
                                completionHandler: @escaping (Bool, String) -> ()) {
        
        let url = signedInUrl(forUrlType: .meResetPassword, actType: .meResetPassword)!
        let parameters = ["password": password,
                          "repassword": repassword,
                          "oldpassword": original]
        
        Alamofire.request(url,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { response in
                            switch response.result {
                            case .success(let jsonResponse):
                                let json = JSON(jsonResponse)
                                print("me reset passwor json: \(json)")
                                let info = json["info"].stringValue
                                let status = json["status"].intValue
                                completionHandler(status == 1, info)
                            case .failure(let error):
                                completionHandler(false, "发生错误")
                                print("me reset password error: \(error)")
                            }
        }
        
    }

    
    // MARK: - Bind email
    static func bindEmail(_ email: String,
                          completionHandler: @escaping (Bool, String) -> ()) {
        
        let url = signedInUrl(forUrlType: .bindEmail, actType: .bindEmail)!
        let parameters = ["email": email]
        
        Alamofire.request(url,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { response in
                            switch response.result {
                            case .success(let jsonResponse):
                                let json = JSON(jsonResponse)
                                print("bind email json: \(json)")
                                let info = json["info"].stringValue
                                let status = json["status"].intValue                                
                                completionHandler(status == 1, info)
                            case .failure(let error):
                                completionHandler(false, "发生错误")
                                print("bind email error: \(error)")
                            }
        }
        
    }
    
    // MARK: - Bind telephone
    static func bindTelephone(_ telephone: String) {
    }

}


