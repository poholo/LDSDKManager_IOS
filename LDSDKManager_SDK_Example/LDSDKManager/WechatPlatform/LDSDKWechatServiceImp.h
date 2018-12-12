//
//  LDSDKWechatServiceImp.h
//  Pods
//
//  Created by yangning on 15-1-29.
//
//

/***
 * 1. 微信分享取消的时候回调是0 - success [官方bug] 导致分享回调无法确认到达率。
 * 2. 支持一下小程序分享
 * 3. 扫码登录 https://open.weixin.qq.com/connect/qrconnect?appid=wxbdc5610cc59c1631&redirect_uri=https%3A%2F%2Fpassport.yhd.com%2Fwechat%2Fcallback.do&response_type=code&scope=snsapi_login&state=3d6be0a4035d839573b04816624a415e#wechat_redirect
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
