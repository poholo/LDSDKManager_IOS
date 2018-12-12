//
// Created by majiancheng on 2018/12/4.
// Copyright (c) 2018 majiancheng. All rights reserved.
//


#import <TencentOpenAPI/QQApiInterface.h>

#import "LDSDKExtendProtocol.h"

@class MMBaseShareDto;

@interface QQApiObject (Extend) <LDSDKExtendProtocol>

+ (QQApiObject *)shareObject:(MMBaseShareDto *)shareDto;

@end