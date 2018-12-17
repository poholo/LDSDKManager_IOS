//
// Created by majiancheng on 2018/12/17.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "LDSDKDingTalkDataVM.h"

#import <DTShareKit-iOS/DTShareKit/DTOpenKit.h>

#import "MMShareConfigDto.h"


@implementation LDSDKDingTalkDataVM

- (NSError *)registerValidate {
    NSError *error;
    if (self.configDto.appId == nil || self.configDto.appId.length == 0) {
        error = [NSError errorWithDomain:kErrorDomain code:LDSDKErrorCodeCommon userInfo:@{kErrorMessage: @"DTalk appid == NULL"}];
    } else {
        error = [NSError errorWithDomain:kErrorDomain code:LDSDKSuccess userInfo:@{kErrorMessage: @"DTalk reister success"}];
    }
    return error;
}

- (NSError *)supportContinue:(NSString *)module {
    return nil;
}

- (BOOL)isPlatformAppInstalled {
    return NO;
}

- (NSError *)respError:(id)resp {
    if ([resp isMemberOfClass:[DTBaseResp class]]) {
        DTBaseResp *dtBaseResp = (DTBaseResp *) resp;
        NSInteger errorcode = [self errorCodePlatform:dtBaseResp.errorCode];
        NSString *errMsg = dtBaseResp.errorMessage ? dtBaseResp.errorMessage : @"";
        NSError *error = [NSError errorWithDomain:kErrorDomain code:errorcode userInfo:@{kErrorMessage: errMsg}];
        return error;
    }
    return nil;
}

- (LDSDKErrorCode)errorCodePlatform:(NSInteger)errorcode {
    switch (errorcode) {
        case DTOpenAPISuccess             : {
            return LDSDKSuccess;
        }
            break;
        case DTOpenAPIErrorCodeCommon     : {
            return LDSDKErrorCodeCommon;
        }
            break;
        case DTOpenAPIErrorCodeUserCancel : {
            return LDSDKErrorCodeUserCancel;
        }
            break;
        case DTOpenAPIErrorCodeSendFail   : {
            return LDSDKErrorCodeSentFail;
        }
            break;
        case DTOpenAPIErrorCodeAuthDeny   : {
            return LDSDKErrorCodeAuthDeny;
        }
            break;
        case DTOpenAPIErrorCodeUnsupport  : {
            return LDSDKErrorCodeUnsupport;
        }
            break;
    }
    return LDSDKErrorCodePayFail;
}

- (NSString *)errorMsg:(NSInteger)errorcode {
    return nil;
}

- (NSArray<NSString *> *)permissions {
    return nil;
}

- (BOOL)canResponseShareResult:(id)resp {
    return [resp isKindOfClass:[DTSendMessageToDingTalkResp class]];
}

- (BOOL)canResponseAuthResult:(id)resp {
    return NO;
}

- (NSDictionary *)wrapAuth:(id)auth {
    return nil;
}

- (NSDictionary *)wrapAuthUserInfo:(id)userinfo {
    return nil;
}

@end