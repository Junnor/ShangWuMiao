//
//  GlobalFunc.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/10.
//  Copyright © 2017年 moelove. All rights reserved.
//

import Foundation

// MARK: - 未登录情况的通过参数获取的URL

func nyato_url(for act: String) -> URL? {
    return nil
}

// MARK: - 加密相关
func stringOauthParameters() -> String {
    
    func getStoredOauthData() {
        let standard = UserDefaults.standard
        
        let stored_uid = standard.value(forKey: uid) as! String
        let stored_oauth_token = standard.value(forKey: oauth_token) as! String
        let stored_oauth_token_secret = standard.value(forKey: oauth_token_secret) as! String
        let passwordCheck = standard.value(forKey: passwordToCheck) as! String
        
        User.shared.uid = stored_uid
        User.shared.oauth_token = stored_oauth_token
        User.shared.oauth_token_secret = stored_oauth_token_secret
        User.shared.passwordToCheck = passwordCheck
    }
    
    if User.shared.uid .isEmpty {
        getStoredOauthData()
    }
    
    let uid_para = "&uid=" + User.shared.uid
    let oauth_token_para = "&oauth_token=" + User.shared.oauth_token
    let oauth_token_secret_para = "&oauth_token_secret=" + User.shared.oauth_token_secret
    
    return uid_para + oauth_token_para + oauth_token_secret_para
}

// MARK: - 登陆后的一系列需要参数
func stringParameters(actTo act: String) -> String {
    let oauth_para = stringOauthParameters()
    
    let userinfoSecret = kSecretKey + act
    let token = userinfoSecret.md5
    let app_time = String(NSDate().timeIntervalSince1970*1000).components(separatedBy: ".").first!
    let app_device = UIDevice.current.identifierForVendor?.uuidString ?? "0"
    
    let sort = [app_device, app_time, token!, User.shared.uid]
    let sorted = sort.sorted { $0 < $1 }
    let appsignSecret = sorted.joined(separator: "&")
    let app_sign = appsignSecret.md5
    
    let app_time_para = "&app_time=" + app_time
    let app_device_para = "&app_device=" + app_device
    let token_para = "&token=" + token!
    let app_sign_para = "&app_sign=" + app_sign!
    
    let version = "&version=" + kAppVersion
    
    return token_para + oauth_para + app_time_para + app_device_para + app_sign_para + version
}

// MARK: - 第三方登录绑定的参数
func stringBindThirdPartyParameters(actTo act: String) -> String {
    
    let app_time = String(NSDate().timeIntervalSince1970*1000).components(separatedBy: ".").first!
    
    let uid_para = "&uid=" + ""
    let oauth_token_para = "&oauth_token=" + app_time.md5
    let oauth_token_secret_para = "&oauth_token_secret=" + kAppVersion.md5
    
    let oauth_para = uid_para + oauth_token_para + oauth_token_secret_para
    
    let userinfoSecret = kSecretKey + act
    let token = userinfoSecret.md5
    let app_device = UIDevice.current.identifierForVendor?.uuidString ?? "0"
    
    let sort = [app_device, app_time, token!, User.shared.uid]
    let sorted = sort.sorted { $0 < $1 }
    let appsignSecret = sorted.joined(separator: "&")
    let app_sign = appsignSecret.md5
    
    let app_time_para = "&app_time=" + app_time
    let app_device_para = "&app_device=" + app_device
    let token_para = "&token=" + token!
    let app_sign_para = "&app_sign=" + app_sign!
    
    let version = "&version=" + kAppVersion
    
    return token_para + oauth_para + app_time_para + app_device_para + app_sign_para + version
}

// MARK: - 存在本地相关
let isLogin = "isLogin"
let uid = "uid"
let oauth_token = "oauth_token"
let oauth_token_secret = "oauth_token_secret"
let passwordToCheck = "passwordToCheck"

let kDefaultCount = 10

func nyato_storeOauthData() {
    let standard = UserDefaults.standard
    
    standard.setValue("1", forKeyPath: isLogin)
    standard.setValue(User.shared.uid, forKeyPath: uid)
    standard.setValue(User.shared.oauth_token, forKeyPath: oauth_token)
    standard.setValue(User.shared.oauth_token_secret, forKeyPath: oauth_token_secret)
    standard.setValue(User.shared.passwordToCheck, forKeyPath: passwordToCheck)

    UserDefaults.standard.synchronize()
}

func nyato_cleanStoredOauthData() {
    let standard = UserDefaults.standard
    
    standard.setValue(nil, forKey: isLogin)
    standard.setValue(nil, forKey: uid)
    standard.setValue(nil, forKey: oauth_token)
    standard.setValue(nil, forKey: oauth_token_secret)
    standard.setValue(nil, forKey: passwordToCheck)

    standard.synchronize()
}

// MARK: - unregister the third party
func nyato_unregisterThirdParty() {
    if ShareSDK.hasAuthorized(.typeSinaWeibo) {
        ShareSDK.cancelAuthorize(.typeSinaWeibo)
    }
    if ShareSDK.hasAuthorized(.typeQQ) {
        ShareSDK.cancelAuthorize(.typeQQ)
    }
    if ShareSDK.hasAuthorized(.typeWechat) {
        ShareSDK.cancelAuthorize(.typeWechat)
    }
}


func nyato_isPhoneNumber(phoneNumber:String?) -> (result: Bool, info: String?) {
    if let phoneNumber = phoneNumber {
        if phoneNumber.characters.count == 0 {
            return (false, "手机号码不能为空...")
        }
        let mobile = "^(13[0-9]|15[0-9]|18[0-9]|17[0-9]|147)\\d{8}$"
        let regexMobile = NSPredicate(format: "SELF MATCHES %@",mobile)
        if regexMobile.evaluate(with: phoneNumber) == true {
            return (true, nil)
        } else {
            return (false, "请输入正确的手机号码...")
        }
    }
    return (false, "手机号码不能为空...")
}
