//
// Created by majiancheng on 2018/12/5.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <WechatOpenSDK/WXApi.h>
#import "LDSDKWechatImpDataVM.h"
#import "NSString+Extend.h"
#import "MMShareConfigDto.h"


@implementation LDSDKWechatImpDataVM

- (NSError *)registerValidate {
    NSError *error;
    if (self.configDto.appId == nil || self.configDto.appId.length == 0) {
        error = [NSError errorWithDomain:kErrorDomain code:LDSDKErrorCodeCommon userInfo:@{kErrorMessage: @"Wechat appid == NULL"}];
    } else {
        error = [NSError errorWithDomain:kErrorDomain code:LDSDKSuccess userInfo:@{kErrorMessage: @"Wechat reister success"}];
    }
    return error;
}

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
    LDSDKErrorCode errorCode = [self errorCodePlatform:resp.errCode];
    NSError *error = [NSError errorWithDomain:kErrorDomain
                                         code:errorCode
                                     userInfo:@{kErrorCode: @(errorCode),
                                             kErrorMessage: [NSString filterInvalid:resp.errStr],
                                             kErrorObject: resp}];

    return error;
}

- (LDSDKErrorCode)errorCodePlatform:(NSInteger)errorcode {
    switch (errorcode) {
        case WXSuccess           : {
            return LDSDKSuccess;
        }
            break;
        case WXErrCodeCommon     : {
            return LDSDKErrorCodeCommon;
        }
            break;
        case WXErrCodeUserCancel : {
            return LDSDKErrorCodeUserCancel;
        }
            break;
        case WXErrCodeSentFail   : {
            return LDSDKErrorCodeSentFail;
        }
            break;
        case WXErrCodeAuthDeny   : {
            return LDSDKErrorCodeAuthDeny;
        }
            break;
        case WXErrCodeUnsupport  : {
            return LDSDKErrorCodeUnsupport;
        }
            break;
    }
    return LDSDKErrorUnknow;
}

- (NSArray<NSString *> *)permissions {
    return nil;
}

- (NSString *)errorMsg:(NSInteger)errorcode {
    return nil;
}

- (BOOL)canResponseShareResult:(id)resp {
    return [resp isKindOfClass:[SendMessageToWXResp class]];
}

- (BOOL)canResponseAuthResult:(id)resp {
    return [resp isKindOfClass:[SendAuthResp class]];
}

- (NSError *)validateAuthToken:(NSDictionary *)dict {
    if (dict[@"errcode"]) {
        NSError *error = [NSError errorWithDomain:kErrorDomain code:[dict[@"errcode"] integerValue] userInfo:@{kErrorMessage: dict[@"errmsg"]}];
        return error;
    }
    return nil;
}


@end