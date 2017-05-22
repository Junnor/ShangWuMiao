//
//  URLAct.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/10.
//  Copyright © 2017年 moelove. All rights reserved.
//

import Foundation

let kHeaderUrl = "https://apiplus.nyato.com"
let kImageHeaderUrl = "https://img.nyato.com/"
let kSecretKey = "us8dgf30hjRJGFU21"
let kAppVersion = "2.0"
let kAlipaySchema = "NyatoVendorAlipay"
let kWechatSchema = "NyatoVendorWechat"


struct RequestURL {
    static let kLoginUrlString = "/index.php?app=ios&mod=Member&act=login"
    static let kUserInfoUrlString = "/index.php?app=ios&mod=Member&act=getuinfo"
    static let kExhibitionUrlString = "/index.php?app=ios&mod=Business&act=ex_list"
    static let kTopupListUrlString = "/index.php?app=ios&mod=Business&act=recharge_logs"
    static let kSoldExhibitionUrlString = "/index.php?app=ios&mod=Business&act=my_list"
    static let kTicketsUrlString =  "/index.php?app=ios&mod=Business&act=sale_logs"
    static let kTicketMsSendUrlString = "/index.php?app=ios&mod=Business&act=sendTicketSms"
    static let kFeedbackUrlString = "/index.php?app=ios&mod=Index&act=report"
    static let kExhibitionTicketList = "/index.php?app=ios&mod=Business&act=ticket_list"
    static let kRechargeUrlString = "/index.php?app=ios&mod=PayInfo&act=rechargeMb"
    static let kRechargeBackUrlString = "/index.php?app=ios&mod=PayInfo&act=recharge_back"
    static let kBuyTicktUrlString = "/index.php?app=ios&mod=Business&act=buyTicket"
}

struct ActType {
    static let login = "login"
    static let getuinfo = "getuinfo"
    static let ex_list = "ex_list"
    static let recharge_logs = "recharge_logs"
    static let my_list = "my_list"
    static let sale_logs = "sale_logs"
    static let sendTicketSms = "sendTicketSms"
    static let report = "report"
    static let ticket_list = "ticket_list"
    static let rechargeMb = "rechargeMb"
    static let recharge_back = "recharge_back"
    static let buyTicket = "buyTicket"
}

