//
//  SettingViewController.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/16.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import SVProgressHUD

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
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 { // Bind telephone
        } else if indexPath.row == 1 {   // Bind email
            bindEmail()
        } else if indexPath.row == 2 {   // reset password
            performSegue(withIdentifier: "meResetPassword", sender: nil)
        }
    }
 
    
    // MARK: - Helper
    
    private func bindEmail() {
        let alert = UIAlertController(title: "绑定邮箱",
                                      message: "输入邮箱地址，提交即可绑定邮箱。记得打开邮箱激活绑定哦",
                                      preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "请输入您的邮箱"
        }
        let ok = UIAlertAction(title: "确定绑定", style: .destructive) { (action) in
            if let email = alert.textFields?.first?.text {
                if email == "" {
                    SVProgressHUD.showInfo(withStatus: "邮箱为空")
                } else {
                    let innerAlert = UIAlertController(title: "确认邮箱",
                                                       message: "请确认您的邮箱：\(email) 是否正确",
                        preferredStyle: .alert)
                    let ok = UIAlertAction(title: "确定绑定", style: .destructive) { (action) in
                        // TODO: fire
                    }
                    let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
                    innerAlert.addAction(cancel)
                    innerAlert.addAction(ok)
                    self.present(innerAlert, animated: true, completion: nil)
                }
            }
        }
        
        let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}
