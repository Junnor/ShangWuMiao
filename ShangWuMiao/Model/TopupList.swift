//
//  TopupList.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/12.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import Alamofire

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
        let stringPara = stringParameters(actTo: ActType.recharge_logs)
        let userinfoString = kHeaderUrl + RequestURL.kTopupListUrlString + stringPara
        
        let url = URL(string: userinfoString)
        let parameters = ["uid": NSString(string: User.shared.uid).integerValue,
                          "p": self.topupListPage]
        
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default, headers: nil).responseJSON {
                            response in
                            switch response.result {
                            case .success(let json):
//                                print("list json: \(json)")
                                
                                if let dic = json as? Dictionary<String, AnyObject> {
                                    guard let status = dic["result"] as? Int, status == 1 else {
                                        let error = dic["error"] as! String
                                        completionHandler(false, error, [])
                                        return
                                    }
                                    
                                    if let data = dic["data"] as? [Dictionary<String, AnyObject>] {
                                        var tmpLists = [TopupList]()
                                        for listDic in data {
                                            let price = listDic["order_price"] as! String
                                            let id = listDic["orderid"] as! String
                                            let title = listDic["ordertitle"] as! String
                                            let payStatus = listDic["pay_status"] as! String
                                            
                                            let payStatusString = (payStatus == "1") ? "已支付" : "未支付"
                                            
                                            let list = TopupList(orderId: id,
                                                                 orderTitle: title,
                                                                 price: String(price),
                                                                 payStatus: payStatusString)
                                            tmpLists.append(list)
                                        }
                                        completionHandler(true, nil, tmpLists)
                                    }
                                }
                            case .failure(let error):
                                print("request top up list error: \(error)")
                            }
        }
    }

}
