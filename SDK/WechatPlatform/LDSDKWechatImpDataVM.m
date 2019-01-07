//
// Created by majiancheng on 2018/12/5.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "LDSDKWechatImpDataVM.h"

#import <WechatOpenSDK/WXApi.h>

#import "NSString+Extend.h"
#import "MCShareConfigDto.h"

NSString *const kWX_NICKNAME_KEY = @"nickname";
NSString *const kWX_AVATARURL_KEY = @"headimgurl";

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

- (NSDictionary *)wrapAuth:(NSDictionary *)auth {
    NSMutableDictionary *authDict = [NSMutableDictionary new];
    authDict[LDSDK_TOKEN_KEY] = auth[@"access_token"];
    authDict[LDSDK_OPENID_KEY] = auth[@"openid"];
    authDict[LDSDK_EXPIRADATE_KEY] = auth[@"expires_in"];
    return authDict;
}

- (NSDictionary *)wrapAuthUserInfo:(NSDictionary *)user {
    NSMutableDictionary *userDict = [NSMutableDictionary new];
    userDict[LDSDK_NICKNAME_KEY] = user[@"nickname"];
    userDict[LDSDK_AVATARURL_KEY] = user[@"headimgurl"];
    userDict[LDSDK_GENDER_KEY] = user[@"sex"];
    userDict[LDSDK_OPENID_KEY] = user[@"openid"];
    userDict[LDSDK_UNION_ID] = user[@"unionid"];
    return userDict;
    /**
     * {
"openid":"OPENID",
"nickname":"NICKNAME",
"sex":1,
"province":"PROVINCE",
"city":"CITY",
"country":"COUNTRY",
"headimgurl": "http://wx.qlogo.cn/mmopen/g3MonUZtNHkdmzicIlibx6iaFqAc56vxLSUfpb6n5WKSYVY0ChQKkiaJSgQ1dZuTOgvLLrhJbERQQ4eMsv84eavHiaiceqxibJxCfHe/0",
"privilege":["PRIVILEGE1","PRIVILEGE2"],
"unionid": " o6_bmasdasdsad6_2sgVt7hMZOPfL"}
     */
}


@end