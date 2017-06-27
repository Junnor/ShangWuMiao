//
//  MeViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/9.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
import SVProgressHUD

class MeViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 在Group模式下隐藏头部空白区域
        tableView.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMcoins), name: nyatoMcoinsChange, object: nil)
        
        meVendor = User.shared.vendorType != Vendor.none
        
        // User check with first load
        userCheck()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 解决9.0以下在从充值列表回退一些cell高度不对的bug
        self.tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func reloadMcoins() {
        self.tableView.reloadData()
    }
        
    // MARK: - Navigation 
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == SegueIdentifer.topUpRecord {
            } else if identifier == SegueIdentifer.delegate {
            } else if identifier == SegueIdentifer.feedback {
            } else if identifier == SegueIdentifer.sold {
            } else if identifier == SegueIdentifer.topUpAction {
            }
        }
    }
    
    // MARK: - Helper
    private func userCheck() {
        User.userCheck { (isUserValid, info) in
            if !isUserValid {
                SVProgressHUD.showError(withStatus: info)
            }
        }
    }
    
    // MARK: - Private 
    fileprivate var meVendor = true
    
    fileprivate enum Identifer: String {
        case avatar = "avatarCellIdentifier"
        case money = "moneyCellIdentifier"
        case detail = "detailCellIdentifier"
    }

    fileprivate struct TitleText {
        static let sold = "已售出门票"
        static let topUpRecord = "充值记录"
        static let feedback = "问题反馈"
        static let delegate = "代理售票相关"
        
        static let signOut = "退出账号"
    }

    fileprivate struct SegueIdentifer {
        static let sold = "ticket sold"
        static let topUpRecord = "top up record"
        static let feedback = "feedback"
        static let delegate = "ticket delegate"

        static let topUpAction = "top up action"
    }

    fileprivate enum VendorSegueEnum: Int {
        case sold =  0
        case topUpRecord
        case feedback
        case delegate
    }
    
    fileprivate enum NoneVendorSegueEnum: Int {
        case feedback = 0
        case delegate = 1
    }

}

// MARK: - Table view data source & delegate

extension MeViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return meVendor ? 2 : 1
        } else if section == 1 {
            return meVendor ? 4 : 2
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // identifier
        var identifer = Identifer.detail.rawValue
        if indexPath.section == 0 {
            identifer = indexPath.row == 0 ? Identifer.avatar.rawValue : Identifer.money.rawValue
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifer, for: indexPath)
        cell.selectionStyle = .none
        
        // text and text color
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if let cell = cell as? MeCell {
                    let width = cell.avatarImageView.frame.width
                    cell.avatarImageView.layer.cornerRadius = width / 2
                    cell.avatarImageView.layer.masksToBounds = true
                    if let url = URL(string: User.shared.avatarString) {
                        let resource = ImageResource(downloadURL: url,
                                                     cacheKey: url.absoluteString)
//                        cell.avatarImageView?.kf.setImage(with: resource)
                        cell.avatarImageView.kf.setImage(with: resource,
                                                         placeholder: nil,
                                                         options: nil,
                                                         progressBlock: nil,
                                                         completionHandler: {
                                                            (image, _, _, _) in
                                                            User.shared.avatar = image
                        })
                    }
                    
                    cell.avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editProfile)))
                    cell.avatarImageView.isUserInteractionEnabled = true
                    
                    cell.usernameLabel?.text = User.shared.uname
                    cell.levelLabel?.text = User.shared.vendorType
                }
            } else {
                let cell = cell as! MoneyCell
                cell.moneyLabel?.text = "\(User.shared.mcoins)"
            }
        } else {
            let cell = cell as! DetailCell
            if indexPath.section == 1 {
                var text = ""
                if meVendor {
                    if let se = VendorSegueEnum(rawValue: indexPath.row) {
                        switch se {
                        case .sold: text = TitleText.sold
                        case .topUpRecord: text = TitleText.topUpRecord
                        case .feedback: text = TitleText.feedback
                        case .delegate: text = TitleText.delegate
                       
                        }
                    }
                } else {
                    if let se = NoneVendorSegueEnum(rawValue: indexPath.row) {
                        switch se {
                        case .feedback: text = TitleText.feedback
                        case .delegate: text = TitleText.delegate
                        }
                    }
                }
                    
                cell.titleLabel.text = text
                cell.titleLabel.textColor = UIColor.black
           
            } else {
                cell.titleLabel.text = TitleText.signOut
                cell.titleLabel.textColor = UIColor.red
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.section == 0 && indexPath.row == 0) ? 180 : 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                performSegue(withIdentifier: SegueIdentifer.topUpAction, sender: indexPath)
            }
        } else if indexPath.section == 1 {
            var identififer = String()
            
            if meVendor {
                if let segueE = VendorSegueEnum(rawValue: indexPath.row) {
                    switch segueE {
                    case .sold: identififer = SegueIdentifer.sold
                    case .topUpRecord: identififer = SegueIdentifer.topUpRecord
                    case .feedback: identififer = SegueIdentifer.feedback
                    case .delegate: identififer = SegueIdentifer.delegate
                    }
                }
            } else {
                if let segueE = NoneVendorSegueEnum(rawValue: indexPath.row) {
                    switch segueE {
                    case .feedback: identififer = SegueIdentifer.feedback
                    case .delegate: identififer = SegueIdentifer.delegate
                    }
                }
            }

            performSegue(withIdentifier: identififer, sender: indexPath)
        } else {
            let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "LoginViewController")
            
            if let loginvc = vc as? LoginViewController {
                let navivc = UINavigationController(rootViewController: loginvc)
                present(navivc, animated: true, completion: {
                    User.shared.clean()
                })
            }
        }
    }
    
    // MARK: - Helper
    @objc private func editProfile() {
        performSegue(withIdentifier: "EditProfile", sender: nil)
    }
    
}
