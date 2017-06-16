//
//  TopupList.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/12.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class TopupList: NSObject {
    var orderid: String!
    var orderTitle: String!
    var order_price: String!
    var pay_status: String!
    
    override init() {
        super.init()
        
        // do nothing
    }
    
    convenience init(orderId: String,
                     orderTitle: String,
                     price: String,
                     payStatus: String) {
        self.init()
        
        self.orderid = orderId
        self.orderTitle = orderTitle
        self.order_price = price
        self.pay_status = payStatus
    }

    fileprivate var topupListPage = 1
}


extension TopupList {
    func requestTopupList(loadMore more: Bool, completionHandler: @escaping (Bool, String?, [TopupList]) -> ()) {
        topupListPage = more ? topupListPage + 1 : 1
        let stringPara = stringParameters(actTo: ActType.recharge_logs.rawValue)
        let userinfoString = kHeaderUrl + RequestUrlStringType.topupList.rawValue + stringPara
        
        let url = URL(string: userinfoString)
        let parameters = ["uid": NSString(string: User.shared.uid).integerValue,
                          "p": self.topupListPage]
        
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default, headers: nil).responseJSON {
                            response in
                            switch response.result {
                            case .success(let jsonSource):
//                                print("list json: \(jsonSource)")
                                
                                let json = JSON(jsonSource)
                                guard let result = json["result"].int,
                                    result == 1 else {
                                        let errorInfo = json["error"].stringValue
                                        completionHandler(false, errorInfo, [])
                                        return
                                }
                                
                                let data = json["data"].arrayValue
                                var tmpLists = [TopupList]()

                                for listDic in data {
                                    let price = listDic["order_price"].stringValue
                                    let id = listDic["orderid"].stringValue
                                    let title = listDic["ordertitle"].stringValue
                                    let payStatus = listDic["pay_status"].stringValue
                                    
                                    let payStatusString = (payStatus == "1") ? "已支付" : "未支付"
                                    
                                    let list = TopupList(orderId: id,
                                                         orderTitle: title,
                                                         price: String(price),
                                                         payStatus: payStatusString)
                                    tmpLists.append(list)

                                }
                                completionHandler(true, nil, tmpLists)
                            case .failure(let error):
                                completionHandler(false, "获取错误", [])
                                print("request top up list error: \(error)")
                            }
        }
    }

}
