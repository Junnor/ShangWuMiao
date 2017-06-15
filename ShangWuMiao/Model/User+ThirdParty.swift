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

    // MARK: - create nyato account with third party
    static func createNyatoAccount(_ account: String, password: String, completionHander: @escaping (_ success: Bool, _ info: String?) -> ()) {
        let stringParas = stringBindThirdPartyParameters(actTo: ActType.thirdPartyCreateNyato)
        let urlString = kHeaderUrl + RequestURL.kThirdPartyCreateNyatoUrlString + stringParas
        let url = URL(string: urlString)!
        let paras = ["uname": account,
                     "password": password,
                     "other_type": User.shared.bindType,
                     "type_uid": User.shared.bindUid]
        Alamofire.request(url,
                          method: .post,
                          parameters: paras,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { (response) in
                            switch response.result {
                            case .success(let jsonResponse):
                                let json = JSON(jsonResponse)
//                                print("create nyato account json: \(json)")
                                let status = json["status"].intValue
                                var info = ""
                                switch status {
                                case 100:
                                    info = "成功"
                                    User.parseUserData(with: json)
                                case 101, 102: info = "请重试"
                                case 103: info = "名称过长或过短"
                                case 104: info = "名称含有违禁词"
                                case 105: info = "名称已存在"
                                case 106: info = "该手机已绑定"
                                case 107: info = "密码不合格"
                                default: info = "未定义"
                                    break
                                }
                                
                                completionHander(status == 100, info)
                                
                            case .failure(let error):
                                completionHander(false, "注册错误")
                                print("create nyato account failure: \(error)")
                            }
        }

    }

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
                                    User.parseUserData(with: json)
                                    
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
//                                print("third party json = \(json)")
                                let status = json["status"].intValue
                                if status == 0 {
                                    completionHandler(false)
                                } else {
                                    User.parseUserData(with: json)
                                    completionHandler(true)
                                }
                            case .failure(let error):
                                completionHandler(false)
                                print("bind error: \(error)")
                            }
        }
    }
    

}
