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

class MeViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 在Group模式下隐藏头部空白区域
        tableView.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMcoins), name: nyatoMcoinsChange, object: nil)
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
            if let segueIdentifer = SegueIdentifer(rawValue: identifier) {
                switch segueIdentifer {
                case .topUpAction:
                    print("..top up")
                case .ticketSold:
                    print(".. sold")
                case .topUpRecord:
                    print(".. top up record")
                case .feedback:
                    print(".. feedback")
                case .ticketDelegate:
                    print("...ticket delegate")
                }
            }
        }
    }
    
    // MARK: - Private 
    
    fileprivate enum Identifer: String {
        case avatar = "avatarCellIdentifier"
        case money = "moneyCellIdentifier"
        case detail = "detailCellIdentifier"
    }

    fileprivate enum TitleText: String {
        case sold = "已售出门票"
        case topUp = "充值记录"
        case feedback = "问题反馈"
        case delegate = "代理售票相关"
        case signOut = "退出账号"
    }

    fileprivate enum SegueIdentifer: String {
        case ticketDelegate = "ticket delegate"
        case feedback = "feedback"
        case topUpRecord = "top up record"
        case ticketSold = "ticket sold"
        case topUpAction = "top up action"
    }

}

// MARK: - Table view data source & delegate

extension MeViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else if section == 1 {
            return 4
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
                        
                        cell.avatarImageView?.kf.setImage(with: resource)
                    }
                    
                    cell.usernameLabel?.text = User.shared.uname
                    cell.levelLabel?.text = User.shared.isBusiness
                }
            } else {
                let cell = cell as! MoneyCell
                cell.moneyLabel?.text = "\(User.shared.mcoins)"
            }
        } else {
            let cell = cell as! DetailCell
            if indexPath.section == 1 {
                var text = ""
                switch indexPath.row {
                case 0: text = TitleText.sold.rawValue
                case 1: text = TitleText.topUp.rawValue
                case 2: text = TitleText.feedback.rawValue
                case 3: text = TitleText.delegate.rawValue
                default: break
                }
                cell.titleLabel.text = text
                cell.titleLabel.textColor = UIColor.black
            } else {
                cell.titleLabel.text = TitleText.signOut.rawValue
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
                performSegue(withIdentifier: SegueIdentifer.topUpAction.rawValue, sender: indexPath)
            }
        } else if indexPath.section == 1 {
            var identififer = String()
            switch indexPath.row {
            case 0: identififer = SegueIdentifer.ticketSold.rawValue
            case 1: identififer = SegueIdentifer.topUpRecord.rawValue
            case 2: identififer = SegueIdentifer.feedback.rawValue
            case 3: identififer = SegueIdentifer.ticketDelegate.rawValue
            default: break
            }
            performSegue(withIdentifier: identififer, sender: indexPath)
        } else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
            
            if let loginvc = vc as? LoginViewController {
                let navivc = UINavigationController(rootViewController: loginvc)
                present(navivc, animated: true, completion: {
                    User.shared.clean()
                })
            }
        }
    }
    
}
