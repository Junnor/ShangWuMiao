//
//  AppDelegate.swift
//  ShangWuMiao
//
//  Created by 赵辉 on 2017/4/10.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import SwiftyJSON


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // wechat register
        WXApi.registerApp(kAppId)
        
        // set different window root vc
        if UserDefaults.standard.value(forKeyPath: isLogin) != nil {
            if let tabvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarViewController") as? TabBarViewController {
                window?.rootViewController = tabvc
            }
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // pay callback
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.host == "safepay" {
            AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: { response in
                let json = JSON(response as Any)
                print("processOrder response: \(String(describing: json))")
                let status = json["resultStatus"].intValue

                UserPay.shared.paySuccess = status == 9000 ? true : false

                // tell database
                UserPay.payResult(tradeStatus: status, callback: { success, info in
                    if success {
                        print("... tell me succes")
                    } else {
                        print("... tell me failure: \(info!)")
                    }
                })
            })
            
            AlipaySDK.defaultService().processAuth_V2Result(url, standbyCallback: { response in
                print("processAuth_V2Result response: \(String(describing: response))")
                // TODO:
            })
        }
        
        return true
    }
}
