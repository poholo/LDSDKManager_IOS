//
// Created by majiancheng on 2018/12/3.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "LDSDKQQServiceImpDataVM.h"

#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/sdkdef.h>
#import <TencentOpenAPI/TencentOAuth.h>

#import "UIImage+LDExtend.h"
#import "MMBaseShareDto.h"
#import "NSString+Extend.h"
#import "MMShareConfigDto.h"

NSString *const kQQ_OPENID_KEY = @"openId";
NSString *const kQQ_TOKEN_KEY = @"access_token";
NSString *const kQQ_NICKNAME_KEY = @"nickname";
NSString *const kQQ_EXPIRADATE_KEY = @"expirationDate";
NSString *const kQQ_AVATARURL_KEY = @"figureurl_qq_2";


@implementation LDSDKQQServiceImpDataVM

- (BOOL)isPlatformAppInstalled {
    return [QQApiInterface isQQInstalled] && [QQApiInterface isQQSupportApi];
}

- (NSError *)registerValidate {
    NSError *error;
    if (self.configDto.appId == nil || self.configDto.appId.length == 0) {
        error = [NSError errorWithDomain:kErrorDomain code:LDSDKErrorCodeCommon userInfo:@{kErrorMessage: @"QQ appid == NULL"}];
    } else {
        error = [NSError errorWithDomain:kErrorDomain code:LDSDKSuccess userInfo:@{kErrorMessage: @"QQ reister success"}];
    }
    return error;
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

- (NSError *)respError:(QQBaseResp *)resp {
    QQApiSendResultCode code = (QQApiSendResultCode) [resp.result integerValue];
    LDSDKErrorCode errorCode = [self errorCodePlatform:code];
    NSString *errorMsg = resp.errorDescription;
    NSError *error = [NSError errorWithDomain:kErrorDomain
                                         code:errorCode
                                     userInfo:@{kErrorCode: @(errorCode),
                                             kErrorMessage: [NSString filterInvalid:errorMsg],
                                             kErrorObject: resp}];

    return error;
}

- (NSError *)respErrorCode:(NSInteger)code {
    LDSDKErrorCode errorCode = [self errorCodePlatform:code];
    NSString *errorMsg = [self errorMsg:code];
    NSError *error = [NSError errorWithDomain:kErrorDomain
                                         code:errorCode
                                     userInfo:@{kErrorCode: @(errorCode),
                                             kErrorMessage: [NSString filterInvalid:errorMsg],
                                             kErrorObject: @(code)}];

    return error;
}

- (NSArray<NSString *> *)permissions {
    return @[kOPEN_PERMISSION_GET_USER_INFO,
            kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
            kOPEN_PERMISSION_ADD_ALBUM,
            kOPEN_PERMISSION_ADD_ONE_BLOG,
            kOPEN_PERMISSION_ADD_SHARE,
            kOPEN_PERMISSION_ADD_TOPIC,
            kOPEN_PERMISSION_CHECK_PAGE_FANS,
            kOPEN_PERMISSION_GET_INFO,
            kOPEN_PERMISSION_GET_OTHER_INFO,
            kOPEN_PERMISSION_LIST_ALBUM,
            kOPEN_PERMISSION_UPLOAD_PIC,
            kOPEN_PERMISSION_GET_VIP_INFO,
            kOPEN_PERMISSION_GET_VIP_RICH_INFO];
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
        default: {
            return LDSDKErrorCodePayFail;
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
        default: {
            return @"";
        }
            break;
    }
    return @"";
}

- (BOOL)canResponseShareResult:(QQBaseResp *)resp {
    return [resp isKindOfClass:[SendMessageToQQResp class]];
}

- (BOOL)canResponseAuthResult:(id)resp {
    return NO;
}

- (NSDictionary *)wrapAuth:(TencentOAuth *)auth {
    NSMutableDictionary *authDict = [NSMutableDictionary new];
    authDict[LDSDK_TOKEN_KEY] = auth.accessToken;
    authDict[LDSDK_OPENID_KEY] = auth.openId;
    authDict[LDSDK_EXPIRADATE_KEY] = auth.expirationDate;
    return authDict;
}

- (NSDictionary *)wrapAuthUserInfo:(APIResponse *)userinfo {
    /**
     ret": 0,
	"msg": "",
	"is_lost": 0,
	"nickname": "littleplayer",
	"gender": "男",
	"province": "",
	"city": "",
	"year": "1988",
	"constellation": "",
	"figureurl": "http:\/\/qzapp.qlogo.cn\/qzapp\/1101701640\/D393347E8D9CC9FACB08799B7CF9BC18\/30",
	"figureurl_1": "http:\/\/qzapp.qlogo.cn\/qzapp\/1101701640\/D393347E8D9CC9FACB08799B7CF9BC18\/50",
	"figureurl_2": "http:\/\/qzapp.qlogo.cn\/qzapp\/1101701640\/D393347E8D9CC9FACB08799B7CF9BC18\/100",
	"figureurl_qq_1": "http:\/\/thirdqq.qlogo.cn\/qqapp\/1101701640\/D393347E8D9CC9FACB08799B7CF9BC18\/40",
	"figureurl_qq_2": "http:\/\/thirdqq.qlogo.cn\/qqapp\/1101701640\/D393347E8D9CC9FACB08799B7CF9BC18\/100",
	"is_yellow_vip": "0",
	"vip": "0",
	"yellow_vip_level": "0",
	"level": "0",
	"is_yellow_year_vip": "0"
     */
    NSMutableDictionary *userDict = [NSMutableDictionary new];
    NSDictionary *json = userinfo.jsonResponse;
    userDict[LDSDK_NICKNAME_KEY] = json[kQQ_NICKNAME_KEY];
    userDict[LDSDK_AVATARURL_KEY] = json[kQQ_AVATARURL_KEY];
    userDict[LDSDK_GENDER_KEY] = json[kQQ_AVATARURL_KEY];
    return userDict;
}


- (NSString *)arkJson {
    return @"{\"app\": \"LDSDKManager_IOS\", \"view\": \"Share\", \"meta\": \"LDSDKManager_IOS\"}";
}


@end
