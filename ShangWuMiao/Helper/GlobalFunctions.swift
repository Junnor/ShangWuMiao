//
//  GlobalFunc.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/10.
//  Copyright © 2017年 moelove. All rights reserved.
//

import Foundation
import UIKit


// MARK: - 加密相关
func stringOauthParameters() -> String {
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

// MARK: - 存在本地相关
let isLogin = "isLogin"
let uid = "uid"
let oauth_token = "oauth_token"
let oauth_token_secret = "oauth_token_secret"

let kDefaultCount = 10

func storeOauthData() {
    let standard = UserDefaults.standard
    
    standard.setValue("1", forKeyPath: isLogin)
    standard.setValue(User.shared.uid, forKeyPath: uid)
    standard.setValue(User.shared.oauth_token, forKeyPath: oauth_token)
    standard.setValue(User.shared.oauth_token_secret, forKeyPath: oauth_token_secret)
    
    UserDefaults.standard.synchronize()
}

func cleanStoredOauthData() {
    let standard = UserDefaults.standard
    
    standard.setValue(nil, forKey: isLogin)
    standard.setValue(nil, forKey: uid)
    standard.setValue(nil, forKey: oauth_token)
    standard.setValue(nil, forKey: oauth_token_secret)
    
    standard.synchronize()
}

private func getStoredOauthData() {
    let standard = UserDefaults.standard
    
    let stored_uid = standard.value(forKey: uid) as! String
    let stored_oauth_token = standard.value(forKey: oauth_token) as! String
    let stored_oauth_token_secret = standard.value(forKey: oauth_token_secret) as! String
    
    User.shared.uid = stored_uid
    User.shared.oauth_token = stored_oauth_token
    User.shared.oauth_token_secret = stored_oauth_token_secret
}

