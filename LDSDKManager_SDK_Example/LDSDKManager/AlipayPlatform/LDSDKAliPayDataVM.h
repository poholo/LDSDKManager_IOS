//
// Created by majiancheng on 2018/12/14.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "LDSDKShareDataVMService.h"


@interface LDSDKAliPayDataVM : NSObject <LDSDKShareDataVMService>

@property(nonatomic, strong) MMShareConfigDto *configDto;
@property(nonatomic, strong) NSDictionary *authDict;
@property(nonatomic, strong) NSDictionary *userInfo;

- (NSDictionary *)authParams:(NSString *)result;

@end