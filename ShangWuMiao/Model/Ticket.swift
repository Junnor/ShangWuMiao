//
//  Ticket.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/12.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

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
    static func mesageSendWithOrderId(id: String, completionHandler: @escaping (Bool, String) -> ()) {

        let url = signedInUrl(forUrlType: .ticketMsSend, actType: .sendTicketSms)
        
        let parameters = ["uid": NSString(string: User.shared.uid).integerValue,
                          "orderid": NSString(string: id).integerValue]
        
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { response in
                            switch response.result {
                            case .success(let jsonResponse):
                                let json = JSON(jsonResponse)
                                let status = json["status"].intValue
                                let info = json["info"].stringValue
                                completionHandler(status == 1, info)
                            case .failure(let error):
                                completionHandler(false, "短信重发错误")
                                printX("error: \(error)")
                            }
        }

    }
    
    func requestTickets(forExhibitionId exhibitionId: String, loadMore more: Bool, completionHandler: @escaping (Bool, String?, [Ticket]) -> ()) {
        ticketPage = more ? ticketPage + 1 : 1

        let url = signedInUrl(forUrlType: .soldTicktsInExhibition, actType: .sale_logs)
        
        let parameters = ["uid": NSString(string: User.shared.uid).integerValue,
                          "eid": NSString(string: exhibitionId).integerValue,
                          "p": self.ticketPage]
        
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { response in
                            switch response.result {
                            case .success(let jsonResponse):
                                let json = JSON(jsonResponse)
                                let status = json["result"].intValue
                                let errorInfo = json["error"].stringValue
                                var tmpTickets = [Ticket]()
                                if status == 1 {
                                    let data = json["data"].arrayValue
                                    for tickt in data {
                                        let orderid = tickt["orderid"].stringValue
                                        let cover = tickt["cover"].stringValue
                                        let ordertitle = tickt["ordertitle"].stringValue
                                        let tel = tickt["tel"].stringValue
                                        let shop_num = tickt["shop_num"].stringValue
                                        
                                        let ticket = Ticket(orderId: orderid,
                                                            title: ordertitle,
                                                            cover: cover,
                                                            telphone: tel,
                                                            number: shop_num)
                                        tmpTickets.append(ticket)
                                    }
                                }
                                
                                if more {
                                    for ticket in tmpTickets {
                                        self.tickets.append(ticket)
                                    }
                                } else {
                                    self.tickets.removeAll()
                                    self.tickets = tmpTickets
                                }
                                
                                completionHandler(status == 1, errorInfo, self.tickets)
                            case .failure(let error):
                                completionHandler(false, "获取错误", [])
                                printX("error: \(error)")
                            }
        }
    }

}
