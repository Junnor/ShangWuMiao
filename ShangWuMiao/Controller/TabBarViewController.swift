//
//  TabBarViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/8.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import SVProgressHUD

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.setDefaultMaskType(.none)

        // 载入用户信息
        User.requestUserInfo(completionHandler: { (success, statusInfo) in
            if success {
            } else {
                SVProgressHUD.showInfo(withStatus: statusInfo)
                print("request user info failure: \(String(describing: statusInfo))")
            }
        })

    }
}
