//
// Created by majiancheng on 2018/12/14.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "LDSDKShareDataVMService.h"


@interface LDSDKTBDataVM : NSObject <LDSDKShareDataVMService>

@property(nonatomic, strong) MCShareConfigDto *configDto;
@property(nonatomic, strong) NSDictionary *authDict;
@property(nonatomic, strong) NSDictionary *userInfo;
@property(nonatomic, assign) BOOL registerSuccess;

- (NSDictionary *)authParams:(NSString *)result;

@end
