//
//  User+ThirdParty.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/15.
//  Copyright © 2017年 moelove. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension User {

    // MARK: - Bind third party with nyato acoount
    static func bindNaytoWithThirdPartyAccount(_ account: String, password: String, completionHander: @escaping (_ success: Bool, _ info: String?) -> ()) {
        let stringParas = stringBindThirdPartyParameters(actTo: ActType.bindNyato)
        let urlString = kHeaderUrl + RequestURL.kBindNyatoUrlString + stringParas
        
        let app_time = String(NSDate().timeIntervalSince1970*1000).components(separatedBy: ".").first!
        let au = app_time.md5!
        
        let paras = ["email": account,
                     "password": password,
                     "other_type": User.shared.bindType,
                     "type_uid": User.shared.bindUid,
                     "oauth_token": au]
        
        let url = URL(string: urlString)!
        
        Alamofire.request(url,
                          method: .post,
                          parameters: paras,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { (response) in
                            
                            switch response.result {
                            case .success(let jsonResponse):
                                let json = JSON(jsonResponse)
                                print("bind nyato json = \(json)")
                                let status = json["status"].intValue
                                if status == 100 {
                                    // TODO: - parse .......
                                    let data = json["data"]
                                    let uid = data["uid"].stringValue
                                    let oauth_token = data["oauth_token"].stringValue
                                    let oauth_token_secret = data["oauth_token_secret"].stringValue
                                    User.shared.uid = uid
                                    User.shared.oauth_token = oauth_token
                                    User.shared.oauth_token_secret = oauth_token_secret
                                    
                                    completionHander(true, nil)
                                } else {
                                    let info = json["info"].stringValue
                                    completionHander(false, info)
                                }
                                
                            case .failure(let error):
                                print("bind nyato error: \(error)")
                            }
        }
    }
    
    // MARK: - Login with third party
    // if binded aready, then login directory, otherwise, let user to bind the account
    static func hadBindThirdParty(for type: String, completionHandler: @escaping (_ binded: Bool) -> ()) {
        
        let stringParas = stringBindThirdPartyParameters(actTo: ActType.thirdParty_BindCheck)
        let urlString = kHeaderUrl + RequestURL.kThirdPartyBindCheckUrlString + stringParas
        let url = URL(string: urlString)!
        let paras = ["other_type": type,
                     "type_uid": User.shared.bindUid]
        
        Alamofire.request(url,
                          method: .post,
                          parameters: paras,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { (response) in
                            switch response.result {
                            case .success(let jsonResponse):
                                let json = JSON(jsonResponse)
                                print("third party json = \(json)")
                                let status = json["status"].intValue
                                if status == 0 {
                                    completionHandler(false)
                                } else {
                                    let data = json["data"]
                                    
                                    let uid = data["uid"].stringValue
                                    let oauth_token = data["oauth_token"].stringValue
                                    let oauth_token_secret = data["oauth_token_secret"].stringValue
                                    let passwordToCheck = data["password"].stringValue
                                    
                                    User.shared.uid = uid
                                    User.shared.oauth_token = oauth_token
                                    User.shared.oauth_token_secret = oauth_token_secret
                                    User.shared.passwordToCheck = passwordToCheck
                                    
                                    completionHandler(true)
                                }
                            case .failure(let error):
                                completionHandler(false)
                                print("bind error: \(error)")
                            }
        }
    }
    

}
