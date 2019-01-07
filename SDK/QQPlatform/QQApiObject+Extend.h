//
// Created by majiancheng on 2018/12/4.
// Copyright (c) 2018 majiancheng. All rights reserved.
//


#import <TencentOpenAPI/QQApiInterface.h>

#import "LDSDKExtendProtocol.h"

@class MCBaseShareDto;

@interface QQApiObject (Extend) <LDSDKExtendProtocol>

+ (QQApiObject *)shareObject:(MCBaseShareDto *)shareDto;

@end