//
//  LoginViewController+ThirdParty.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/14.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

extension LoginViewController {
    
    @IBAction func sinaLogin() {
        loginWith(platformType: .typeSinaWeibo, type: "sina")
    }
    
    @IBAction func qqLogin() {
        loginWith(platformType: .typeQQ, type: "qzone")
    }
    
    @IBAction func wehcatLogin() {
        loginWith(platformType: .typeWechat, type: "wechat")
    }
    
    private func loginWith(platformType: SSDKPlatformType, type: String) {
        ShareSDK.getUserInfo(platformType) { [weak self] (state, user, error) in
            print("=====user: \(user)")
            print("=====error: \(error)")
            print("=====state: \(state)")

            switch state {
            case .success:
                if let user = user {
                    User.shared.bindType = type
                    User.shared.bindUid = user.uid
                    User.shared.bindToken = user.credential.token
                    User.shared.avatarString = user.icon
                    User.shared.uname = user.nickname
                    print("======....success")
                    // Network layer
                    User.hadBindThirdParty(for: type, completionHandler: { (binded) in
                        if binded {
                            // TODO: to content window
                            SVProgressHUD.showSuccess(withStatus: "登录成功")
                            
                            self?.performSegue(withIdentifier: "login", sender: nil)
                            nyato_storeOauthData()
                        } else {
                            self?.bindAccountCheck()
                        }
                    })
                }
            case .fail:
                print("getUserInfo fail: \(String(describing: error))")
            default: break
            }
        }
    }
    
    private func bindAccountCheck() {
        let alert = UIAlertController(title: "请绑定喵特账号",
                                      message: "您还未绑定喵特账号，请选择以下操作完成喵特账号绑定",
                                      preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let nyatoAccount = UIAlertAction(title: "绑定已有账号",
                                         style: UIAlertActionStyle.default,
                                         handler: { [weak self] action in
                                            self?.bindNyato()
        })
//        let newOne = UIAlertAction(title: "新注册个账号",
//                                   style: .destructive,
//                                   handler: { [weak self] action in
//                                    self?.createNewOne()
//        })
        let newOne = UIAlertAction(title: "新注册个账号",
                                   style: .destructive,
                                   handler: { action in })

        alert.addAction(nyatoAccount)
        alert.addAction(newOne)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func bindNyato() {
        let alert = UIAlertController(title: "绑定已注册账号",
                                      message: "输入您在喵特注册的账号和密码，进行绑定",
                                      preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "请输入邮箱或者手机号码"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "请输入您的密码"
            textField.isSecureTextEntry = true
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let done = UIAlertAction(title: "确定绑定", style: .destructive) { (action) in
            if let account = alert.textFields?.first?.text,
                let password = alert.textFields?.last?.text {
                
                User.bindNaytoWithThirdPartyAccount(account, password: password, completionHander: { (success, info) in
                    if success {
                        // TODO: to content window
                        SVProgressHUD.showSuccess(withStatus: "绑定成功")
                    } else {
                        SVProgressHUD.showError(withStatus: "绑定失败")
                    }
                })
            } else {
                SVProgressHUD.showError(withStatus: "账号或密码不能为空")
            }
        }
        alert.addAction(done)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
}