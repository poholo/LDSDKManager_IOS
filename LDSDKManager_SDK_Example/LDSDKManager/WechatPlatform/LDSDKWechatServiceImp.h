//
//  LDSDKWechatServiceImp.h
//  Pods
//
//  Created by yangning on 15-1-29.
//
//

/***
 * 1. 微信分享取消的时候回调是0 - success [官方bug] 导致分享回调无法确认到达率。
 *
 */

#import <Foundation/Foundation.h>
#import "LDSDKAuthService.h"
#import "LDSDKRegisterService.h"
#import "LDSDKPayService.h"
#import "LDSDKShareService.h"
#import "LDSDKHandleURLProtocol.h"

@class BaseReq;
@class BaseResp;

typedef void (^LDSDKWXCallbackBlock)(BaseResp *resp);

@interface LDSDKWechatServiceImp : NSObject <LDSDKAuthService, LDSDKRegisterService, LDSDKShareService, LDSDKPayService, LDSDKHandleURLProtocol>

@end
