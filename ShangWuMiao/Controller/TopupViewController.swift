//
//  TopupViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/9.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON
import PassKit

class TopupViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.alwaysBounceVertical = true
        }
    }
    
    @IBOutlet weak var mcoinsLabel: UILabel!
    @IBOutlet weak var mcoinsSumLabel: UILabel!
    @IBOutlet weak var sumIndicatorLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.isScrollEnabled = false
            tableView.backgroundColor = UIColor.clear
            tableView.separatorStyle = .none
        }
    }
    
    fileprivate let numberOfChoice = 2
    fileprivate let topupIdentifier = "top up identifier"
    fileprivate let applePayIdentifier = "Apple Pay"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "充值喵币"

        mcoinsLabel?.text = "\(User.shared.mcoins)"
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshMcoins), name: nyatoMcoinsChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func refreshMcoins() {
        mcoinsLabel?.text = "\(User.shared.mcoins)"
    }
    
    fileprivate var currentMcoinsCount = 10 {
        didSet {
            mcoinsSumLabel?.text = "\(currentMcoinsCount)"
            sumIndicatorLabel?.text = "\(currentMcoinsCount)"
        }
    }
    
    @IBAction func mcoinsHundredPlusAction(_ sender: Any) {
        currentMcoinsCount += 100
    }

    @IBAction func mcoinsTenPlusAction(_ sender: Any) {
        currentMcoinsCount += 10
    }
    
    @IBAction func mcoinsMinusAction(_ sender: Any) {
        if currentMcoinsCount == 10 {
            return
        } else {
            currentMcoinsCount -= 10
        }
    }
}

// MARK: - Table view data source & delegate
extension TopupViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfChoice
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = (indexPath.row == 0) ? topupIdentifier : applePayIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier:cellId, for: indexPath)
        cell.selectionStyle = .none
        if let cell = cell as? TopupCell {
            cell.payImageView?.image = #imageLiteral(resourceName: "pay-alipay")
            cell.titleLabel?.text = "使用支付宝支付"
            
        } else if let cell = cell as? ApplePayCell {
            if #available(iOS 8.3, *) {
                for subview in cell.applyPayView.subviews {
                    subview.removeFromSuperview()
                }
                let payButton = PKPaymentButton(type: .plain, style: .white)
                payButton.frame = cell.applyPayView.bounds
                cell.applyPayView.backgroundColor = UIColor.white
                cell.applyPayView.addSubview(payButton)
                cell.applyPayView.clipsToBounds = true
            } else {
                // Fallback on earlier versions
            }
            cell.titleLabel.text = "Apple Pay"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {   // alipay
            UserPay.pay(withType: Pay.alipay,
                        orderPrice: Float(currentMcoinsCount),
                        completionHandler: { [weak self] (success, info) in
                            if success {
                                self?.alipayAction()
                            } else {
                                SVProgressHUD.showError(withStatus: info!)
                                print("alipay pay failure: \(info!)")
                            }
            })
        } else if indexPath.row == 1 { // Apple pay
            // pay
            
        } else {  // wechat
            
            // TODO: Hidden Hidden Hidden Hidden Hidden Hidden Hidden
            /*
             isWechat = true
             // Float(currentMcoinsCount)
             UserPay.pay(withType: Pay.wechat,
             orderPrice: Float(1),
             completionHandler: { [weak self] (success, info) in
             if success {
             print("pay.....")
             self?.wechatAction()
             } else {
             SVProgressHUD.showError(withStatus: info!)
             print("wehcat pay failure: \(info!)")
             }
             
             })
             */
        }
    }

}

// Apple Pay

fileprivate extension TopupViewController {
}

// MARK: - Alipay

fileprivate extension TopupViewController {
    fileprivate func alipayAction() {
        AlipaySDK.defaultService().payOrder(UserPay.shared.alipay_sign_str,
                                            fromScheme: kAlipaySchema,
                                            callback: { response in
                                                let json = JSON(response as Any)
                                                let status = json["resultStatus"].intValue
                                                //                                                print(".... source application json: \(json)")
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
    }

}

// MARK: - Wechat pay
/*
fileprivate extension TopupViewController {
    fileprivate func wechatAction() {
        let payReq = PayReq()
        payReq.openID = UserPay.shared.appid
        payReq.partnerId = UserPay.shared.partnerid
        payReq.prepayId = UserPay.shared.prepayid
        payReq.package = UserPay.shared.package
        payReq.nonceStr = UserPay.shared.noncestr
        payReq.timeStamp = UserPay.shared.timestamp
        payReq.sign = UserPay.shared.wechat_sign_str
        
        WXApi.send(payReq)
    }
}
 */
