//
//  Exhibition.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/10.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class Exhibition: NSObject {
    
    // for normal exhibition
    var addr: String!
    var cover: String!
    var start_time: String!
    var end_time: String!
    var name: String!
    var exid: String!
    var location: String!
    var exDescription: String!
    var scene_price: String!
    var presale_price: String!

    // for ticket exhibition
    var stauts: String!
    
    
    // for the newest enhibition of local
    var logo: String!
    
    override init() {
        // do nothing
        super.init()
    }
    
    convenience init(id: String,
         cover: String,
         name: String,
         exDescription: String,
         addr: String,
         location: String,
         start_time: String,
         end_time: String) {
        
        self.init()
        
        self.exid = id
        self.cover = cover
        self.name = name
        self.exDescription = exDescription
        self.location = location
        self.start_time = start_time
        self.end_time = end_time
        self.addr = addr
    }
    
    
    // For more data 
    fileprivate var exhibitionPage = 1
    fileprivate var ticketPage = 1
    fileprivate var topupListPage = 1

    fileprivate var exhibitions = [Exhibition]()
    
    static func fromJSON(_ json: JSON) -> Exhibition {
        let addr = json["addr"].stringValue
        let cover = json["cover"].stringValue
        let start_time = json["start_time"].stringValue
        let end_time = json["end_time"].stringValue
        let name = json["name"].stringValue
        let exid = json["eid"].stringValue
        let location = json["location"].stringValue
        let description = json["description"].stringValue
        
        let scene_price = json["scene_price"].stringValue
        let presale_price = json["presale_price"].stringValue

        
        let ex = Exhibition(id: exid,
                            cover: cover,
                            name: name,
                            exDescription: description,
                            addr: addr,
                            location: location,
                            start_time: start_time,
                            end_time: end_time)
        
        ex.scene_price = scene_price
        ex.presale_price = presale_price
        return ex
    }
}

extension Exhibition {
    // digit == true -> 05-11 10:00
    func exhibition(stringTime time: String, digit: Bool) -> String {
        let value = NSString(string: time).doubleValue
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        if digit {
            formatter.dateFormat = "MM-dd HH:mm"
        } else {
            formatter.dateFormat = "yyyy年MM月dd日"
        }
        let date = Date(timeIntervalSince1970: value)

        return formatter.string(from: date)
    }
}

// Data request
extension Exhibition {
    
    func requestExhibitionListTickets(completionHandle: @escaping (Bool, String?, [Ticket]) -> ()) {

        let url = signedInUrl(forUrlType: .exhibitionTicketList, actType: .ticket_list)
        
        let parameters = ["uid": NSString(string: User.shared.uid).integerValue,
                          "eid": NSString(string: self.exid).integerValue]
        
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { response in
                            switch response.result {
                            case .success(let jsonResponse):
                                let json = JSON(jsonResponse)
                                let status = json["result"].intValue
                                var tickts = [Ticket]()
                                if status == 1 {
                                    let data = json["data"].arrayValue
                                    for tickt in data {
                                        let id = tickt["id"].stringValue
                                        let name = tickt["name"].stringValue
                                        let price = tickt["price"].stringValue
                                        let proxy_price = tickt["proxy_price"].stringValue
                                        let ticket = Ticket(ticketId: id, name: name, price: price, proxy_price: proxy_price)
                                        tickts.append(ticket)
                                    }
                                }
                                completionHandle(status == 1, nil, tickts)
                            case .failure(let error):
                                completionHandle(false, "获取错误", [])
                                printX("error: \(error)")
                            }
        }
        
    }
   
    func requestSoldTicketForExhibitionList(loadMore more: Bool, completionHandler: @escaping (Bool, String, [Exhibition]) -> ()) {
        ticketPage = more ? ticketPage + 1 : 1
        
        let url = signedInUrl(forUrlType: .soldExhibitions, actType: .my_list)
        
        let parameters = ["uid": NSString(string: User.shared.uid).integerValue,
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
                                var tmpExhibitions = [Exhibition]()
                                if status == 1 {
                                    let data = json["data"].arrayValue
                                    for exhibition in data {
                                        let ex = Exhibition.fromJSON(exhibition)
                                        
                                        // for ticket exhibition
                                        let status = exhibition["status"].stringValue
                                        ex.stauts = status

                                        tmpExhibitions.append(ex)
                                    }
                                }
                                
                                if more {
                                    for exhibition in tmpExhibitions {
                                        self.exhibitions.append(exhibition)
                                    }
                                } else {
                                    self.exhibitions.removeAll()
                                    self.exhibitions = tmpExhibitions
                                }
                                
                                completionHandler(status == 1, errorInfo, self.exhibitions)
                                
                            case .failure(let error):
                                completionHandler(false, "获取已购漫展错误", [])
                                printX("error: \(error)")
                            }
        }
    }

    // true for more, false for page 0 or refresh
    func requestExhibitionList(withKeyword keyword:  String?, loadMore: Bool, completionHandler: @escaping (Bool, String, [Exhibition]) -> ()) {
        
        exhibitionPage = loadMore ? exhibitionPage + 1 : 1

        let url = signedInUrl(forUrlType: .exhibitions, actType: .ex_list)!
        
        let parameters = ["uid": NSString(string: User.shared.uid).integerValue,
                          "p": self.exhibitionPage,
                          "keyword": keyword ?? ""] as [String : Any]
        
        Alamofire.request(url,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { response in
                            switch response.result {
                            case .success(let jsonResponse):
                                let json = JSON(jsonResponse)
                                let status = json["result"].intValue
                                let errorInfo = json["error"].stringValue
                                var tmpExhibitions = [Exhibition]()
                                if status == 1 {
                                    let data = json["data"].arrayValue
                                    for exhibition in data {
                                        let ex = Exhibition.fromJSON(exhibition)
                                        tmpExhibitions.append(ex)
                                    }
                                }
                                
                                if loadMore {
                                    for exhibition in tmpExhibitions {
                                        self.exhibitions.append(exhibition)
                                    }
                                } else {
                                    self.exhibitions.removeAll()
                                    self.exhibitions = tmpExhibitions
                                }
                                
                                completionHandler(status == 1, errorInfo, self.exhibitions)
                            case .failure(let error):
                                completionHandler(false, "获取漫展列表错误", [])
                                printX("error: \(error)")
                            }
        }
    }
    
    
    // MARK: - A new local exhibition
    static func newLocalExhibition(completionHandler: @escaping (_ status: Bool, _ exhibition: Exhibition?) -> ()) {
        let url = signedInUrl(forUrlType: .newExhibitionPic, actType: .newExhibitionPic)!
        
        var provinceId = 0
        if let value = UserDefaults.standard.value(forKey: "procinceId") as? Int {
            provinceId = value
        }
        
        let parameters = ["province": provinceId]
        Alamofire.request(url,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default, headers: nil).responseJSON {
                            response in
                            switch response.result {
                            case .success(let jsonResponse):
                                let json = JSON(jsonResponse)

                                let status = json["status"].intValue
                                var exhibition = Exhibition()
                                if status == 1 {
                                    if status == 1 {
                                        let data = json["data"]
                                        exhibition = Exhibition.fromJSON(data)
                                    }
                                    
                                    let logo = json["logo"].stringValue
                                    exhibition.logo = logo
                                }
                                completionHandler(status == 1, exhibition)
                            case .failure(let error):
                                completionHandler(false, nil)
                                printX("error: \(error)")
                            }
                            
        }
        
    }

}
