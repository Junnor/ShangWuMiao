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
class ApplePayViewController: UIViewController {
    
    @IBOutlet weak var applePayButton: UIButton!
    @IBOutlet weak var applePayStatusLabel: UILabel!
    
    private var payRequest = PKPaymentRequest()
    private let merchantID = "merchant.com.example.merchantname.ts"
    
    private let payNetworks: [PKPaymentNetwork] = [.visa, .chinaUnionPay, .masterCard]

    override func viewDidLoad() {
        super.viewDidLoad()

        isApplePayAvailableCheck()
        
        applePayButton.setTitle("Apple Pay", for: .normal)
        applePayButton.addTarget(self, action: #selector(applePay), for: .touchUpInside)
    }
    
    @objc private func applePay() {
        configureWithRequest(payRequest)

        let payauViewController = PKPaymentAuthorizationViewController(paymentRequest: payRequest)
        payauViewController.delegate = self
        present(payauViewController, animated: true, completion: nil)
    }
    
    private func configureWithRequest(_ request: PKPaymentRequest) {
        request.merchantIdentifier = merchantID
        request.countryCode = "CN"
        request.currencyCode = "CNY"
        
        request.supportedNetworks = payNetworks

        request.merchantCapabilities = [.capability3DS, .capabilityCredit, .capabilityDebit, .capabilityEMV]
        
        // Order info
        let originalPrice = NSDecimalNumber(mantissa: 100, exponent: -2, isNegative: false)
        let afterDiscount = NSDecimalNumber(mantissa: 10, exponent: -2, isNegative: false)
        
        let originalItem = PKPaymentSummaryItem(label: "XYZ原价", amount: originalPrice, type: .final)
        let afterDiscountItem = PKPaymentSummaryItem(label: "XYZ代理价", amount: afterDiscount, type: .final)
        let totalItem = PKPaymentSummaryItem(label: "喵特", amount: afterDiscount)
        
        request.paymentSummaryItems = [originalItem, afterDiscountItem, totalItem]
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
    
    
    private func isApplePayAvailableCheck() {
        
        var msg = "当前设备可正常使用Apple Pay"
        // Show or hide the apple pay button
        if !PKPaymentAuthorizationViewController.canMakePayments() {
            msg = "当前设备版本或系统不支持ApplePay"
            let alert = UIAlertController(title: "Apple Pay",
                                          message: msg,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }

        // Show prompt to user to set something
        // Show a add cards button
        if !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: payNetworks) {
            msg = "当前设备没有包含支持的支付银行卡"

            let alert = UIAlertController(title: "Apple Pay",
                                          message:msg,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    
        applePayStatusLabel.text = msg
    }

}

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

    
}
