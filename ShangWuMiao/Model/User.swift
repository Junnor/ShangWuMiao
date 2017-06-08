//
//  User.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/10.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

final class User {
    
    // MARK: - singleton
    static let shared = User()
    private init() {}
    
    // MARK: - Properties
    
    // 用户ID
    var uid = String()
    
    // 用户加密信息
    var oauth_token = String()
    
    // 用户加密信息
    var oauth_token_secret = String()
    
    /*
     1: 男
     2: 女
     */
    
    var gender = String()
    
    // 用户名
    var uname = String()
    
    // 头像 url string
    var avatarString = String()
    
    /* Struct Vendor
     0: 不是商户
     1: 普通商户
     2: 高级商户
     3: 超级商户
     */
    var vendorType: String = Vendor.none   // Default
    // 金额, 有两位小数点
    var mcoins: Float = 0.00 {
        didSet {
            NotificationCenter.default.post(name: nyatoMcoinsChange, object: nil)
        }
    }
    

    // MARK: - clean after sign out
    func clean() {
        uid = ""
        oauth_token = ""
        oauth_token_secret = ""
        gender = ""
        uname = ""
        avatarString = ""
        vendorType = ""
        mcoins = 0.00
        
        nyato_cleanStoredOauthData()
    }
}

struct Vendor {
    static let none = "不是商户"
    static let normal = "普通商户"
    static let vip = "高级商户"
    static let superVip = "超级商户"
}

extension User {
    
    // MARK: - Login
    static func login(parameters: Dictionary<String, String>,
                      completionHandler: @escaping (_ success: Bool, _ info: String) -> ()) {
        let loginSecret = kSecretKey + ActType.login
        let token = loginSecret.md5
        let loginUrlString = kHeaderUrl + RequestURL.kLoginUrlString + "&token=" + token!
        
        let url = URL(string: loginUrlString)
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default, headers: nil).responseJSON {
                            response in
                            switch response.result {
                            case .success(let jsonResponse):
                                let json = JSON(jsonResponse)
//                                print("login json = \(json)")
                                let info = json["info"].stringValue
                                let status = json["status"].intValue
                                if status == 1 {
                                    let data = json["data"]
                                    let uid = data["uid"].stringValue
                                    let oauth_token = data["oauth_token"].stringValue
                                    let oauth_token_secret = data["oauth_token_secret"].stringValue
                                    User.shared.uid = uid
                                    User.shared.oauth_token = oauth_token
                                    User.shared.oauth_token_secret = oauth_token_secret
                                }
                                completionHandler(status == 1, info)
                            case .failure(let error):
                                completionHandler(false, "登陆错误")
                                print("login error = \(error)")
                            }
                            
        }
        
    }
    
    // MARK: - Buy tickt
    static func buyTickt(ticktId id: Int, counts: Int, phone: String, price: Float, callBack: @escaping (Bool, String) -> ()) {
        let stringPara = stringParameters(actTo: ActType.buyTicket)
        let userinfoString = kHeaderUrl + RequestURL.kBuyTicktUrlString + stringPara
        let url = URL(string: userinfoString)
        
        let parameters = ["uid": NSString(string: User.shared.uid).integerValue,
                          "ticket_id": id,
                          "shop_num": counts,
                          "tel": phone,
                          "price": price] as [String : Any]
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { response in
                            switch response.result {
                            case .success(let jsonResponse):
                                let json = JSON(jsonResponse)
                                let info = json["info"].stringValue
                                let status = json["status"].intValue
                                callBack(status == 1, info)
                            case .failure(let error):
                                print("buy tickts error: \(error)")
                                callBack(false, "购票错误")
                            }
        }
    }

    // MARK: - User info
    static func requestUserInfo(completionHandler: @escaping (Bool, String?) -> ()) {
        let stringPara = stringParameters(actTo: ActType.getuinfo)
        let userinfoString = kHeaderUrl + RequestURL.kUserInfoUrlString + stringPara
        let url = URL(string: userinfoString)
        
        let parameters = ["uid": NSString(string: User.shared.uid).integerValue]
        
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { response in
                            
                            switch response.result {
                            case .success(let jsonResponse):
                                let json = JSON(jsonResponse)
//                                print("user info json: \(json)")
                                let info = json["info"].stringValue
                                let status = json["status"].intValue
                                
                                if status == 1 {
                                    let data = json["data"]
                                    let user = User.shared
                                    
                                    let uname = data["uname"].stringValue
                                    let isBusiness = data["is_business"].stringValue
                                    let avatarUrlString = data["avatar"].stringValue
                                    let gender = data["sex"].stringValue
                                    let mcoins = data["mcoins"].floatValue
                                    
                                    user.mcoins = mcoins
                                    user.avatarString = avatarUrlString
                                    user.uname = uname
                                    user.gender = gender
                                    
                                    switch isBusiness {
                                    case "0": user.vendorType = Vendor.none
                                    case "1": user.vendorType = Vendor.normal
                                    case "2": user.vendorType = Vendor.vip
                                    case "3": user.vendorType = Vendor.superVip
                                    default: break
                                    }

                                }
                                completionHandler(status == 1, info)
                            case .failure(let error):
                                completionHandler(false, "获取错误")
                                print("get user info error: \(error)")
                            }
        }
    }
    
    // MARK: - Feedback
    static func feedbackWithContent(contentText text: String, completionHandler: @escaping (Bool, String) -> ()) {
        let stringPara = stringParameters(actTo: ActType.report)
        let userinfoString = kHeaderUrl + RequestURL.kFeedbackUrlString + stringPara
        let url = URL(string: userinfoString)
        
        func deviceParameters() -> String {
            let device = UIDevice.current
            let model = device.model
            let systemVersion = device.systemVersion
            let appVersion = kAppVersion  // may store in device
            
            return "appVersion: \(appVersion), systemVersion: \(systemVersion), device: \(model)"
        }

        let parameters = ["uid": NSString(string: User.shared.uid).integerValue,
                          "denounce": text,
                          "type": "iOS",
                          "id": 0,
                          "denounce_version": deviceParameters()] as [String : Any]

        Alamofire.request(url!, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            switch response.result {
            case .success(let jsonResponse):
                let json = JSON(jsonResponse)
//                print("feed back json: \(json)")
                let info = json["info"].stringValue
                let status = json["status"].intValue
                completionHandler(status == 1, info)
            case .failure(let error):
                completionHandler(false, "反馈错误")
                print("feed back error: \(error)")
            }
        }
    }
    
}




