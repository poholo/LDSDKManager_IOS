//
// Created by majiancheng on 2018/12/14.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "LDSDKAliPayDataVM.h"

#import <APOpenSdk/APOpenAPIObject.h>

#import "MMShareConfigDto.h"


@implementation LDSDKAliPayDataVM

- (NSError *)registerValidate {
    NSError *error;
    if (self.configDto.appId == nil || self.configDto.appId.length == 0) {
        error = [NSError errorWithDomain:kErrorDomain code:LDSDKErrorCodeCommon userInfo:@{kErrorMessage: @"Alipay appid == NULL"}];
    } else {
        error = [NSError errorWithDomain:kErrorDomain code:LDSDKSuccess userInfo:@{kErrorMessage: @"Alipay reister success"}];
    }
    return error;
}

- (NSError *)supportContinue:(NSString *)module {
    return nil;
}

- (BOOL)isPlatformAppInstalled {
    return NO;
}

- (NSError *)respError:(NSDictionary *)resp {
    NSInteger errorcode = [resp[@"resultStatus"] integerValue];
    NSString *errorMsg = [self errorMsg:errorcode];
    LDSDKLoginCode errorCode = LDSDKLoginFailed;
    if (errorcode == 10000 || errorcode == 9000) {
        errorCode = LDSDKLoginSuccess;
    } else if (errorcode == 20000) {
        errorCode = LDSDKLoginFailed;
    } else if (errorcode == 20001) {
        errorCode = LDSDKLoginNoAuth;
    } else if (errorcode == 40001) {
        errorCode = LDSDKLoginMissParams;
    } else if (errorcode == 40002) {
        errorCode = LDSDKLoginMissParams;
    } else if (errorcode == 40004) {
        errorCode = LDSDKLoginFailed;
    } else if (errorcode == 40006) {
        errorcode = LDSDKLoginNoAuth;
    } else if (errorcode == 4000) {
        errorCode = LDSDKLoginFailed;
    } else if (errorcode == 5000) {
        errorCode = LDSDKLoginFailed;
    } else if (errorcode == 6001) {
        errorCode = LDSDKLoginUserCancel;
    } else if (errorcode == 6002) {
        errorCode = LDSDKLoginNoNet;
    } else if (errorcode == 6004) {
        errorCode = LDSDKLoginFailed;
    }
    NSError *error = [NSError errorWithDomain:kErrorDomain code:errorCode userInfo:@{kErrorMessage: errorMsg ? errorMsg : @""}];
    return error;
}

- (LDSDKErrorCode)errorCodePlatform:(NSInteger)errorcode {
    return LDSDKErrorCodeCommon;
}

- (NSString *)errorMsg:(NSInteger)errorcode {
    if (errorcode == 10000 || errorcode == 9000) {
        return @"success";
    } else if (errorcode == 20000) {
        return @"服务不可用";
    } else if (errorcode == 20001) {
        return @"授权权限不足";
    } else if (errorcode == 40001) {
        return @"缺少必选参数";
    } else if (errorcode == 40002) {
        return @"非法的参数";
    } else if (errorcode == 40004) {
        return @"业务处理失败";
    } else if (errorcode == 40006) {
        return @"权限不足";
    } else if (errorcode == 8000) {
        return @"正在处理中，支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态";
    } else if (errorcode == 4000) {
        return @"订单支付失败";
    } else if (errorcode == 5000) {
        return @"重复请求";
    } else if (errorcode == 6001) {
        return @"用户中途取消";
    } else if (errorcode == 6002) {
        return @"网络连接出错";
    } else if (errorcode == 6004) {
        return @"支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态";
    }

    return nil;
}

- (NSArray<NSString *> *)permissions {
    return nil;
}

- (BOOL)canResponseShareResult:(id)resp {
    return [resp isKindOfClass:[APSendMessageToAPResp class]];
}

- (BOOL)canResponseAuthResult:(id)resp {
    return NO;
}

- (NSDictionary *)wrapAuth:(NSDictionary *)auth {
    NSMutableDictionary *authDict = [NSMutableDictionary new];
    authDict[LDSDK_TOKEN_KEY] = auth[@"sign"];
//    authDict[LDSDK_OPENID_KEY] = auth[@""];
//    authDict[LDSDK_EXPIRADATE_KEY] = auth[@""];
    return authDict;
}

- (NSDictionary *)wrapAuthUserInfo:(id)userinfo {
    return nil;
}

- (NSDictionary *)authParams:(NSString *)result {
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary new];
    NSArray<NSString *> *array = [result componentsSeparatedByString:@"&"];
    for (NSString *value in array) {
        NSArray *subArr = [value componentsSeparatedByString:@"="];
        if (subArr.count == 2) {
            mutableDictionary[subArr.firstObject] = subArr.lastObject;
        }
    }
    return mutableDictionary;
}

@end