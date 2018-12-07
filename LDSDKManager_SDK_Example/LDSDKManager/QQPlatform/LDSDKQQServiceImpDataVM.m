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

- (NSError *)respError:(id)resp {
    LDSDKErrorCode errorCode = [self errorCodePlatform:resp];
    NSError *error = [NSError errorWithDomain:kErrorDomain
                                         code:errorCode
                                     userInfo:@{kErrorCode: @(errorCode),
                                             kErrorMessage: @"",
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


@end
