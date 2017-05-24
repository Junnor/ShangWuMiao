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
    
    /*
     0: 不是商户
     1: 普通商户
     2: 高级商户
     3: 超级商户
     */
    var isBusiness = String()
    
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
        isBusiness = ""
        mcoins = 0.00
        
        nyato_cleanStoredOauthData()
    }
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
                          encoding: URLEncoding.default, headers: nil).responseJSON {                            response in
                            switch response.result {
                            case .success(let json):
//                                print("login json = \(json)")
                                if let dic = json as? Dictionary<String, AnyObject> {
                                    if let status = dic["status"] as? Int {
                                        let info = dic["info"] as! String
                                        
                                        // user data
                                        if status == 1 {
                                            let data = dic["data"] as? Dictionary<String, String>
                                            if let data = data {
                                                let uid = data["uid"]
                                                let oauth_token = data["oauth_token"]
                                                let oauth_token_secret = data["oauth_token_secret"]
                                                
                                                User.shared.uid = uid ?? ""
                                                User.shared.oauth_token = oauth_token ?? ""
                                                User.shared.oauth_token_secret = oauth_token_secret ?? ""
                                            }
                                        }
                                        
                                        print("login info: \(info)")
                                        completionHandler(status == 1, info)
                                    }
                                }
                            case .failure(let error):
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
                            case .success(let source):
                                let json = JSON(source)
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
                            case .success(let json):
//                                print("user info json: \(json)")
                                if let dic = json as? Dictionary<String, AnyObject> {
                                    guard let status = dic["status"] as? Int, status == 1 else {
                                        let info = dic["info"] as? String
                                        completionHandler(false, info)
                                        return
                                    }
                                    if let data = dic["data"] as? Dictionary<String, AnyObject> {
                                        let user = User.shared
                                        
                                        let uname = data["uname"] as? String
                                        let isBusiness = data["is_business"] as? String
                                        let avatarUrlString = data["avatar"] as? String
                                        let gender = data["sex"] as? String
                                        
                                        let mcoins = data["mcoins"]
                                        if mcoins is Float {
                                            user.mcoins = mcoins as! Float
                                        } else if mcoins is String {
                                            user.mcoins = Float((mcoins as! String))!
                                        }
                                        
                                        user.avatarString = avatarUrlString ?? ""
                                        user.uname = uname ?? ""
                                        user.gender = gender ?? ""
                                        
                                        if isBusiness != nil {
                                            switch isBusiness! {
                                            case "0": user.isBusiness = "不是商户"
                                            case "1": user.isBusiness = "普通商户"
                                            case "2": user.isBusiness = "高级商户"
                                            case "2": user.isBusiness = "超级商户"
                                            default: break
                                            }
                                        }
                                        
                                        completionHandler(true, nil)
                                    }
                                }
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
            case .success(let json):
                print("feed back json: \(json)")
            case .failure(let error):
                completionHandler(false, "反馈错误")
                print("feed back error: \(error)")
            }
        }
    }
    
}




