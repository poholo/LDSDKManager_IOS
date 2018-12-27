//
// Created by majiancheng on 2018/12/6.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LDSDKShareDataVMService.h"


@interface LDSDKWeiboDataVM : NSObject <LDSDKShareDataVMService>

@property(strong, nonatomic) NSString *token;
@property(strong, nonatomic) NSString *userId;

@property(nonatomic, strong) MCShareConfigDto *configDto;
@property(nonatomic, strong) NSDictionary *authDict;
@property(nonatomic, strong) NSDictionary *userInfo;
@property(nonatomic, assign) BOOL registerSuccess;

- (NSError *)validateAuthToken:(NSDictionary *)dict;

@end