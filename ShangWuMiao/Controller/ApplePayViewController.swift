//
//  ApplePayViewController.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/6.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import PassKit


// chinaUnionPay
@available(iOS 9.2, *)
class ApplePayViewController: UIViewController, UPAPayPluginDelegate {
    
    @IBOutlet weak var applePayButton: UIButton!
    @IBOutlet weak var applePayStatusLabel: UILabel!
    
    fileprivate var payRequest = PKPaymentRequest()
    fileprivate let nyatoMerchantID = "merchant.com.example.merchantname.ts"
    
    fileprivate let payNetworks: [PKPaymentNetwork] = [.chinaUnionPay]

    override func viewDidLoad() {
        super.viewDidLoad()

        applePayButton.setTitle("", for: .normal)
        let payButton = PKPaymentButton(type: .plain, style: .whiteOutline)
        view.addSubview(payButton)
        payButton.center = view.center
        applePayButton = payButton
        
        isApplePayAvailableCheck()
        

//        applePayButton.setTitle("Apple Pay", for: .normal)
        applePayButton.addTarget(self, action: #selector(applePay), for: .touchUpInside)
    }
    
    @objc private func applePay() {
        if !isCardAvailable() {
            return
        }
        tnPay()
        
    }
    
    private var tn: String!
    // "00" for distrubution, "01" for testing
    private let mode = "01"
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
    
    private func showAlert(_ info: String) {
        let alert = UIAlertController(title: "提示", message: info, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    
    private func isApplePayAvailableCheck() {
        
        var msg = "当前设备可正常使用Apple Pay"
        // Show or hide the apple pay button
        if !PKPaymentAuthorizationViewController.canMakePayments() {
            msg = "当前设备版本或系统不支持ApplePay"
            showAlert(msg)
        }
        applePayStatusLabel.text = msg
    }
    
    private func isCardAvailable() -> Bool {
        var available = true

        if !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: payNetworks) {
            let msg = "当前设备没有包含支持的支付银联卡, 你可以到 Wallet 应用添加银联卡"
            applePayStatusLabel.text = msg
            
            showAlert(msg)
            
            available = false
        }
        
        return available
    }

}

/*
@available(iOS 9.2, *)
extension ApplePayViewController: PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        
        // get: ajunct info if needed
        // get: payment.token
        // ... Send payment token, shipping and billing address, and order information to your server ...
        
        print("payment token = \(payment.token)")
        
        let msg = "当前设备可正常使用Apple Pay"
        applePayStatusLabel.text = msg + "transactionIdentifier: " + payment.token.transactionIdentifier

        // get status value from server
        let status: PKPaymentAuthorizationStatus = .success  // from server
        completion(status)
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // Helper
    private func configureWithRequest(_ request: PKPaymentRequest) {
        request.merchantIdentifier = nyatoMerchantID
        request.countryCode = "CN"
        request.currencyCode = "CNY"
        
        request.supportedNetworks = payNetworks
        
        request.merchantCapabilities = [.capability3DS, .capabilityCredit, .capabilityDebit, .capabilityEMV]
        
        // Order info
        let topupPrice = NSDecimalNumber(mantissa: 100, exponent: -2, isNegative: false)
        
        let topupItem = PKPaymentSummaryItem(label: "喵币充值", amount: topupPrice, type: .final)
        let totalItem = PKPaymentSummaryItem(label: "喵特", amount: topupPrice)
        
        request.paymentSummaryItems = [topupItem, totalItem]
    }
    
    
    // Not needed in nyato,,, just for testing
    private func shippingWithPaymentRequest(_ requst: PKPaymentRequest) {
        var name = PersonNameComponents()
        name.givenName = "Dengquan"
        name.familyName = "Zhu"
        
        let address = CNMutablePostalAddress()
        address.street = "Yangguang Street"
        address.city = "ShenZhen"
        address.state = "GD"
        
        let contact = PKContact()
        contact.name = name
        contact.postalAddress = address
        
        requst.shippingContact = contact
    }

}
 */
