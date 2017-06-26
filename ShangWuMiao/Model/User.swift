//
//  User.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/10.
//  Copyright © 2017年 moelove. All rights reserved.
//


import Foundation
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
    
    // 用户验证密码
    var passwordToCheck = ""

    /*
     1: 男
     2: 女
     */
    
    var gender = String()
    
    // 用户名
    var uname = String()
    
    // 头像 url string
    var avatarString = String()
    
    // 地理坐标
    var coordinateString = ""
    
    
    /* Struct Vendor
     0: 不是商户
     1: 普通商户
     2: 高级商户
     3: 超级商户
     */
    var vendorType: String = Vendor.normal   // Default
    // 金额, 有两位小数点
    var mcoins: Float = 0.00 {
        didSet {
            NotificationCenter.default.post(name: nyatoMcoinsChange, object: nil)
        }
    }
    
    // MARK: - 第三方登录绑定
    var bindType = "nyato"
    var bindToken = ""
    var bindUid = ""
//    var willRegisterNyato = false
    
    // MARK: - 绑定手机或者邮箱
    var telephone: String!
    var email: String!
    
    // 保存不同地区手机的信息
    var phonesInfo = [(title: String, area_code: String, length: Int)]()
    
    // Callback
    typealias callBack = (Bool, String) -> ()
    
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
        nyato_unregisterThirdParty()
    }
    
    static func parseUserData(with json: JSON) {
        let data = json["data"]
        
        let uid = data["uid"].stringValue
        let oauth_token = data["oauth_token"].stringValue
        let oauth_token_secret = data["oauth_token_secret"].stringValue
        let passwordToCheck = data["password"].stringValue
        
        User.shared.uid = uid
        User.shared.oauth_token = oauth_token
        User.shared.oauth_token_secret = oauth_token_secret
        User.shared.passwordToCheck = passwordToCheck
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
        let url = nonSignInUrl(forUrlType: .login, actType: .login)
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default, headers: nil).responseJSON {
                            response in
                            switch response.result {
                            case .success(let jsonResponse):
                                let json = JSON(jsonResponse)
                                
                                let info = json["info"].stringValue
                                let status = json["status"].intValue
                                if status == 1 {
                                    
                                    User.parseUserData(with: json)
                                }
                                completionHandler(status == 1, info)
                            case .failure(let error):
                                completionHandler(false, "登陆错误")
                                printX("error: \(error)")
                            }
                            
        }
        
    }

    // MARK: - User check
    static func userCheck(_ completionHandler: @escaping (_ isUserValid: Bool, _ info: String) -> ()) {

        let url = signedInUrl(forUrlType: .userCheck, actType: .user_check)
        
        let parameters = ["uid": NSString(string: User.shared.uid).integerValue,
                          "password": User.shared.passwordToCheck] as [String : Any]
        
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { (response) in
                            switch response.result {
                            case .success(let jsonResponse):
                                /* status
                                 0: 正常
                                 1: 密码变动
                                 2: 被禁用
                                 3: 被删除
                                 4: 缓存清理
                                 5: token加密失效
                                 >0: 退出用户
                                 */
                                let json = JSON(jsonResponse)

                                let status = json["status"].intValue
                                let info = json["info"].stringValue
                                completionHandler(status == 0, info)
                            case .failure(let error):
                                completionHandler(false, "请求数据失败")
                                printX("error: \(error)")
                            }
        }
    }
    
    // MARK: - Buy tickt
    static func buyTickt(ticktId id: Int, counts: Int, phone: String, price: Float, callBack: @escaping (Bool, String) -> ()) {

        let url = signedInUrl(forUrlType: .buyTickt, actType: .buyTicket)
        
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
                                printX("error: \(error)")
                                callBack(false, "购票错误")
                            }
        }
    }
    
    // MARK: - Setting info
    static func requestSettingInfo() {
        let url = signedInUrl(forUrlType: .setting, actType: .setting)!
        
        let parameters = ["uid": NSString(string: User.shared.uid).integerValue]
        Alamofire.request(url,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { response in
                            switch response.result {
                            case .success(let jsonResponse):
                                let json = JSON(jsonResponse)
                                
                                var phonesInfo = [(title: String, area_code: String, length: Int)]()
                                
                                let phones = json["phone"].arrayValue
                                
                                for phone in phones {
                                    let title = phone["title"].stringValue
                                    let area_code = phone["area_code"].stringValue
                                    let length = phone["length"].intValue
                                    
                                    let phoneInfo = (title, area_code, length)
                                    phonesInfo.append(phoneInfo)
                                }
                                
                                User.shared.phonesInfo = phonesInfo
                                
                            case .failure(let error):
                                printX("error: \(error)")
                            }
        }
    }
    
    // MARK: - User info
    static func requestUserInfo(completionHandler: @escaping (Bool, String?) -> ()) {

        let url = signedInUrl(forUrlType: .userInfo, actType: .getuinfo)
        
        let parameters = ["uid": NSString(string: User.shared.uid).integerValue]
        
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { response in
                            
                            switch response.result {
                            case .success(let jsonResponse):
                                let json = JSON(jsonResponse)
                                
//                                printX("json: \(json)")
                                
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
                                    
                                    let email = data["email"].stringValue
                                    let mobile = data["mobile"].stringValue
                                    
                                    user.email = (email == "") ? nil : email
                                    user.telephone = (mobile == "") ? nil : mobile
                                    
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
                                    
                                    // Statistics
                                    User.statisticWithCounty()
                                }
                                completionHandler(status == 1, info)
                            case .failure(let error):
                                completionHandler(false, "获取错误")
                                printX("error: \(error)")
                            }
        }
    }
    
    // Statistic
    static private func statisticWithCounty() {
        
        let user = User.shared
        
        Countly.sharedInstance().userLogged(in: user.uid)
        
        //default properties
        Countly.user().name = user.uid as CountlyUserDetailsNullableString
        Countly.user().username = user.uname as CountlyUserDetailsNullableString
        Countly.user().email = (user.email ?? "") as CountlyUserDetailsNullableString
        Countly.user().gender = (user.gender == "1" ? "M" : "F") as CountlyUserDetailsNullableString
        Countly.user().phone = (user.telephone ?? "") as CountlyUserDetailsNullableString
        
        //profile photo
        Countly.user().pictureURL = user.avatarString as CountlyUserDetailsNullableString
        
        Countly.user().save()
    }
    
    // MARK: - Feedback
    static func feedbackWithContent(contentText text: String, completionHandler: @escaping (Bool, String) -> ()) {
        
        let url = signedInUrl(forUrlType: .feedback, actType: .report)
        
        func deviceParameters() -> String {
            let device = UIDevice.current
            let model = device.model
            let systemVersion = device.systemVersion
            let appVersion = shangHuAppVersion  // may store in device
            
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
                let info = json["info"].stringValue
                let status = json["status"].intValue
                completionHandler(status == 1, info)
            case .failure(let error):
                completionHandler(false, "反馈错误")
                printX("error: \(error)")
            }
        }
    }
    
}




