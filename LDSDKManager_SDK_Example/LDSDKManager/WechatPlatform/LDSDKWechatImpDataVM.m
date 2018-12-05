//
// Created by majiancheng on 2018/12/5.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <WechatOpenSDK/WXApi.h>
#import "LDSDKWechatImpDataVM.h"


@implementation LDSDKWechatImpDataVM

- (BOOL)isPlatformAppInstalled {
    return [WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi];
}


- (NSError *)supportContinue:(NSString *)module {
    NSError *error;
    if (![WXApi isWXAppInstalled] || ![WXApi isWXAppSupportApi]) {
        error = [NSError errorWithDomain:module
                                    code:0
                                userInfo:@{@"NSLocalizedDescription": @"请先安装Wechat客户端"}];
    }
    return error;
}

- (NSError *)respError:(BaseResp *)resp {
    NSError *error = [NSError errorWithDomain:kErrorDomain
                                         code:resp.errCode
                                     userInfo:@{kErrorCode: @(resp.errCode),
                                             kErrorMessage: resp.errStr,
                                             kErrorObject: resp}];

    return error;
}


@end