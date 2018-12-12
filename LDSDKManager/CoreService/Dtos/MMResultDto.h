//
// Created by majiancheng on 2018/12/5.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "MMDto.h"

#import "LDSDKConfig.h"


@interface MMResultDto : MMDto

@property(nonatomic, assign) LDSDKErrorCode code;
@property(nonatomic, strong) NSError *error;
@property(nonatomic, strong) id object;

+ (MMResultDto *)createResult:(id)object;

@end