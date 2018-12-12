//
// Created by majiancheng on 2018/12/5.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LDSDKShareDataVMService.h"


@interface LDSDKWechatImpDataVM : NSObject <LDSDKShareDataVMService>

@property(nonatomic, strong) MMShareConfigDto *configDto;

@property(nonatomic, strong) NSString *code;
@property(nonatomic, strong) NSDictionary *authDict;
@property(nonatomic, strong) NSDictionary *userInfo;

- (NSError *)validateAuthToken:(NSDictionary *)dict;

@end