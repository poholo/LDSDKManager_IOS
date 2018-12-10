//
// Created by majiancheng on 2018/12/6.
// Copyright (c) 2018 majiancheng. All rights reserved.
//


#import "LDSDKWeiboDataVM.h"
#import "NSString+Extend.h"
#import "MMShareConfigDto.h"

#import <Weibo_SDK/WeiboSDK.h>

@implementation LDSDKWeiboDataVM

- (NSError *)registerValidate {
    NSError *error;
    if (self.configDto.appId == nil || self.configDto.appId.length == 0) {
        error = [NSError errorWithDomain:kErrorDomain code:LDSDKErrorCodeCommon userInfo:@{kErrorMessage: @"Weibo appid == NULL"}];
    } else {
        error = [NSError errorWithDomain:kErrorDomain code:LDSDKSuccess userInfo:@{kErrorMessage: @"Weibo reister success"}];
    }
    return error;
}

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
    NSString *errorMsg = [self errorMsg:resp.statusCode];
    NSError *error = [NSError errorWithDomain:kErrorDomain
                                         code:errorCode
                                     userInfo:@{kErrorCode: @(errorCode),
                                             kErrorMessage: [NSString filterInvalid:errorMsg],
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

- (NSString *)errorMsg:(NSInteger)errorcode {
    switch (errorcode) {
        case WeiboSDKResponseStatusCodeSuccess           : {
            return @"成功";
        }
            break;
        case WeiboSDKResponseStatusCodeUserCancel : {
            return @"用户取消";
        }
            break;
        case WeiboSDKResponseStatusCodeShareInSDKFailed: {
            return @"SDK分享失败";
        }
            break;
        case WeiboSDKResponseStatusCodeSentFail   : {
            return @"发送失败";
        }
            break;
        case WeiboSDKResponseStatusCodeAuthDeny   : {
            return @"Auth拒绝";
        }
            break;
        case WeiboSDKResponseStatusCodeUnsupport  : {
            return @"不支持";
        }
            break;
        case WeiboSDKResponseStatusCodePayFail: {
            return @"支付失败";
        }
            break;
    }
    return @"";
}

- (NSArray<NSString *> *)permissions {
    return nil;
}

- (BOOL)canResponseShareResult:(id)resp {
    return [resp isKindOfClass:[WBSendMessageToWeiboResponse class]];
}


@end
