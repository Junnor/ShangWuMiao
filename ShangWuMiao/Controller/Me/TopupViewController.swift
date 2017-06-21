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
import Alamofire

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
    
    // alipay + wecaht pay + apple pay (if available)
    fileprivate var numberOfPayChoice = 2
    fileprivate let topupIdentifier = "top up identifier"
    fileprivate let applePayIdentifier = "Apple Pay"
    
    fileprivate var addedPayButton = false
    
    // For Apple pay
    fileprivate var tn: String!
    // "00" for distrubution, "01" for testing
    fileprivate let mode = "01"     // TODO: replace
    fileprivate let nyatoMerchantID = "merchant.com.example.merchantname.ts"    // TODO: replace
    fileprivate var payNetworks = [PKPaymentNetwork]()


    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberOfPayChoice = isApplePayAvailable() ? 3 : 2

        title = "充值喵币"
        mcoinsLabel?.text = "\(User.shared.mcoins)"
        NotificationCenter.default.addObserver(self, selector: #selector(refreshMcoins), name: nyatoMcoinsChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Helper
    
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
        return numberOfPayChoice
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellId = topupIdentifier
        
        if isApplePayAvailable() {
            cellId = (indexPath.row == (numberOfPayChoice - 1)) ? applePayIdentifier : topupIdentifier
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier:cellId, for: indexPath)
        cell.selectionStyle = .none
        if let cell = cell as? TopupCell {
            var image = #imageLiteral(resourceName: "pay-wenxin")
            var text = "使用微信支付"
            if indexPath.row == 0 {
                image = #imageLiteral(resourceName: "pay-alipay")
                text = "使用支付宝支付"
            }
            cell.payImageView?.image = image
            cell.titleLabel?.text = text
            
        } else if let cell = cell as? ApplePayCell {
            if #available(iOS 8.3, *) {
                if !addedPayButton {
                    addedPayButton = true
                    
                    let payButton = PKPaymentButton(type: .plain, style: .whiteOutline)
                    
                    cell.applyPayView.backgroundColor = UIColor.clear
                    payButton.frame = cell.applyPayView.frame
                    cell.contentView.addSubview(payButton)
                }

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
        } else if indexPath.row == 1 { // Wechat pay
            // Float(currentMcoinsCount)
            UserPay.pay(withType: Pay.wechat,
                        orderPrice: Float(1),
                        completionHandler: { [weak self] (success, info) in
                            if success {
                                print("wechat pay.....")
                                self?.wechatAction()
                            } else {
                                SVProgressHUD.showError(withStatus: info!)
                                print("wehcat pay failure: \(info!)")
                            }
                            
            })

        } else {  // Apple pay
            applePay()
        }
    }

}

// MARK: - Apple Pay

extension TopupViewController: UPAPayPluginDelegate {
    
    // MARK: UPAPay Delegate
    func upaPayPluginResult(_ payResult: UPPayResult!) {
        if let status = payResult?.paymentResultStatus {
            switch status {
            case .success:
                print("success")
                let otherInfo = payResult.otherInfo ?? ""
                let successInfo = "支付成功\n\(otherInfo)"
                showAlert(successInfo)
            case .failure:
                print("failure")
                let errorInfo = payResult.errorDescription ?? "支付失败"
                showAlert(errorInfo)
            case .cancel:
                print("cancel")
                showAlert("支付取消")
            case .unknownCancel:
                print("unknownCancel")
                let errorInfo = ""
                // TODO: get [errorInfo] from server, may success or failure
                showAlert(errorInfo)
            }
        }
    }

    // MARK: - Helper
    
    fileprivate func isApplePayAvailable() -> Bool {
        var available = false
        
        // 需要银联
        if #available(iOS 9.2, *) {
            if PKPaymentAuthorizationViewController.canMakePayments() {
                payNetworks = [.chinaUnionPay]
                available = true
            }
        } else {
            // Fallback on earlier versions
        }

        return available
    }
    
    
    @objc fileprivate func applePay() {
        // Check whether the network is support
        if !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: payNetworks) {
            let msg = "当前设备没有包含支持的支付银联卡, 你可以到 Wallet 应用添加银联卡"
            showAlert(msg)
            return
        }
        
        // Get TN
        fetchTransactionNumber { [weak self] tnResult in
            if tnResult != nil {
                self?.tn = tnResult
                self?.tnPay()
            }
        }
    }
    
    private func tnPay() {
        if tn != nil && tn.characters.count > 0 {
            UPAPayPlugin.startPay(tn,
                                  mode: mode,
                                  viewController: self,
                                  delegate: self,
                                  andAPMechantID: nyatoMerchantID)
        } else {
            showAlert("获得交易单号失败")
        }
    }

    private func fetchTransactionNumber(callbacK: @escaping (_ tn: String?) -> ()) {
        // TODO: replace
        if let url = URL(string: "http://101.231.204.84:8091/sim/getacptn") {
            Alamofire.request(url,
                              method: .post,
                              parameters: nil,
                              encoding: URLEncoding.default,
                              headers: nil).responseJSON { response in
                                switch response.result {
                                case .success(let data):
                                    let str = String(describing: data)
                                    callbacK(str)
                                case .failure(let error):
                                    print("Fetch TN error: \(error)")
                                }
                                
            }
        }
    }
    
    private func showAlert(_ info: String) {
        let alert = UIAlertController(title: "提示", message: info, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Alipay

fileprivate extension TopupViewController {
    fileprivate func alipayAction() {
        AlipaySDK.defaultService().payOrder(UserPay.shared.alipay_sign_str,
                                            fromScheme: kAlipaySchema,
                                            callback: { response in    // 没有支付宝客户端的回调
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
