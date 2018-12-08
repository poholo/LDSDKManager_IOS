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
extern NSString *const LDSDKIdentifierKey;
extern NSString *const LDSDKPlatformTypeKey;
extern NSString *const LDSDKShareToMoudleKey;
extern NSString *const LDSDKShareTypeKey;
extern NSString *const LDSDKShareTitleKey;
extern NSString *const LDSDKShareDescKey;
extern NSString *const LDSDKShareImageKey;
extern NSString *const LDSDKShareImageUrlKey;
extern NSString *const LDSDKShareUrlKey;
extern NSString *const LDSDKShareMeidaUrlKey;
extern NSString *const LDSDKShareRedirectURIKey;  //新浪微博分享专用
extern NSString *const LDSDKShareCallBackKey;

extern NSString *const kErrorMessage;
extern NSString *const kErrorDomain;
extern NSString *const kErrorObject;
extern NSString *const kErrorCode;

typedef NS_ENUM(NSInteger, LDSDKPlatformType) {
    LDSDKPlatformQQ,  // QQ
    LDSDKPlatformWeChat,  //微信
    LDSDKPlatformAliPay,  //支付宝
    LDSDKPlatformWeibo,   //新浪微博
};

typedef NS_ENUM(NSInteger, LDSDKShareToModule) {
    LDSDKShareToContact,  //分享至第三方应用的联系人或组
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

typedef NS_ENUM(NSInteger, LDSDKErrorCode) {
    LDSDKSuccess = 1,                ///< 成功
    LDSDKErrorCodeCommon = -1,       ///< 普通错误类型
    LDSDKErrorCodeUserCancel = -2,   ///< 用户点击取消并返回
    LDSDKErrorCodeSentFail = -3,     ///< 发送失败
    LDSDKErrorCodeAuthDeny = -4,     ///< 授权失败
    LDSDKErrorCodeUnsupport = -5,    ///< 不支持
    LDSDKErrorUninstallPlatformApp = -6, ///< 没有安装平台app
    LDSDKErrorCodePayFail = -7,          ///< 支付失败
    LDSDKErrorUnknow = -999,
};

typedef NS_ENUM(NSInteger, LDSDKLoginCode) {
    LDSDKLoginSuccess = 1,
    LDSDKLoginFailed = -1,
    LDSDKLoginNoNet = -2,
    LDSDKLoginUserCancel = -3,
    LDSDKLoginNoAuth = -4,
};

#if DEBUG
#define LDLog(fmt, ...) NSLog((@"%s %d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define LDLog(fmt, ...)
#endif

@interface LDSDKConfig : NSObject
@end
