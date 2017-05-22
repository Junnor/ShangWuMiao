//
//  Ticket.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/12.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import Alamofire

class Ticket: NSObject {
    
    var cover: String!
    var ordertitle: String!
    var tel: String!
    var shop_num: String!
    var orderid: String!
    
    // for exhibition ticket list
    var id: String!
    var name: String!
    var price: String!
    var proxy_price: String!

    override init() {
        // do nothing
        super.init()
    }

    convenience init(orderId: String, title: String, cover: String, telphone: String, number: String) {
        self.init()
        
        self.orderid = orderId
        self.ordertitle = title
        self.cover = cover
        self.tel = telphone
        self.shop_num = number
    }
    
    convenience init(ticketId: String, name: String, price: String, proxy_price: String) {
        self.init()
        
        self.id = ticketId
        self.name = name
        self.price = price
        self.proxy_price = proxy_price
    }
    
    
    fileprivate var ticketPage = 1
    fileprivate var tickets = [Ticket]()
}

extension Ticket {
    static func mesageSendWithOrderId(id: String, completionHandler: @escaping (Int, String) -> ()) {
        let stringPara = stringParameters(actTo: ActType.sendTicketSms)
        let userinfoString = kHeaderUrl + RequestURL.kTicketMsSendUrlString + stringPara
        
        let url = URL(string: userinfoString)
        let parameters = ["uid": NSString(string: User.shared.uid).integerValue,
                          "orderid": NSString(string: id).integerValue]
        
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { response in
                            switch response.result {
                            case .success(let json):
//                                print("..ticket json: \(json)")
                                guard let dic = json as? Dictionary<String, Any>,
                                let status = dic["status"] as? Int, let info = dic["info"] as? String else {
                                    completionHandler(0, "cast type failure")
                                    return
                                }
                                completionHandler(status, info)
                            case .failure(let error):
                                print("send ticket message error: \(error)")
                            }
        }

    }
    
    func requestTickets(forExhibitionId exhibitionId: String, loadMore more: Bool, completionHandler: @escaping (Bool, String?, [Ticket]) -> ()) {
        ticketPage = more ? ticketPage + 1 : 1
        
        let stringPara = stringParameters(actTo: ActType.sale_logs)
        let userinfoString = kHeaderUrl + RequestURL.kTicketsUrlString + stringPara
        
        let url = URL(string: userinfoString)
        let parameters = ["uid": NSString(string: User.shared.uid).integerValue,
                          "eid": NSString(string: exhibitionId).integerValue,
                          "p": self.ticketPage]
        
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { response in
                            switch response.result {
                            case .success(let json):
//                                print("exhibition list json: \(json)")
//                                print("........................................")
                                if let dic = json as? Dictionary<String, AnyObject> {
                                    if let status = dic["result"] as? Int {
                                        if status == 1 {
                                            if let dataArr = dic["data"] as? Array<Dictionary<String, AnyObject>> {
                                                var tmpTickets = [Ticket]()
                                                for data in dataArr {
                                                    // 先这样, 强制转换不好 ！！！
                                                    let orderid = data["orderid"] as! String
                                                    let cover = data["cover"] as! String
                                                    let ordertitle = data["ordertitle"] as! String
                                                    let tel = data["tel"] as! String
                                                    let shop_num = data["shop_num"] as! String

                                                    let ticket = Ticket(orderId: orderid, title: ordertitle, cover: cover, telphone: tel, number: shop_num)
                                                    
                                                    tmpTickets.append(ticket)
                                                }
                                                
                                                if more {
                                                    for ticket in tmpTickets {
                                                        self.tickets.append(ticket)
                                                    }
                                                } else {
                                                    self.tickets.removeAll()
                                                    self.tickets = tmpTickets
                                                }
                                                
                                                completionHandler(true, nil, self.tickets)
                                            }
                                            return
                                        } else {
                                            let errorInfo = dic["error"] as? String
                                            completionHandler(false, errorInfo, [])
                                        }
                                    }
                                }
                            case .failure(let error):
                                print("get tickets data error: \(error)")
                            }
        }
    }

}
