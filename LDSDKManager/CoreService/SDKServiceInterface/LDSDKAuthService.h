//
//  LDSDKAuthService.h
//  LDThirdLib
//
//  Created by ss on 15/8/12.
//  Copyright (c) 2015年 ss. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LDSDKConfig.h"

typedef void (^LDSDKAuthCallback)(LDSDKLoginCode, NSError *error, NSDictionary *oauthInfo, NSDictionary *userInfo);


@protocol LDSDKAuthService <NSObject>

/*!
 *  @brief  第三方登陆
 *
 *  @param callback 登陆回调
 */
- (void)authPlatformCallback:(LDSDKAuthCallback)callback;

- (void)authPlatformQRCallback:(LDSDKAuthCallback)callBack;

/*!
 *  @brief  退出登陆，主要是QQ平台
 */
- (void)authLogoutPlatformCallback:(LDSDKAuthCallback)callBack;;

@end
