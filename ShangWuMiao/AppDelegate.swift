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

