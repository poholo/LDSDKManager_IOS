//
//  LDSDKAuthService.h
//  LDThirdLib
//
//  Created by ss on 15/8/12.
//  Copyright (c) 2015年 ss. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LDSDKLoginCallback)(NSDictionary *oauthInfo, NSDictionary *userInfo, NSError *error);


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
