//
//  UserPay.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/19.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum Pay: String {
    case wechat = "wechat"
    case alipay = "alipay"
}

final class UserPay {
    
    // MARK: - singleton
    static let shared = UserPay()
    private init() {}
    
    var orderPrice: Float!
    var order_id: String!
    
    // for alipay
    var alipay_sign_str: String!

    // for wechat
    var wechat_sign_str: String!
    var appid: String!
    var noncestr: String!
    var partnerid: String!
    var prepayid: String!
    var package: String!
    var timestamp: UInt32!
 
    // for
    var paySuccess: Bool!
}

extension UserPay {
    static func pay(withType payType: Pay, orderPrice: Float, completionHandler: @escaping (Bool, String?) -> ()) {
        UserPay.shared.orderPrice = orderPrice
        
        let url = signedInUrl(forUrlType: .recharge, actType: .rechargeMb)
        
        let parameters = ["uid": NSString(string: User.shared.uid).integerValue,
                          "order_price": orderPrice,
                          "pay_type": payType.rawValue] as [String : Any]
        
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default, headers: nil).responseJSON {
                            response in
                            switch response.result {
                            case .success(let jsonResource):
                                let json = JSON(jsonResource)
                                let info = json["info"].stringValue
                                if json["status"].intValue == 1 {
                                    let order_id = json["order_id"].stringValue
                                    UserPay.shared.order_id = order_id
                                    switch payType {
                                    case .alipay:
                                        let sign_str = json["sign_str"].stringValue
                                        
                                        UserPay.shared.alipay_sign_str = sign_str
                                    case .wechat:
                                        if let wechatSource = json["wx_sign"].dictionary {
                                            let wechat = JSON(wechatSource)
                                            let appid = wechat["appid"].stringValue
                                            let sign = wechat["sign"].stringValue

                                            let noncestr = wechat["noncestr"].stringValue
                                            let partnerid = wechat["partnerid"].stringValue
                                            let prepayid = wechat["prepayid"].stringValue
                                            let timestamp = wechat["timestamp"].stringValue
                                            let package = wechat["package"].stringValue

                                            UserPay.shared.wechat_sign_str = sign
                                            UserPay.shared.appid = appid
                                            UserPay.shared.noncestr = noncestr
                                            UserPay.shared.partnerid = partnerid
                                            UserPay.shared.prepayid = prepayid
                                            UserPay.shared.package = package
                                            UserPay.shared.timestamp = UInt32(timestamp)
                                        }
                                        
//                                        // test for temporary appid
//                                        UserPay.shared.appid = json["appid"].stringValue

                                        break
                                    }
                                    completionHandler(true, nil)
                                    return
                                }
                                completionHandler(false, info)
                            case .failure(let error):
                                completionHandler(false, "支付错误")
                                printX("error: \(error)")
                            }
                            
        }
        
    }
    
    static func payResult(tradeStatus status: Int, callback completionHandler: @escaping (Bool, String?) -> ()) {

        let url = signedInUrl(forUrlType: .rechargeCallback, actType: .recharge_back)
        
        let parameters = ["uid": NSString(string: User.shared.uid).integerValue,
                          "order_price": UserPay.shared.orderPrice,
                          "out_trade_no": UserPay.shared.order_id,
                          "trade_status": status] as [String : Any]
        
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { response in
                            switch response.result {
                            case .success(let jsonResource):
                                let json = JSON(jsonResource)
                                let info = json["info"].stringValue
                                let status = json["status"].intValue
                                completionHandler(status == 1, info)
                            case .failure(let error):
                                completionHandler(false, "回调错误")
                                printX("error: \(error)")
                            }
        }
    }

}
