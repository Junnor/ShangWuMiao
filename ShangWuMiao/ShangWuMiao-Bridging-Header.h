//
//  ShangWuMiao-Bridging-Header.h
//  ShangWuMiao
//
//  Created by Ju on 2017/5/9.
//  Copyright © 2017年 moelove. All rights reserved.
//

#ifndef ShangWuMiao_Bridging_Header_h
#define ShangWuMiao_Bridging_Header_h

// String md5
#import <CommonCrypto/CommonCrypto.h>

// Alipay
#import <AlipaySDK/AlipaySDK.h>

// Apple pay
#import "UPAPayPluginDelegate.h"
#import "UPAPayPlugin.h"

//#import "WXApi.h"
//#import "WXApiObject.h"

// Share SDK
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

// 第三方登录
#import <ShareSDKExtension/SSEThirdPartyLoginHelper.h>

//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

//微信SDK头文件
#import "WXApi.h"

//新浪微博SDK头文件
#import "WeiboSDK.h"
//新浪微博SDK需要在项目Build Settings中的Other Linker Flags添加"-ObjC"


#endif /* ShangWuMiao_Bridging_Header_h */




