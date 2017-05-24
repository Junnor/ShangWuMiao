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
        }
    }
    
    fileprivate let topupIdentifier = "top up identifier"

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
    
    fileprivate func alipayAction() {
        print("alipayAction")
        AlipaySDK.defaultService().payOrder(UserPay.shared.alipay_sign_str,
                                            fromScheme: kAlipaySchema,
                                            callback: { response in
                                                let json = JSON(response as Any)
                                                let status = json["resultStatus"].intValue
                                                print(".... source application json: \(json)")
                                                
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
                                                print("alipay payOrder call back = \(String(describing: response))")
        })
    }
    
    /*       Not used yet
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
     */
    
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

extension TopupViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:topupIdentifier, for: indexPath)
        cell.selectionStyle = .none
        if let cell = cell as? TopupCell {
            cell.payImageView?.image = #imageLiteral(resourceName: "pay-alipay")
            cell.titleLabel?.text = "使用支付宝支付"
            
        }
        return cell
    }
}

extension TopupViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {   // alipay
            print("UserPay pay ")

            UserPay.pay(withType: Pay.alipay,
                        orderPrice: Float(1),
                        completionHandler: { [weak self] (success, info) in
                            if success {
                                self?.alipayAction()
                            } else {
                                SVProgressHUD.showError(withStatus: info!)
                                print("alipay pay failure: \(info!)")
                            }
            })
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
