//
//  LDSDKAliPayServiceImp.m
//  LDSDKManager
//
//  Created by ss on 15/8/21.
//  Copyright (c) 2015年 张海洋. All rights reserved.
//

#import "LDSDKAliPayServiceImp.h"

#import <AlipaySDK/AlipaySDK.h>
#import <APOpenSdk/APOpenAPIObject.h>

#import "LDSDKConfig.h"
#import "LDSDKAliPayDataVM.h"
#import "MCBaseShareDto.h"
#import "LDSDKExtendProtocol.h"
#import "APBaseReq+Extend.h"
#import "APOpenAPI.h"
#import "MCShareConfigDto.h"

@interface LDSDKAliPayServiceImp () <APOpenAPIDelegate>

@property(nonatomic, strong) LDSDKAliPayDataVM *dataVM;

@property(nonatomic, copy) LDSDKShareCallback shareCallback;
@property(nonatomic, copy) LDSDKAuthCallback authCallback;
@property(nonatomic, copy) LDSDKPayCallback payCallBack;

@end

@implementation LDSDKAliPayServiceImp


#pragma mark -
#pragma mark - 配置部分

- (BOOL)isPlatformAppInstalled {
    return YES;
}


- (NSError *)registerWithPlatformConfig:(NSDictionary *)config {
    self.dataVM.configDto = [MCShareConfigDto createDto:config];
    NSError *error = [self.dataVM registerValidate];
    BOOL success = [APOpenAPI registerApp:self.dataVM.configDto.appId];
    if (!success) {
        error = [NSError errorWithDomain:kErrorDomain code:LDSDKErrorCodeCommon userInfo:@{kErrorMessage: @"AlipayShare register error"}];
    }
    if (error.code != LDSDKSuccess) {
        self.dataVM.registerSuccess = NO;
    } else {
        self.dataVM.registerSuccess = YES;
    }
    return error;
}

- (BOOL)isRegistered {
    return self.dataVM.registerSuccess;
}


#pragma mark - share

- (void)shareContent:(NSDictionary *)exDict {
    NSError *error = [self.dataVM supportContinue:@"AlipayShare"];
    LDSDKShareCallback callback = exDict[LDSDKShareCallBackKey];
    if (error) {
        if (callback) {
            callback(LDSDKErrorUninstallPlatformApp, error);
        }
        return;
    }
    self.shareCallback = callback;
    MCBaseShareDto *shareDto = [MCBaseShareDto factoryCreateShareDto:exDict];

    APBaseReq *apMediaMessage = [APBaseReq shareObject:shareDto];

    if (!shareDto || !apMediaMessage) {
        if (self.shareCallback) {
            NSError *err = [NSError errorWithDomain:kErrorDomain code:LDSDKErrorCodeUnsupport userInfo:@{kErrorMessage: @"Not support: check params"}];
            self.shareCallback(LDSDKErrorCodeUnsupport, err);
        }
        return;
    }

    BOOL success = [APOpenAPI sendReq:apMediaMessage];
    if (!success) {
        error = [NSError errorWithDomain:kErrorDomain code:LDSDKErrorCodeCommon userInfo:@{kErrorMessage: @"初始化请求失败"}];
        if (self.shareCallback) {
            self.shareCallback((LDSDKErrorCode) error.code, error);
        }
    }
}

- (BOOL)responseResult:(APBaseResp *)resp {
    if ([resp isKindOfClass:[APSendMessageToAPResp class]]) {
        APSendMessageToAPResp *response = (APSendMessageToAPResp *) resp;
        NSError *error = [self.dataVM respError:resp];
        if (self.shareCallback) {
            self.shareCallback((LDSDKErrorCode) error.code, error);
        }
        return YES;
    }
    return NO;
}


#pragma mark - auth

- (void)authPlatformCallback:(LDSDKAuthCallback)callback ext:(NSDictionary *)extDict {
    NSString *authUrl = extDict[LDSDKAuthUrlKey];
    NSString *authSchema = extDict[LDSDKAuthSchemaKey];
    if (authUrl.length == 0 || authSchema.length == 0) {
        NSError *error = [NSError errorWithDomain:kErrorDomain code:LDSDKLoginFailed userInfo:@{kErrorMessage: @"Miss authurl or schema"}];
        if (callback) {
            callback(LDSDKLoginFailed, error, nil, nil);
        }
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[AlipaySDK defaultService] auth_V2WithInfo:authUrl fromScheme:authSchema callback:^(NSDictionary *resultDict) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf processAuth_V2Next:resultDict];
    }];
}

