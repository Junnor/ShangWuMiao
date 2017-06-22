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
        
        // Set navigation bar appearance and back title
        let barAppearance = UINavigationBar.appearance()
        barAppearance.tintColor = UIColor.white
        barAppearance.barTintColor = UIColor.barTintColor
        barAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UITabBar.appearance().tintColor = UIColor.themeYellow
        
        // Share and login with third party [ShareSDK]
        registerShare()
        
        // Apple push notification service, use the third party [JPush]
        registerJPush(with: launchOptions)
        
        // Set different window root view controller
        if UserDefaults.standard.value(forKeyPath: isLogin) != nil {
            if let tabvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarViewController") as? TabBarViewController {
                window?.rootViewController = tabvc
            }
        }
        
        // Check APNs, just need to do with the platform which prior iOS 10
        if #available(iOS 10.0, *) {
            // When iOS platform is iOS, the UNUserNotificationCennter will handle it
        } else {
            handleAPNsIfNeeded(launchOptions: launchOptions)
        }
        
        // Statistics, use the thrid party [Countly]
        let countlyConfig = CountlyConfig()
        countlyConfig.appKey = "78df730eb3e4785ee47721a2da25d5ce1fff40e2"
        countlyConfig.host = "https://appanalytics.nyato.com"
        countlyConfig.features = [CLYPushNotifications, CLYCrashReporting, CLYAutoViewTracking]

        Countly.sharedInstance().start(with: countlyConfig)
                
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        
        isPrioriOS10APNsUseCustomBannerNow = hasEnteredBackground ? false : true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        hasEnteredBackground = true
    }
    
    // MARK: - Pay callback
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.host == "safepay" {   // 有支付宝客户端情况
            AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: { response in
                let json = JSON(response as Any)
                let status = json["resultStatus"].intValue
                
                UserPay.shared.paySuccess = (status == 9000) ? true : false
                
                // tell database
                if  status == 9000 {
                    NotificationCenter.default.post(name: alipaySuccess, object: nil)

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
        } else if url.scheme == nyatoWechatAppId {
            return WXApi.handleOpen(url, delegate: self)
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
                appInfo?.ssdkSetupQQ(byAppId: "1106143355",
                                     appKey: "9hislwXqqUdRiPp2",
                                     authType: SSDKAuthTypeSSO)
            case SSDKPlatformType.subTypeQZone:
                appInfo?.ssdkSetupQQ(byAppId: "1106143355",
                                     appKey: "9hislwXqqUdRiPp2",
                                     authType: SSDKAuthTypeSSO)
            default:
                break
            }
        }
    }
    
    // MARK: - Properties for APNs in forground (used in custom banner)
    fileprivate var hasEnteredBackground = false
    fileprivate var isPrioriOS10APNsUseCustomBannerNow = true
    fileprivate var isFromLaunch = false
    fileprivate var customBannerUrl: URL!
    fileprivate var customBanner: (bannerView: BannerView, startFrame: CGRect, finalFrame: CGRect)!
    fileprivate var bannerShowSeconds = 5
    fileprivate var bannerTimer: Timer!
    // --------------------------------------

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


// MARK: - Apple Push Notificaiton service (APNs)

extension AppDelegate: JPUSHRegisterDelegate {
    
    // MARK: - Register and recieve stuff

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
    
    fileprivate func handleAPNsIfNeeded(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            if let aps = notification["aps"] as? [String: AnyObject] {
                if let urlString = aps["link_url"] as? String,
                    let url = URL(string: urlString) {
                    isFromLaunch = true
                    let webViewController = createWebViewController(with: url, title: "查看内容 launch")
                    // Important, or selectedViewController will be nil
                    (window?.rootViewController as? TabBarViewController)?.selectedIndex = 0
                    ((window?.rootViewController as? TabBarViewController)?.selectedViewController as? UINavigationController)?.pushViewController(webViewController, animated: true)
                }
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
        print("===== did Receive Remote Notification")
        
        JPUSHService.handleRemoteNotification(userInfo)
        
        if #available(iOS 10.0, *) {
            // Handle notification by UNUserNotificationCenterDelegate
        } else {
            let aps = userInfo["aps"] as! [String: AnyObject]

            if let urlString = aps["link_url"] as? String,
                let url = URL(string: urlString) {
                
                print("isPrioriOS10APNsUseCustomBannerNow = \(isPrioriOS10APNsUseCustomBannerNow), and isFromLaunch = \(isFromLaunch)")
                
                if isPrioriOS10APNsUseCustomBannerNow  {
                    // Foreground called
                    if !isFromLaunch {
                        customBannerUrl = url
                        
                        customBanner?.bannerView.removeFromSuperview()
                        customBanner = nil
                        invalidBannerTimer()
                        
                        let banner = createBannerView(withPush: "Some infomation about the apns, and url: \(url)")
                        customBanner = banner
                        
                        window?.addSubview(customBanner.bannerView)
                        window?.bringSubview(toFront:customBanner.bannerView)
                        
                        UIView.animate(withDuration: 1.0, animations: {
                            self.customBanner.bannerView.frame = banner.finalFrame
                        }, completion: nil)
                        
                        fireBannerTimer()
                    }
                    isFromLaunch = false
                } else {
                    // Background called
                    let webViewController = createWebViewController(with: url, title: "查看内容 didReceiveRemoteNotification")
                    
                    ((window?.rootViewController as? TabBarViewController)?.selectedViewController as? UINavigationController)?.pushViewController(webViewController, animated: true)
                    
                    isPrioriOS10APNsUseCustomBannerNow = true
                }
            }

        }        
        completionHandler(.newData)
    }
    
    
    // MARK: - Custom banner view
    
