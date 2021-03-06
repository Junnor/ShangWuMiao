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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
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
            var telephone = "未绑定"
            if let mobile = User.shared.telephone {
                telephone = mobile
            }
            cell.detailTextLabel?.text = telephone
        } else if indexPath.row == 1 {
            var email = "未绑定"
            if let value = User.shared.email {
                email = value
            }
            cell.detailTextLabel?.text = email
        }

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "账号设置"
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {   // Unbind telephone
            if let _ = User.shared.telephone {
                unbindTelephone()
            } else {  // Bind telephone
                performSegue(withIdentifier: "bindTelephone", sender: nil)
            }
        } else if indexPath.row == 1 {   // Unbind email
            if let _ = User.shared.email {
                SVProgressHUD.showInfo(withStatus: "已经绑定邮箱")
            } else {  // Bind email
                bindEmail()
            }
        } else if indexPath.row == 2 {   // reset password
            performSegue(withIdentifier: "meResetPassword", sender: nil)
        }
    }
 
    
    // MARK: - Helper
    
    private var unbindPassword: String = ""
    private func unbindTelephone() {
        
        func sendUnbindTelephoneRequest() {
            User.unbindTelephone(unbindPassword) { (success, info) in
                SVProgressHUD.showInfo(withStatus: info)
                if success {
                    User.shared.telephone = nil
                    self.unbindPassword = ""
                    self.tableView.reloadData()
                }
            }
        }
        
        let alert = UIAlertController(title: "解除手机绑定",
                                      message: "输入账号密码就可以解除手机绑定更换手机绑定啦，记得重新绑定账号哦",
                                      preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "请输入您的账号密码"
            textField.isSecureTextEntry = true
        }
        let ok = UIAlertAction(title: "解除绑定", style: .destructive) { (action) in
            if let password = alert.textFields?.first?.text {
                if password == "" {
                    SVProgressHUD.showInfo(withStatus: "密码为空")
                } else {
                    self.unbindPassword = password
                    sendUnbindTelephoneRequest()
                }
            }
        }
        
        let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    private var email: String = ""
    private func bindEmail() {
        
        func sendBindEmailRequest() {
            User.bindEmail(email) { [weak self] (success, info) in
                
                SVProgressHUD.showInfo(withStatus: info)
                if success {
                    User.shared.email = self?.email
                    self?.tableView.reloadData()
                }
            }
        }
        
        let alert = UIAlertController(title: "绑定邮箱",
                                      message: "输入邮箱地址，提交即可绑定邮箱。记得打开邮箱激活绑定哦",
                                      preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "请输入您的邮箱"
        }
        let ok = UIAlertAction(title: "确定绑定", style: .destructive) { [weak self] (action) in
            if let email = alert.textFields?.first?.text {
                if email == "" {
                    SVProgressHUD.showInfo(withStatus: "邮箱为空")
                } else {
                    self?.email = email
                    let innerAlert = UIAlertController(title: "确认邮箱",
                                                       message: "请确认您的邮箱：\(email) 是否正确",
                        preferredStyle: .alert)
                    let ok = UIAlertAction(title: "确定绑定", style: .destructive) { (action) in
                        sendBindEmailRequest()
                    }
                    let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
                    innerAlert.addAction(cancel)
                    innerAlert.addAction(ok)
                    self?.present(innerAlert, animated: true, completion: nil)
                }
            }
        }
        
        let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
}
