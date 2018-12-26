//
// Created by majiancheng on 2018/12/4.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "MMDto.h"

#import "LDSDKConfig.h"


@interface MMShareConfigDto : MMDto

@property(nonatomic, strong) NSString *appId;
@property(nonatomic, strong) NSString *appSecret;
@property(nonatomic, strong) NSString *appSchema;
@property(nonatomic, assign) LDSDKPlatformType appPlatformType;
@property(nonatomic, strong) NSString *appDesc;
@property(nonatomic, strong) NSString *redirectURI;

- (NSDictionary *)dict;

@end