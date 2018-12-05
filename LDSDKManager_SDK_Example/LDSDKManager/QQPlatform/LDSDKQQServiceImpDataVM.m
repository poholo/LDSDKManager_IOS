//
// Created by majiancheng on 2018/12/3.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "LDSDKQQServiceImpDataVM.h"
#import "UIImage+LDExtend.h"
#import "MMBaseShareDto.h"

#import <TencentOpenAPI/QQApiInterface.h>


@implementation LDSDKQQServiceImpDataVM

- (BOOL)isPlatformAppInstalled {
    return [QQApiInterface isQQInstalled] && [QQApiInterface isQQSupportApi];
}


- (NSError *)supportContinue:(NSString *)module {
    NSError *error;
    if (![QQApiInterface isQQInstalled] || ![QQApiInterface isQQSupportApi]) {
        error = [NSError errorWithDomain:module
                                    code:0
                                userInfo:@{@"NSLocalizedDescription": @"请先安装QQ客户端"}];
    }
    return error;
}


@end