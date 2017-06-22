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
var shangHuAppVersion: String {
    return  Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
}

// 支付宝跳转
let kAlipaySchema = "NyatoVendorAlipay"

// 微信 AppID
let nyatoWechatAppId = "wxeb0f70c7821904f6"

// 喵币监听
let nyatoMcoinsChange = Notification.Name("nyatoMcoinsChange")


// Counlty 统计
let countlyPayEventKey = "shangwupay"

let alipaySuccess = Notification.Name("alipaySuccess")
let wechatPaySuccess = Notification.Name("wechatPaySuccess")
let applePaySuccess = Notification.Name("applePaySuccess")
let buyTicktsSuccess = Notification.Name("buyTicktsSuccess")


// Url string
enum RequestUrlStringType: String {
    
    // 解除绑定手机
    case unbindTelephone = "/index.php?app=ios&mod=Member&act=phoneUnBind"

    // 绑定手机
    case bindTelephone = "/index.php?app=ios&mod=Member&act=MobileBind"
    
    // 绑定邮箱
    case bindEmail = "/index.php?app=ios&mod=Member&act=bindEmail"

    // 设置内重设密码
    case meResetPassword = "/index.php?app=ios&mod=Member&act=mod_pw"
    
    // 验证找回通过手机找回密码的验证码
    case verifyCodeForRetrievePsw = "/index.php?app=ios&mod=Member&act=verifyCode"

    // 手机找回密码
    case retrievePasswordWithTelephone = "/index.php?app=ios&mod=Member&act=resetPwd"

    // 邮箱找回密码
    case retrievePasswordWithEmail = "/index.php?app=ios&mod=Member&act=forgot_pwd"
    
    // 通过第三方平台（比如微信，微博， QQ） 注册喵特账号
    case thirdPartyCreateNyato = "/index.php?app=ios&mod=Member&act=other_login"
    
    // 第三方账号绑定已有的喵特账户
    case bindNyato = "/index.php?app=ios&mod=Member&act=bind_user"
    
    // 第三方登录绑定判断
    case thirdPartyBindCheck = "/index.php?app=ios&mod=Member&act=is_bind"
    
    // 获取验证码
    case phoneCode = "/index.php?app=ios&mod=Member&act=sendPhoneCode"
    
    // 用户注册
    case register = "/index.php?app=ios&mod=Member&act=phoneReg"
    
    // 用户登陆
    case login = "/index.php?app=ios&mod=Member&act=login"
    
    // 获取用户信息
    case userInfo = "/index.php?app=ios&mod=Member&act=getuinfo"
    
    // 我的充值列表
    case topupList = "/index.php?app=ios&mod=Business&act=recharge_logs"
    
    // 重发购票短信
    case ticketMsSend = "/index.php?app=ios&mod=Business&act=sendTicketSms"
    
    // 用户反馈
    case feedback = "/index.php?app=ios&mod=Index&act=report"
    
    // 用户检测
    case userCheck = "/index.php?app=ios&mod=Member&act=userCheck"
    
    // 用户充值
    case recharge = "/index.php?app=ios&mod=PayInfo&act=rechargeMb"
    
    // 充值成功回调
    case rechargeCallback = "/index.php?app=ios&mod=PayInfo&act=recharge_back"
    
    // 购买门票
    case buyTickt = "/index.php?app=ios&mod=Business&act=buyTicket"
    
    // 展会列表
    case exhibitions = "/index.php?app=ios&mod=Business&act=ex_list"

    // 我售出的展会列表
    case soldExhibitions = "/index.php?app=ios&mod=Business&act=my_list"
    
    // 我售出的展会门票列表
    case soldTicktsInExhibition =  "/index.php?app=ios&mod=Business&act=sale_logs"

    // 展会门票列表
    case exhibitionTicketList = "/index.php?app=ios&mod=Business&act=ticket_list"
    
    
    // 更新接口
    case appUpdate = "/index.php?app=ios&mod=Business&act=ios_update"
    
}

enum ActType: String {
    
    // 解除绑定手机
    case unbindTelephone = "phoneUnBind"
    
    // 绑定手机
    case bindTelephone = "MobileBind"

    // 绑定邮箱
    case bindEmail = "bindEmail"
    
    // 设置内重设密码
    case meResetPassword = "mod_pw"

    // 验证找回通过手机找回密码的验证码
    case verifyCodeForRetrievePsw = "verifyCode"
    
    // 手机找回密码
    case retrievePasswordWithTelephone = "resetPwd"
    
    // 邮箱找回密码
    case retrievePasswordWithEmail = "forgot_pwd"
    
    // 通过第三方平台（比如微信，微博， QQ） 注册喵特账号
    case thirdPartyCreateNyato = "other_login"
    
    // 第三方账号绑定喵特账户
    case bindNyato = "bind_user"
    
    // 第三方登录绑定
    case thirdPartyBindCheck = "is_bind"
    
    // 获取验证码
    case sendPhoneCode = "sendPhoneCode"
    
    // 用户注册
    case register = "phoneReg"
    
    // 用户登陆
    case login = "login"
    
    // 获取用户信息
    case getuinfo = "getuinfo"
    
    // 我的充值列表
    case recharge_logs = "recharge_logs"
    
    // 重发购票短信
    case sendTicketSms = "sendTicketSms"
    
    // 用户反馈
    case report = "report"
    
    // 用户检测
    case user_check = "userCheck"
    
    // 用户充值
    case rechargeMb = "rechargeMb"
    
    // 充值成功回调
    case recharge_back = "recharge_back"
    
    // 购买门票
    case buyTicket = "buyTicket"
    
    // 展会列表
    case ex_list = "ex_list"
    
    // 我售出的展会列表
    case my_list = "my_list"
    
    // 我售出的展会门票列表
    case sale_logs = "sale_logs"
    
    // 展会门票列表
    case ticket_list = "ticket_list"
    
    // 更新接口
    case ios_update = "ios_update"
}


