//
// Created by majiancheng on 2018/12/5.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "MCDto.h"

#import "LDSDKConfig.h"


@interface MCResultDto : MCDto

@property(nonatomic, assign) LDSDKErrorCode code;
@property(nonatomic, strong) NSError *error;
@property(nonatomic, strong) id object;

+ (MCResultDto *)createResult:(id)object;

@end