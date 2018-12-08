//
//  LDSDKQQServiceImp.h
//  TestThirdPlatform
//
//  Created by ss on 15/8/17.
//  Copyright (c) 2015年 Lede. All rights reserved.
//

/***
 * qq 空间视频分享只支持本地相册视频
 */
#import <Foundation/Foundation.h>

#import "LDSDKAuthService.h"
#import "LDSDKRegisterService.h"
#import "LDSDKShareService.h"
#import "LDSDKHandleURLProtocol.h"

@class QQBaseReq;
@class QQBaseResp;

typedef void (^LDSDKQQCallbackBlock)(QQBaseResp *resp);

@interface LDSDKQQServiceImp : NSObject <LDSDKAuthService, LDSDKRegisterService, LDSDKShareService, LDSDKHandleURLProtocol>

@end
