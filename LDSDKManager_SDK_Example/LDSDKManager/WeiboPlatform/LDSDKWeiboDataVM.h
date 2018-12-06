//
// Created by majiancheng on 2018/12/6.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LDSDKShareDataVMService.h"


@interface LDSDKWeiboDataVM : NSObject <LDSDKShareDataVMService>

@property(nonatomic, strong) MMShareConfigDto *configDto;

@end