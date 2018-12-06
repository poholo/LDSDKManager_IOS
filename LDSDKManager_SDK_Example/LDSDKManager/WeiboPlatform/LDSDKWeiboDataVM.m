//
// Created by majiancheng on 2018/12/6.
// Copyright (c) 2018 majiancheng. All rights reserved.
//


#import "LDSDKWeiboDataVM.h"

#import <Weibo_SDK/WeiboSDK.h>

@implementation LDSDKWeiboDataVM

- (BOOL)isPlatformAppInstalled {
    return [WeiboSDK isWeiboAppInstalled] && [WeiboSDK isCanShareInWeiboAPP];
}


- (NSError *)supportContinue:(NSString *)module {
    NSError *error;
    if (![WeiboSDK isWeiboAppInstalled] || ![WeiboSDK isCanShareInWeiboAPP]) {
        error = [NSError errorWithDomain:module
                                    code:0
                                userInfo:@{@"NSLocalizedDescription": @"请先安装微博客户端"}];
    }
    return error;
}

- (NSError *)respError:(WBBaseResponse *)resp {
    LDSDKErrorCode errorCode = [self errorCodePlatform:resp.statusCode];
    NSError *error = [NSError errorWithDomain:kErrorDomain
                                         code:errorCode
                                     userInfo:@{kErrorCode: @(errorCode),
                                             kErrorMessage: @"", //TODO:: weibo error info
                                             kErrorObject: resp}];

    return error;
}

- (LDSDKErrorCode)errorCodePlatform:(NSInteger)errorcode {
    switch (errorcode) {
        case WeiboSDKResponseStatusCodeSuccess           : {
            return LDSDKSuccess;
        }
            break;
        case WeiboSDKResponseStatusCodeUserCancel : {
            return LDSDKErrorCodeUserCancel;
        }
            break;
        case WeiboSDKResponseStatusCodeShareInSDKFailed:
        case WeiboSDKResponseStatusCodeSentFail   : {
            return LDSDKErrorCodeSentFail;
        }
            break;
        case WeiboSDKResponseStatusCodeAuthDeny   : {
            return LDSDKErrorCodeAuthDeny;
        }
            break;
        case WeiboSDKResponseStatusCodeUnsupport  : {
            return LDSDKErrorCodeUnsupport;
        }
            break;
        case WeiboSDKResponseStatusCodePayFail: {
            return LDSDKErrorCodePayFail;
        }
            break;
    }
    return LDSDKErrorUnknow;
}

@end