//
// Created by majiancheng on 2018/12/17.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LDSDKHandleURLProtocol.h"
#import "LDSDKAuthService.h"
#import "LDSDKRegisterService.h"
#import "LDSDKShareService.h"


@interface LDSDKDingTalkServiceImp : NSObject <LDSDKAuthService, LDSDKRegisterService, LDSDKShareService, LDSDKHandleURLProtocol>

@end