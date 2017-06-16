//
//  SettingViewController.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/16.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private enum AccountSetting: String {
        case bindTelephone = "绑定手机"
        case bindEmail = "绑定邮箱"
        case resetPassword = "修改密码"
        
        static var count: Int {
            return 3
        }
        
        static var settingText: [Int: String] {
            return [0: "绑定手机",
                    1: "绑定邮箱",
                    2: "修改密码"]
        }
    }
    
    private let bindedTelephone = false
    private let bindedEmail = false


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AccountSetting.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // BasicCell: will add UISwitch, not used yet
        
        let indentifier = (indexPath.row == AccountSetting.count - 1) ? "IndicatorCell" : "DetailCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: indentifier, for: indexPath)
            
        cell.textLabel?.text = AccountSetting.settingText[indexPath.row]
        
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = bindedTelephone ? "已绑定" : "未绑定"
        } else if indexPath.row == 1 {
            cell.detailTextLabel?.text = bindedEmail ? "已绑定" : "未绑定"
        }

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "账号设置"
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            performSegue(withIdentifier: "meResetPassword", sender: nil)
        }
    }
 
}
