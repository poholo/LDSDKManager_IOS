//
//  LDSDKAuthService.h
//  LDThirdLib
//
//  Created by ss on 15/8/12.
//  Copyright (c) 2015年 ss. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LDSDKLoginCallback)(NSDictionary *oauthInfo, NSDictionary *userInfo, NSError *error);

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

@protocol LDSDKAuthService <NSObject>

/*!
 *  @brief  判断该平台是否支持登陆
 *
 *  @return 已安装返回YES，否则返回NO
 */
- (BOOL)isLoginEnabledOnPlatform;

/*!
 *  @brief  第三方登陆
 *
 *  @param callback 登陆回调
 */
- (void)loginToPlatformWithCallback:(LDSDKLoginCallback)callback;

/*!
 *  @brief  退出登陆，主要是QQ平台
 */
- (void)logoutFromPlatform;

@end
