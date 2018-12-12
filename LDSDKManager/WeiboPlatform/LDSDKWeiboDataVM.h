//
// Created by majiancheng on 2018/12/6.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LDSDKShareDataVMService.h"


@interface LDSDKWeiboDataVM : NSObject <LDSDKShareDataVMService>

@property(strong, nonatomic) NSString *token;
@property(strong, nonatomic) NSString *userId;

@property(nonatomic, strong) MMShareConfigDto *configDto;
@property(nonatomic, strong) NSDictionary *authDict;
@property(nonatomic, strong) NSDictionary *userInfo;

- (NSError *)validateAuthToken:(NSDictionary *)dict;

@end