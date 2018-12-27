//
// Created by majiancheng on 2018/12/12.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "MCShareNewsDto.h"


@interface MCShareMiniProgramDto : MCShareNewsDto

@property(nonatomic, strong) NSString *miniProgramId;
@property(nonatomic, assign) LDSDKMiniProgramType miniProgramType;

@end