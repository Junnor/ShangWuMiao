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
import SafariServices
import UserNotifications
import WebKit


fileprivate let viewActionIdentifier = "VIEW_IDENTIFIER"
fileprivate let newsCategoryIdentifier = "NEWS_CATEGORY"

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
        
        registerJPush(with: launchOptions)
        
        // Set different window root vc
        if UserDefaults.standard.value(forKeyPath: isLogin) != nil {
            if let tabvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarViewController") as? TabBarViewController {
                window?.rootViewController = tabvc
            }
        }
        
        handleAPNsIfNeeded(launchOptions: launchOptions)
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    
    // MARK: - Pay callback
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
            })
        }
        
        return true
    }
    
    // MARK: - Share
    private func registerShare() {
        let shareAppKey = "1e9aa2d08bba3"
        let nyatourl = "http://nyato.com"
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
                //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                appInfo?.ssdkSetupSinaWeibo(byAppKey: "3026246088",
                                            appSecret: "beb7d09137b4bb35e83f67caf04c48ce",
                                            redirectUri : nyatourl,
                                            authType : SSDKAuthTypeBoth)
            case SSDKPlatformType.typeWechat:
                appInfo?.ssdkSetupWeChat(byAppId: "wxeb0f70c7821904f6",
                                         appSecret: "90c169dfaee46efe8c63123fa38bb326")
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


// MARK: - Home sceen quick action
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


// MARK: - APNs
extension AppDelegate: JPUSHRegisterDelegate {
    
    // App not running
    fileprivate func handleAPNsIfNeeded(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            if let aps = notification["aps"] as? [String: AnyObject] {
                if let urlString = aps["link_url"] as? String,
                    let url = URL(string: urlString) {
                    let webViewController = createWebViewController(with: url, title: "查看内容 launch")
                    
                    ((window?.rootViewController as? TabBarViewController)?.selectedViewController as? UINavigationController)?.pushViewController(webViewController, animated: true)
                }
                
            }
        }
    }
    
    fileprivate func registerJPush(with launchOptions: [UIApplicationLaunchOptionsKey: Any]!) {
        let entity = JPUSHRegisterEntity()
        entity.types = Int(JPAuthorizationOptions.alert.rawValue | JPAuthorizationOptions.badge.rawValue | JPAuthorizationOptions.sound.rawValue)
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        
        JPUSHService.setup(withOption: launchOptions,
                           appKey: "80007dd9f0a3f42bd27c9cd2",
                           channel: "Publish channel",
                           apsForProduction: false,
                           advertisingIdentifier: nil)
        JPUSHService.registrationIDCompletionHandler { (resCode, resID) in
            if resCode == 0 {  // success
                if #available(iOS 10.0, *) {
                    let viewAction = UNNotificationAction(identifier: viewActionIdentifier,
                                                          title: "查看",
                                                          options: [.foreground])
                    let newCategory = UNNotificationCategory(identifier: newsCategoryIdentifier,
                                                             actions: [viewAction],
                                                             intentIdentifiers: [],
                                                             options: [])
                    UNUserNotificationCenter.current().setNotificationCategories([newCategory])
                } else {
                    // Fallback on earlier versions
                }
            } else {
                print("set jpush error, resCode: \(resCode)")
            }
        }
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailToRegisterForRemoteNotificationsWithError: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("===== didReceiveRemoteNotification")
        
        JPUSHService.handleRemoteNotification(userInfo)
        
        let aps = userInfo["aps"] as! [String: AnyObject]
        
        if let urlString = aps["link_url"] as? String,
            let url = URL(string: urlString) {
            let webViewController = createWebViewController(with: url, title: "查看内容 application")
            
            ((window?.rootViewController as? TabBarViewController)?.selectedViewController as? UINavigationController)?.pushViewController(webViewController, animated: true)
        }
        
        completionHandler(.newData)
    }
    
    // JPush delegate
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        print("=====Center, willPresent")
        let userInfo = notification.request.content.userInfo
        
        let aps = userInfo["aps"] as! [String: AnyObject]
        
        // response.actionIdentifier == viewActionIdentifier
        if let urlString = aps["link_url"] as? String,
            let url = URL(string: urlString) {
            let webViewController = createWebViewController(with: url, title: "查看内容 Center Will")
            
            ((window?.rootViewController as? TabBarViewController)?.selectedViewController as? UINavigationController)?.pushViewController(webViewController, animated: true)
        }
        
        
        let type = Int(JPAuthorizationOptions.alert.rawValue | JPAuthorizationOptions.badge.rawValue | JPAuthorizationOptions.sound.rawValue)
        
        completionHandler(type)
    }
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        let userInfo = response.notification.request.content.userInfo
        
        print("=====Center, didReceive")
        
        let aps = userInfo["aps"] as! [String: AnyObject]
        
        // response.actionIdentifier == viewActionIdentifier
        if let urlString = aps["link_url"] as? String,
            let url = URL(string: urlString) {
            let webViewController = createWebViewController(with: url, title: "查看内容 Center Did")
            
            ((window?.rootViewController as? TabBarViewController)?.selectedViewController as? UINavigationController)?.pushViewController(webViewController, animated: true)
        }
        
        completionHandler()
    }
    
    private func createWebViewController(with url: URL, title: String) -> WebViewController {
        let webViewController = WebViewController()
        webViewController.automaticallyAdjustsScrollViewInsets = false
        webViewController.view.frame = UIScreen.main.bounds
        webViewController.url = url
        webViewController.webTitle = title
        webViewController.hidesBottomBarWhenPushed = true
        
        return webViewController
    }
}



