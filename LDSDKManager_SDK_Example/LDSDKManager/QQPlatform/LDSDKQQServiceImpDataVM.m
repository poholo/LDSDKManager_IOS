//
// Created by majiancheng on 2018/12/3.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "LDSDKQQServiceImpDataVM.h"

#import <TencentOpenAPI/QQApiInterface.h>

#import "UIImage+LDExtend.h"
#import "MMBaseShareDto.h"
#import "sdkdef.h"


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

- (NSError *)respError:(NSNumber *)resp {
    QQApiSendResultCode code = (QQApiSendResultCode) resp.integerValue;
    LDSDKErrorCode errorCode = [self errorCodePlatform:code];
    NSString *errorMsg = [self errorMsg:code];
    NSError *error = [NSError errorWithDomain:kErrorDomain
                                         code:errorCode
                                     userInfo:@{kErrorCode: @(errorCode),
                                             kErrorMessage: errorMsg,
                                             kErrorObject: resp}];

    return error;
}

- (NSInteger)moduleToPlatform:(LDSDKShareToModule)module {
    switch (module) {
        case LDSDKShareToTimeLine: {

        }
            break;
        case LDSDKShareToContact: {

        }
            break;
        case LDSDKShareToOther: {

        }
            break;
    }

    return 0;
}


- (NSArray<NSString *> *)permissions {
    return @[kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO];
}


- (LDSDKErrorCode)errorCodePlatform:(NSInteger)errorcode {
    QQApiSendResultCode qqErrorCode = (QQApiSendResultCode) errorcode;
    switch (qqErrorCode) {
        case EQQAPISENDSUCESS : {
            return LDSDKSuccess;
        }
            break;
        case EQQAPIQQNOTINSTALLED  : {
            return LDSDKErrorUninstallPlatformApp;
        }
            break;
        case EQQAPIQQNOTSUPPORTAPI  : {
            return LDSDKErrorCodeUnsupport;
        }
            break;
        case EQQAPIMESSAGETYPEINVALID  : {
            return LDSDKErrorCodeUnsupport;
        }
            break;
        case EQQAPIMESSAGECONTENTNULL  : {
            return LDSDKErrorCodeCommon;
        }
            break;
        case EQQAPIMESSAGECONTENTINVALID: {
            return LDSDKErrorCodeCommon;
        }
            break;
        case EQQAPIAPPNOTREGISTED : {
            return LDSDKErrorCodeCommon;
        }
            break;
        case EQQAPIAPPSHAREASYNC : {
            return LDSDKErrorCodeCommon;
        }
            break;
        case EQQAPIMESSAGEARKCONTENTNULL: {
            return LDSDKErrorCodeCommon;
        }
            break;
        case EQQAPISENDFAILD : {
            return LDSDKErrorCodeSentFail;
        }
            break;
        case EQQAPISHAREDESTUNKNOWN : {
            return LDSDKErrorUnknow;
        }
            break;
        case EQQAPITIMSENDFAILD  : {
            return LDSDKErrorCodeSentFail;
        }
            break;
        case EQQAPITIMNOTINSTALLED : {
            return LDSDKErrorUninstallPlatformApp;
        }
            break;
        case EQQAPITIMNOTSUPPORTAPI : {
            return LDSDKErrorCodeUnsupport;
        }
            break;
        case EQQAPIQZONENOTSUPPORTTEXT : {
            return LDSDKErrorCodeUnsupport;
        }
            break;
        case EQQAPIQZONENOTSUPPORTIMAGE : {
            return LDSDKErrorCodeUnsupport;
        }
            break;
        case EQQAPIVERSIONNEEDUPDATE : {
            return LDSDKErrorCodeUnsupport;
        }
            break;
        case ETIMAPIVERSIONNEEDUPDATE : {
            return LDSDKErrorCodeUnsupport;
        }
            break;
    }
    return LDSDKErrorCodePayFail;
}

- (NSString *)errorMsg:(NSInteger)errorcode {
    QQApiSendResultCode qqErrorCode = (QQApiSendResultCode) errorcode;
    switch (qqErrorCode) {
        case EQQAPISENDSUCESS : {
            return @"成功";
        }
            break;
        case EQQAPIQQNOTINSTALLED  : {
            return @"QQ未安装";
        }
            break;
        case EQQAPIQQNOTSUPPORTAPI  : {
            return @"QQ api不支持";
        }
            break;
        case EQQAPIMESSAGETYPEINVALID  : {
            return @"无效";
        }
            break;
        case EQQAPIMESSAGECONTENTNULL  : {
            return @"内容为空";
        }
            break;
        case EQQAPIMESSAGECONTENTINVALID: {
            return @"内容无效";
        }
            break;
        case EQQAPIAPPNOTREGISTED : {
            return @"没有注册的app";
        }
            break;
        case EQQAPIAPPSHAREASYNC : {
            return @"异步分享";
        }
            break;
        case EQQAPIMESSAGEARKCONTENTNULL: {
            return @"ark内容为空";
        }
            break;
        case EQQAPISENDFAILD : {
            return @"发送失败";
        }
            break;
        case EQQAPISHAREDESTUNKNOWN : {
            return @"未指定分享到QQ或者TIM";
        }
            break;
        case EQQAPITIMSENDFAILD  : {
            return @"TIM发送失败";
        }
            break;
        case EQQAPITIMNOTINSTALLED : {
            return @"TIM未安装";
        }
            break;
        case EQQAPITIMNOTSUPPORTAPI : {
            return @"TIM不支持的API";
        }
            break;
        case EQQAPIQZONENOTSUPPORTTEXT : {
            return @"QQZone不支持文本";
        }
            break;
        case EQQAPIQZONENOTSUPPORTIMAGE : {
            return @"QQ空间不支持图片";
        }
            break;
        case EQQAPIVERSIONNEEDUPDATE : {
            return @"QQ版本需要更新";
        }
            break;
        case ETIMAPIVERSIONNEEDUPDATE : {
            return @"TIM版本需要更新";
        }
            break;
    }
    return @"";
}


@end
