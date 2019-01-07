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

- (void)authPlatformCallback:(LDSDKAuthCallback)callback ext:(NSDictionary *)extDict;

- (void)authPlatformQRCallback:(LDSDKAuthCallback)callback ext:(NSDictionary *)extDict;;

- (void)authLogoutPlatformCallback:(LDSDKAuthCallback)callBack;

@end
