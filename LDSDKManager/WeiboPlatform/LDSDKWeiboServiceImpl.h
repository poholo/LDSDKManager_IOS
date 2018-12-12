//
//  LDSDKWeiboServiceImpl.h
//  LDSDKManager
//
//  Created by ss on 15/9/1.
//  Copyright (c) 2015年 张海洋. All rights reserved.
//

/***
 * 微博的视频分享到故事和timeline但必须是本地视频 !必须支持打开相册的info属性否则崩溃
 */

#import "LDSDKRegisterService.h"
#import "LDSDKShareService.h"
#import "LDSDKHandleURLProtocol.h"
#import "LDSDKAuthService.h"

@interface LDSDKWeiboServiceImpl : NSObject <LDSDKRegisterService, LDSDKShareService, LDSDKAuthService, LDSDKHandleURLProtocol>

@end
