//
// Created by majiancheng on 2018/12/3.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LDSDKConfig.h"

@class MMBaseShareDto;
@class MMShareConfigDto;

@protocol LDSDKShareDataVMService <NSObject>

@property(nonatomic, strong) MMShareConfigDto *configDto;

- (NSError *)supportContinue:(NSString *)module;

- (BOOL)isPlatformAppInstalled;

@end