    private func fireBannerTimer() {
        bannerTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                          target: self,
                                          selector: #selector(validBanner),
                                          userInfo: nil,
                                          repeats: true)
        bannerTimer.fire()
    }
    
    private func invalidBannerTimer() {
        bannerShowSeconds = 5
        bannerTimer?.invalidate()
    }
    
    @objc private func validBanner() {
        bannerShowSeconds -= 1
        
        if bannerShowSeconds == 0 {
            invalidBannerTimer()
            swipeCustomBannerToClosed()
        }
    }

    private func createBannerView(withPush text: String) -> (bannerView: BannerView, startFrame: CGRect, finalFrame: CGRect) {
        let bannerView = Bundle.main.loadNibNamed("BannerView",
                                                  owner: nil,
                                                  options: [:])?.first as! BannerView
        let width =  UIScreen.main.bounds.width - 20
        let textWidth = width - 20
        let rect = NSString(string: text).boundingRect(with: CGSize(width:textWidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
        
        let textHeight = ceil(rect.height)
        let propmtHeight: CGFloat = 30
        let height = textHeight + propmtHeight
        
        let startFrame = CGRect(x: 10, y: -100, width: width, height: height)
        let finalFrame = CGRect(x: 10, y: 20, width: width, height: height)
        
        bannerView.frame = startFrame
        bannerView.bannerLabel.text = text
        
        bannerView.layer.cornerRadius = 20
        bannerView.clipsToBounds = true
        
        bannerView.backgroundColor = UIColor.themeYellow
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(openCustomBannerViewContent))
        bannerView.addGestureRecognizer(tap)
        
        let swipeUp = UISwipeGestureRecognizer(target: self,
                                               action: #selector(swipeCustomBannerToClosed))
        swipeUp.direction = .up
        bannerView.addGestureRecognizer(swipeUp)
        
        return (bannerView, startFrame, finalFrame)
    }
    
    @objc private func swipeCustomBannerToClosed() {
        
        UIView.animate(withDuration: 0.5,
                       animations: {
                        self.customBanner.bannerView.frame = self.customBanner.startFrame
        },
                       completion: { (_) in
                        self.invalidBannerTimer()
                        self.customBanner?.bannerView.removeFromSuperview()
                        self.customBanner = nil
        })
    }
    
    @objc private func openCustomBannerViewContent() {
        invalidBannerTimer()
        customBanner?.bannerView.removeFromSuperview()
        customBanner = nil
        
        let webViewController = createWebViewController(with: customBannerUrl,
                                                        title: "查看内容 Banner")
        
        ((window?.rootViewController as? TabBarViewController)?.selectedViewController as? UINavigationController)?.pushViewController(webViewController, animated: true)
    }
    
    // WebViewConroller
    private func createWebViewController(with url: URL, title: String) -> WebViewController {
        let webViewController = WebViewController()
        webViewController.automaticallyAdjustsScrollViewInsets = false
        webViewController.view.frame = UIScreen.main.bounds
        webViewController.url = url
        webViewController.webTitle = title
        webViewController.hidesBottomBarWhenPushed = true
        
        return webViewController
    }

    // MARK: - JPush delegate, for iOS 10
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        print("=====Center, willPresent")
        
        // completion handler
        let type = Int(JPAuthorizationOptions.alert.rawValue | JPAuthorizationOptions.badge.rawValue | JPAuthorizationOptions.sound.rawValue)
        completionHandler(type)
    }
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        print("=====Center, didReceive")
        
        let userInfo = response.notification.request.content.userInfo
        let aps = userInfo["aps"] as! [String: AnyObject]
        
        // response.actionIdentifier == viewActionIdentifier
        if let urlString = aps["link_url"] as? String,
            let url = URL(string: urlString) {
            let webViewController = createWebViewController(with: url, title: "查看内容 Center Did")
            
            ((window?.rootViewController as? TabBarViewController)?.selectedViewController as? UINavigationController)?.pushViewController(webViewController, animated: true)
        }
        
        completionHandler()
    }
}

// MARK: - Wechat Api Delegate

extension AppDelegate: WXApiDelegate {
    
    func onResp(_ resp: BaseResp!) {
        switch resp.errCode {
        case 0:
            NotificationCenter.default.post(name: wechatPaySuccess, object: nil)
        default: break
        }
    }
}


