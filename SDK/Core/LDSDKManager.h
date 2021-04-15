//
//  LDSDKManager.h
//  LDSDKManager
//
//  Created by ss on 15/8/25.
//  Copyright (c) 2015年 张海洋. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LDSDKConfig.h"
#import "LDSDKHandleURLProtocol.h"

@protocol LDSDKShareService;
@protocol LDSDKAuthService;
@protocol LDSDKPayService;


@interface LDSDKManager : NSObject <LDSDKHandleURLProtocol>

+ (instancetype)share;

/**
 *  根据配置列表依次注册第三方SDK
 *
 *  @return YES则配置成功
 */
- (void)registerWithPlatformConfigList:(NSArray *)configList;

/*!
 *  @brief  获取配置服务
 *
 *  @return 服务实例
 */
- (id <LDSDKShareService>)registerService:(LDSDKPlatformType)type;

/*!
 *  @brief  获取登陆服务
 *
 *  @return 服务实例
 */
- (id <LDSDKAuthService>)authService:(LDSDKPlatformType)type;

/*!
 *  @brief  获取分享服务
 *
 *  @return 服务实例
 */
- (id <LDSDKShareService>)shareService:(LDSDKPlatformType)type;

/*!
 *  @brief  获取支付服务
 *
 *  @return 服务实例
 */
- (id <LDSDKPayService>)payService:(LDSDKPlatformType)type;


/*!
 *  @brief  统一处理各个SDK的回调
 *
 *  @param url 回调URL
 *
 *  @return 处理成功返回YES，否则返回NO
 */
- (BOOL)handleURL:(NSURL *)url;

/*!
 * @brief 微信1.8.7.1回调
 * @praram activity
 *  @return Boolean
 */
- (BOOL)handleActivity:(NSUserActivity *)activity;

@end
