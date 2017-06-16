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
    
    static func resetPassword() {}
    
    static func findPasswordWithEmail(_ email: String, completionHandler: @escaping (_ state: Bool, _ info: String) -> ()) {
        let registerSecret = kSecretKey + ActType.findPasswordWithEmail
        let token = registerSecret.md5
        let loginUrlString = kHeaderUrl + RequestURL.kFindPasswordWithEmailUrlString + "&token=" + token!
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
                                print("verify json error: \(error)")
                            }
        }
    }

}
