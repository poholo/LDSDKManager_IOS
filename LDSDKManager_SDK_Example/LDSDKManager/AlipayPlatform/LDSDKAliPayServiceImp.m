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
#import "MMBaseShareDto.h"
#import "LDSDKExtendProtocol.h"
#import "APBaseReq+Extend.h"
#import "APOpenAPI.h"
#import "MMShareConfigDto.h"

@interface LDSDKAliPayServiceImp () <APOpenAPIDelegate>

@property(nonatomic, strong) LDSDKAliPayDataVM *dataVM;
@property(strong, nonatomic) NSString *aliPayScheme;

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
    self.dataVM.configDto = [MMShareConfigDto createDto:config];
    NSError *error = [self.dataVM registerValidate];
    BOOL success = [APOpenAPI registerApp:self.dataVM.configDto.appId];
    if (!success) {
        error = [NSError errorWithDomain:kErrorDomain code:LDSDKErrorCodeCommon userInfo:@{kErrorMessage: @"AlipayShare register error"}];
    }
    return error;
}

- (BOOL)isRegistered {
    return (self.aliPayScheme && [self.aliPayScheme length]);
}

- (BOOL)handleResultUrl:(NSURL *)url {
    return [self payProcessOrderWithPaymentResult:url standbyCallback:NULL];
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
    MMBaseShareDto *shareDto = [MMBaseShareDto factoryCreateShareDto:exDict];

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
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDict) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf processAuth_V2Next:resultDict];
        }];
    }
    return handle;
}



#pragma mark -
#pragma mark -  支付部分

- (void)payOrder:(NSString *)orderString callback:(LDSDKPayCallback)callback {
    NSLog(@"AliPay");
    [self alipayOrder:orderString callback:callback];
}

- (BOOL)payProcessOrderWithPaymentResult:(NSURL *)url
                         standbyCallback:(void (^)(NSDictionary *))callback {
    if ([url.scheme.lowercaseString isEqualToString:self.aliPayScheme]) {
        [self aliPayProcessOrderWithPaymentResult:url standbyCallback:callback];
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - alipay

- (void)alipayOrder:(NSString *)orderString callback:(LDSDKPayCallback)callback {
    [[AlipaySDK defaultService]
            payOrder:orderString
          fromScheme:self.aliPayScheme
            callback:^(NSDictionary *resultDic) {
                NSString *signString = resultDic[@"result"];
                NSString *memo = resultDic[@"memo"];
                NSInteger resultStatus = [resultDic[@"resultStatus"] integerValue];
                if (callback) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (resultStatus == 9000) {
                            callback(signString, nil);
                        } else {
                            NSError *error = [NSError errorWithDomain:@"AliPay"
                                                                 code:0
                                                             userInfo:@{@"NSLocalizedDescription": memo}];
                            callback(signString, error);
                        }

                    });
                }
            }];
}

- (void)aliPayProcessOrderWithPaymentResult:(NSURL *)url
                            standbyCallback:(void (^)(NSDictionary *resultDic))callback {
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:callback];
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
