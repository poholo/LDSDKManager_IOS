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
extern NSString *const LDSDKPlatformTypeKey;
extern NSString *const LDSDKShareToMoudleKey;
extern NSString *const LDSDKShareTypeKey;
extern NSString *const LDSDKShareTitleKey;
extern NSString *const LDSDKShareDescKey;
extern NSString *const LDSDKShareImageKey;
extern NSString *const LDSDKShareImageUrlKey;
extern NSString *const LDSDKShareUrlKey;
extern NSString *const LDSDKShareTextKey;         //新浪微博分享专用
extern NSString *const LDSDKShareRedirectURIKey;  //新浪微博分享专用
extern NSString *const LDSDKShareCallBackKey;

typedef NS_ENUM(NSInteger, LDSDKPlatformType) {
    LDSDKPlatformQQ = 1,  // QQ
    LDSDKPlatformWeChat,  //微信
    LDSDKPlatformYiXin,   //易信
    LDSDKPlatformAliPay,  //支付宝
    LDSDKPlatformWeibo,   //新浪微博
};

typedef NS_ENUM(NSInteger, LDSDKShareToModule) {
    LDSDKShareToContact = 1,  //分享至第三方应用的联系人或组
    LDSDKShareToTimeLine,     //分享至第三方应用的timeLine
    LDSDKShareToOther         //分享至第三方应用的其他模块
};

typedef NS_ENUM(NSInteger, LDSDKShareType) {
    LDSDKShareTypeText,
    LDSDKShareTypeImage,
    LDSDKShareTypeNews,
    LDSDKShareTypeAudio,
    LDSDKShareTypeVideo,
};

@interface LDSDKConfig : NSObject
@end
