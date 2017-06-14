//
//  AppDelegate.swift
//  ShangWuMiao
//
//  Created by 赵辉 on 2017/4/10.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Set navigation bar appearance and back title
        let barAppearance = UINavigationBar.appearance()
        barAppearance.tintColor = UIColor.white
        barAppearance.barTintColor = UIColor.barTintColor
        barAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UITabBar.appearance().tintColor = UIColor.themeYellow
        
        registerShare()

        // Set different window root vc
        if UserDefaults.standard.value(forKeyPath: isLogin) != nil {
            if let tabvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarViewController") as? TabBarViewController {
                window?.rootViewController = tabvc
            }
        }
        
        return true
    }
    
    // pay callback
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.host == "safepay" {
            AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: { response in
                let json = JSON(response as Any)
                let status = json["resultStatus"].intValue
                
                UserPay.shared.paySuccess = (status == 9000) ? true : false
                
                // tell database
                if  status == 9000 {
                    User.requestUserInfo(completionHandler: { (success, statusInfo) in
                        if success {
                            // TODO
                        } else {
                            SVProgressHUD.showInfo(withStatus: statusInfo)
                            print("request user info failure: \(String(describing: statusInfo))")
                        }
                    })
                    
                    UserPay.payResult(tradeStatus: status, callback: { success, info in
                        if success {
                            SVProgressHUD.showSuccess(withStatus: info)
                        } else {
                            SVProgressHUD.showError(withStatus: info!)
                        }
                    })
                }
                
            })
            
            AlipaySDK.defaultService().processAuth_V2Result(url, standbyCallback: { response in
                print("processAuth_V2Result response: \(String(describing: response))")
                // TODO: alipay
            })
        }
        
        return true
    }
    
    // MARK: Helper
    
    // ShareSDK: App Key 1e9aa2d08bba3
    private func registerShare() {
        let shareAppKey = "1e9aa2d08bba3"
        let nyatourl = "http://www.nyato.com"
        ShareSDK.registerApp(shareAppKey,
                             activePlatforms: [SSDKPlatformType.typeSinaWeibo.rawValue,
                                               SSDKPlatformType.typeTencentWeibo.rawValue,
                                               SSDKPlatformType.typeQQ.rawValue,
                                               SSDKPlatformType.subTypeQZone.rawValue,
                                               SSDKPlatformType.typeWechat.rawValue,
                                               SSDKPlatformType.typeAny.rawValue],
                             onImport: { (platform: SSDKPlatformType) in
                                switch platform{
                                case SSDKPlatformType.typeWechat:
                                    ShareSDKConnector.connectWeChat(WXApi.classForCoder())
                                    ShareSDKConnector.connectWeChat(WXApi.classForCoder(), delegate: self)
                                case SSDKPlatformType.typeQQ:
                                    ShareSDKConnector.connectQQ(QQApiInterface.classForCoder(), tencentOAuthClass: TencentOAuth.classForCoder())
                                case SSDKPlatformType.typeSinaWeibo:
                                    ShareSDKConnector.connectWeibo(WeiboSDK.classForCoder())
                                default:
                                    break
                                }
        }) { (platform: SSDKPlatformType, appInfo: NSMutableDictionary?) in
            switch platform {
            case SSDKPlatformType.typeSinaWeibo:
                print("=======sina weibo")
                //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                appInfo?.ssdkSetupSinaWeibo(byAppKey: "3026246088",
                                            appSecret: "beb7d09137b4bb35e83f67caf04c48ce",
                                            redirectUri : nyatourl,
                                            authType : SSDKAuthTypeBoth)
            case SSDKPlatformType.typeWechat:
                appInfo?.ssdkSetupWeChat(byAppId: "wx8356797cc8741cfb",
                                         appSecret: "432be9d7445dd12bff81e29ac6375c6a")
            case SSDKPlatformType.typeQQ:
                appInfo?.ssdkSetupQQ(byAppId: "1101335990",
                                     appKey: "1101335990",
                                     authType: SSDKAuthTypeSSO)
            case SSDKPlatformType.subTypeQZone:
                appInfo?.ssdkSetupQQ(byAppId: "1101335990",
                                     appKey: "1101335990",
                                     authType: SSDKAuthTypeSSO)
            default:
                break
            }
        }
    }
}

// Home sceen quick action
extension AppDelegate {
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        handleShortcutItem(shortcutItem)
        
        // Whether deal with the completionHandler
        if let navic = window?.rootViewController as? UINavigationController,
            let _ = navic.visibleViewController as? LoginViewController {
            completionHandler(false)
        } else {
            completionHandler(true)
        }
    }
    
    private enum ShortcutItemType: String {
        case topup = "com.nyato.shangwumiao.topup"
        case feedback = "com.nyato.shangwumiao.feedback"
    }
    
    @available(iOS 9.0, *)
    private func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) {
        switch shortcutItem.type {
        case ShortcutItemType.topup.rawValue:
            showTopup()
        case ShortcutItemType.feedback.rawValue:
            showFeedback()
        default:
            break
        }
    }
    
    private func showTopup() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let rootViewController = window?.rootViewController as? TabBarViewController {
            rootViewController.selectedIndex = 1
            
            if User.shared.vendorType != Vendor.none {
                
                let identifier = "TopupViewController"
                let topupViewController = storyboard.instantiateViewController(withIdentifier: identifier) as! TopupViewController
                
                if let meNavigationController = rootViewController.selectedViewController as? UINavigationController {
                    meNavigationController.pushViewController(topupViewController, animated: true)
                }
            }
        }
    }
        
    private func showFeedback() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let rootViewController = window?.rootViewController as? TabBarViewController {
            rootViewController.selectedIndex = 1
            
            let identifier = "FeedbackViewController"
            let feedbackVC = storyboard.instantiateViewController(withIdentifier: identifier) as! FeedbackViewController
            
            if let meNavigationController = rootViewController.selectedViewController as? UINavigationController {
                meNavigationController.pushViewController(feedbackVC, animated: true)
            }
        }
    }
    
}