- (void)authPlatformQRCallback:(LDSDKAuthCallback)callback ext:(NSDictionary *)extDict {

}


- (void)authLogoutPlatformCallback:(LDSDKAuthCallback)callBack {
    self.authCallback = callBack;
    if (!self.dataVM.authDict) {
        if (self.authCallback) {
            self.authCallback(LDSDKLoginSuccess, nil, nil, nil);
        }
    } else {
        self.dataVM.authDict = nil;
        if (self.authCallback) {
            self.authCallback(LDSDKLoginSuccess, nil, nil, nil);
        }
    }
}


- (void)processAuth_V2Next:(NSDictionary *)resultDict {
//    NSInteger status = [resultDict[@"resultStatus"] integerValue];
    NSDictionary *params = [self.dataVM authParams:resultDict[@"result"]];
//    BOOL statusResult = [params[@"success"] boolValue];
    NSError *error = [self.dataVM respError:resultDict];
    self.dataVM.authDict = [self.dataVM wrapAuth:params];
    if (self.authCallback) {
        self.authCallback((LDSDKLoginCode) error.code, error, self.dataVM.authDict, self.dataVM.userInfo);
    }
}


- (BOOL)handleURL:(NSURL *)url {
    BOOL handle = [APOpenAPI handleOpenURL:url delegate:self];
    if (!handle) {
        __weak typeof(self) weakSelf = self;
        if ([url.host isEqualToString:@"safepay"]) {
            return [self payProcessOrderWithPaymentResult:url standbyCallback:NULL];
        } else {
            [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDict) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf processAuth_V2Next:resultDict];
            }];
        }
    }
    return handle;
}

#pragma mark -
#pragma mark -  支付部分

- (void)payOrder:(NSString *)orderString callback:(LDSDKPayCallback)callback {
    self.payCallBack = callback;
    [self alipayOrder:orderString callback:callback];
}

- (BOOL)payProcessOrderWithPaymentResult:(NSURL *)url
                         standbyCallback:(void (^)(NSDictionary *))callback {
    if ([url.scheme.lowercaseString isEqualToString:self.dataVM.configDto.appSchema]) {
        [self aliPayProcessOrderWithPaymentResult:url standbyCallback:callback];
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - alipay

- (void)alipayOrder:(NSString *)orderString callback:(LDSDKPayCallback)callback {
    __weak typeof(self) weakSelf = self;
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:self.dataVM.configDto.appSchema callback:^(NSDictionary *resultDic) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf __processAlipayNext:resultDic];
    }];
}

- (void)aliPayProcessOrderWithPaymentResult:(NSURL *)url
                            standbyCallback:(void (^)(NSDictionary *resultDic))callback {
    __weak typeof(self) weakSelf = self;
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *dict) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf __processAlipayNext:dict];
    }];
}

- (void)__processAlipayNext:(NSDictionary *)resultDict {
    NSDictionary *params = [self.dataVM authParams:resultDict[@"result"]];
    NSInteger status = [params[@"resultStatus"] integerValue];

    if (self.payCallBack) {
        __weak typeof(self) weakSelf = self;
        [self mainExecute:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (status == 9000) {
                self.payCallBack(resultDict, nil);
            } else {
                NSError *error = [NSError errorWithDomain:@"AliPay"
                                                     code:0
                                                 userInfo:@{@"NSLocalizedDescription": @"支付失败"}];
                strongSelf.payCallBack(resultDict, error);
            }
        }];
    }
}


- (void)mainExecute:(dispatch_block_t)block {
    if ([NSThread isMainThread]) {
        if (block) {
            block();
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block();
            }
        });
    }
}


#pragma mark -

- (void)onReq:(APBaseReq *)req {

}

- (void)onResp:(APBaseResp *)resp {
    if ([self.dataVM canResponseShareResult:resp] && [self responseResult:resp]) {
        return;
    }
}

#pragma mark - getter

- (LDSDKAliPayDataVM *)dataVM {
    if (!_dataVM) {
        _dataVM = [LDSDKAliPayDataVM new];
    }
    return _dataVM;
}
@end
