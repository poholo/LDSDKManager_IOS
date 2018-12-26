//
// Created by majiancheng on 2018/12/17.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LDSDKShareDataVMService.h"


@interface LDSDKTelegramDataVM : NSObject <LDSDKShareDataVMService>

@property(nonatomic, strong) MMShareConfigDto *configDto;
@property(nonatomic, assign) BOOL registerSuccess;

- (BOOL)share2Telegram:(NSDictionary *)exDict;

@end