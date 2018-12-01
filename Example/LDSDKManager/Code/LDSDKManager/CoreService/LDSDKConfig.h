//
// Created by majiancheng on 2018/11/29.
// Copyright (c) 2018 张海洋. All rights reserved.
//

#import <Foundation/Foundation.h>


//微信登陆，用户信息的Key
extern NSString *const kWX_OPENID_KEY;
extern NSString *const kWX_NICKNAME_KEY;
extern NSString *const kWX_AVATARURL_KEY;
extern NSString *const kWX_ACCESSTOKEN_KEY;
// QQ登陆，用户信息的Key
extern NSString *const kQQ_OPENID_KEY;
extern NSString *const kQQ_TOKEN_KEY;
extern NSString *const kQQ_NICKNAME_KEY;
extern NSString *const kQQ_EXPIRADATE_KEY;
extern NSString *const kQQ_AVATARURL_KEY;


//应用注册SDK服务，配置信息的Key
extern NSString *const LDSDKConfigAppIdKey;
extern NSString *const LDSDKConfigAppSecretKey;
extern NSString *const LDSDKConfigAppSchemeKey;
extern NSString *const LDSDKConfigAppPlatformTypeKey;
extern NSString *const LDSDKConfigAppDescriptionKey;


//使用SDK分享，分享内容信息的Key
extern NSString *const LDSDKShareContentTitleKey;
extern NSString *const LDSDKShareContentDescriptionKey;
extern NSString *const LDSDKShareContentImageKey;
extern NSString *const LDSDKShareContentWapUrlKey;
extern NSString *const LDSDKShareContentTextKey;         //新浪微博分享专用
extern NSString *const LDSDKShareContentRedirectURIKey;  //新浪微博分享专用
extern NSString *const LDSDKShareTypeKey;

typedef NS_ENUM(NSUInteger, LDSDKPlatformType) {
    LDSDKPlatformQQ = 1,  // QQ
    LDSDKPlatformWeChat,  //微信
    LDSDKPlatformYiXin,   //易信
    LDSDKPlatformAliPay,  //支付宝
    LDSDKPlatformWeibo,   //新浪微博
};

@interface LDSDKConfig : NSObject
@end