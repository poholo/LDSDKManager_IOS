//
// Created by majiancheng on 2018/12/3.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LDSDKShareService.h"
#import "LDSDKShareDataVMService.h"


@interface LDSDKQQServiceImplDataVM : NSObject <LDSDKShareDataVMService>

@property (nonatomic, strong) MMShareConfigDto * configDto;

@end