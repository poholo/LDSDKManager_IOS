//
// Created by majiancheng on 2018/12/5.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LDSDKShareDataVMService.h"


@interface LDSDKWechatImpDataVM : NSObject <LDSDKShareDataVMService>

@property(nonatomic, strong) MCShareConfigDto *configDto;

@property(nonatomic, strong) NSString *code;
@property(nonatomic, strong) NSDictionary *authDict;
@property(nonatomic, strong) NSDictionary *userInfo;
@property(nonatomic, assign) BOOL registerSuccess;

- (NSError *)validateAuthToken:(NSDictionary *)dict;

@end