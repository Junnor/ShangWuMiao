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

// 密钥
let kSecretKey = "us8dgf30hjRJGFU21"

// 版本
let kAppVersion = "2.0"

// 支付宝跳转
let kAlipaySchema = "NyatoVendorAlipay"
//let kAppId = "wx8356797cc8741cfb"
//var isWechat: Bool!

// 喵币监听
let nyatoMcoinsChange = Notification.Name("nyatoMcoinsChange")


struct RequestURL {
    
    // 验证找回通过手机找回密码的验证码
    static let kVerifyCodeForRetrievePswUrlString = "/index.php?app=ios&mod=Member&act=verifyCode"

    // 手机找回密码
    static let kRetrievePasswordWithTelephoneUrlString = "/index.php?app=ios&mod=Member&act=resetPwd"

    // 邮箱找回密码
    static let kRetrievePasswordWithEmailUrlString = "/index.php?app=ios&mod=Member&act=forgot_pwd"
    
    // 通过第三方平台（比如微信，微博， QQ） 注册喵特账号
    static let kThirdPartyCreateNyatoUrlString = "/index.php?app=ios&mod=Member&act=other_login"
    
    // 第三方账号绑定已有的喵特账户
    static let kBindNyatoUrlString = "/index.php?app=ios&mod=Member&act=bind_user"
    
    // 第三方登录绑定判断
    static let kThirdPartyBindCheckUrlString = "/index.php?app=ios&mod=Member&act=is_bind"
    
    // 获取验证码
    static let kCodeUrlString = "/index.php?app=ios&mod=Member&act=sendPhoneCode"
    
    // 用户注册
    static let kRegisterUrlString = "/index.php?app=ios&mod=Member&act=phoneReg"
    
    // 用户登陆
    static let kLoginUrlString = "/index.php?app=ios&mod=Member&act=login"
    
    // 获取用户信息
    static let kUserInfoUrlString = "/index.php?app=ios&mod=Member&act=getuinfo"
    
    // 我的充值列表
    static let kTopupListUrlString = "/index.php?app=ios&mod=Business&act=recharge_logs"
    
    // 重发购票短信
    static let kTicketMsSendUrlString = "/index.php?app=ios&mod=Business&act=sendTicketSms"
    
    // 用户反馈
    static let kFeedbackUrlString = "/index.php?app=ios&mod=Index&act=report"
    
    // 用户检测
    static let kUserCheckUrlString = "/index.php?app=ios&mod=Member&act=userCheck"
    
    // 用户充值
    static let kRechargeUrlString = "/index.php?app=ios&mod=PayInfo&act=rechargeMb"
    
    // 充值成功回调
    static let kRechargeBackUrlString = "/index.php?app=ios&mod=PayInfo&act=recharge_back"
    
    // 购买门票
    static let kBuyTicktUrlString = "/index.php?app=ios&mod=Business&act=buyTicket"
    
    // 展会列表
    static let kExhibitionUrlString = "/index.php?app=ios&mod=Business&act=ex_list"

    // 我售出的展会列表
    static let kSoldExhibitionUrlString = "/index.php?app=ios&mod=Business&act=my_list"
    
    // 我售出的展会门票列表
    static let kTicketsUrlString =  "/index.php?app=ios&mod=Business&act=sale_logs"

    // 展会门票列表
    static let kExhibitionTicketList = "/index.php?app=ios&mod=Business&act=ticket_list"
    
    
    // 更新接口
    static let kAppUpdateUrlString = "/index.php?app=ios&mod=Business&act=ios_update"
    
}

//struct ActType {
//    
//    // 验证找回通过手机找回密码的验证码
//    static let verifyCodeForRetrievePsw = "verifyCode"
//    
//    // 手机找回密码
//    static let retrievePasswordWithTelephone = "resetPwd"
//    
//    // 邮箱找回密码
//    static let retrievePasswordWithEmail = "forgot_pwd"
//    
//    // 通过第三方平台（比如微信，微博， QQ） 注册喵特账号
//    static let thirdPartyCreateNyato = "other_login"
//
//    // 第三方账号绑定喵特账户
//    static let bindNyato = "bind_user"
//    
//    // 第三方登录绑定
//    static let thirdParty_BindCheck = "is_bind"
//    
//    // 获取验证码
//    static let sendPhoneCode = "sendPhoneCode"
//    
//    // 用户注册
//    static let register = "phoneReg"
//    
//    // 用户登陆
//    static let login = "login"
//    
//    // 获取用户信息
//    static let getuinfo = "getuinfo"
//    
//    // 我的充值列表
//    static let recharge_logs = "recharge_logs"
//    
//    // 重发购票短信
//    static let sendTicketSms = "sendTicketSms"
//    
//    // 用户反馈
//    static let report = "report"
//    
//    // 用户检测
//    static let user_check = "userCheck"
//    
//    // 用户充值
//    static let rechargeMb = "rechargeMb"
//    
//    // 充值成功回调
//    static let recharge_back = "recharge_back"
//    
//    // 购买门票
//    static let buyTicket = "buyTicket"
//    
//    // 展会列表
//    static let ex_list = "ex_list"
//
//    // 我售出的展会列表
//    static let my_list = "my_list"
//    
//    // 我售出的展会门票列表
//    static let sale_logs = "sale_logs"
//    
//    // 展会门票列表
//    static let ticket_list = "ticket_list"
//    
//    // 更新接口
//    static let ios_update = "ios_update"
//}

struct ActType {
    
    // 验证找回通过手机找回密码的验证码
    static let verifyCodeForRetrievePsw = "verifyCode"
    
    // 手机找回密码
    static let retrievePasswordWithTelephone = "resetPwd"
    
    // 邮箱找回密码
    static let retrievePasswordWithEmail = "forgot_pwd"
    
    // 通过第三方平台（比如微信，微博， QQ） 注册喵特账号
    static let thirdPartyCreateNyato = "other_login"
    
    // 第三方账号绑定喵特账户
    static let bindNyato = "bind_user"
    
    // 第三方登录绑定
    static let thirdParty_BindCheck = "is_bind"
    
    // 获取验证码
    static let sendPhoneCode = "sendPhoneCode"
    
    // 用户注册
    static let register = "phoneReg"
    
    // 用户登陆
    static let login = "login"
    
    // 获取用户信息
    static let getuinfo = "getuinfo"
    
    // 我的充值列表
    static let recharge_logs = "recharge_logs"
    
    // 重发购票短信
    static let sendTicketSms = "sendTicketSms"
    
    // 用户反馈
    static let report = "report"
    
    // 用户检测
    static let user_check = "userCheck"
    
    // 用户充值
    static let rechargeMb = "rechargeMb"
    
    // 充值成功回调
    static let recharge_back = "recharge_back"
    
    // 购买门票
    static let buyTicket = "buyTicket"
    
    // 展会列表
    static let ex_list = "ex_list"
    
    // 我售出的展会列表
    static let my_list = "my_list"
    
    // 我售出的展会门票列表
    static let sale_logs = "sale_logs"
    
    // 展会门票列表
    static let ticket_list = "ticket_list"
    
    // 更新接口
    static let ios_update = "ios_update"
}


