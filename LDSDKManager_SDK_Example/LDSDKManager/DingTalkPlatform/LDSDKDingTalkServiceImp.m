//
// Created by majiancheng on 2018/12/17.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "LDSDKDingTalkServiceImp.h"

#import <DTShareKit-iOS/DTShareKit/DTOpenKit.h>

#import "LDSDKDingTalkDataVM.h"
#import "MMShareConfigDto.h"
#import "MMBaseShareDto.h"
#import "DTBaseReq+Extend.h"

@interface LDSDKDingTalkServiceImp () <DTOpenAPIDelegate>

@property(nonatomic, copy) LDSDKShareCallback shareCallback;
@property(nonatomic, copy) LDSDKAuthCallback authCallback;
@property(nonatomic, strong) LDSDKDingTalkDataVM *dataVM;

@end

@implementation LDSDKDingTalkServiceImp

- (void)authPlatformCallback:(LDSDKAuthCallback)callback ext:(NSDictionary *)extDict {

}

- (void)authPlatformQRCallback:(LDSDKAuthCallback)callback ext:(NSDictionary *)extDict {

}

- (void)authLogoutPlatformCallback:(LDSDKAuthCallback)callBack {

}

- (BOOL)isPlatformAppInstalled {
    return NO;
}

- (NSError *)registerWithPlatformConfig:(NSDictionary *)config {
    self.dataVM.configDto = [MMShareConfigDto createDto:config];
    [DTOpenAPI registerApp:self.dataVM.configDto.appId];
    NSError *error = [self.dataVM registerValidate];
    return error;
}

- (BOOL)isRegistered {
    return NO;
}

- (BOOL)handleResultUrl:(NSURL *)url {
    return NO;
}

- (void)shareContent:(NSDictionary *)exDict {
    NSError *error = [self.dataVM supportContinue:@"DingTalk"];
    LDSDKShareCallback callback = exDict[LDSDKShareCallBackKey];
    if (error) {
        if (callback) {
            callback(LDSDKErrorUninstallPlatformApp, error);
        }
        return;
    }
    self.shareCallback = callback;
    MMBaseShareDto *shareDto = [MMBaseShareDto factoryCreateShareDto:exDict];
    DTBaseReq *req = [DTBaseReq shareObject:shareDto];
    if (!shareDto || !req) {
        if (self.shareCallback) {
            NSError *err = [NSError errorWithDomain:kErrorDomain code:LDSDKErrorCodeUnsupport userInfo:@{kErrorMessage: @"Not support: check params"}];
            self.shareCallback(LDSDKErrorCodeUnsupport, err);
        }
        return;
    }

    BOOL success = [DTOpenAPI sendReq:req];

    if (!success) {
        error = [NSError errorWithDomain:kErrorDomain code:LDSDKErrorCodeCommon userInfo:@{kErrorMessage: @"req failed"}];
        if (self.shareCallback) {
            self.shareCallback((LDSDKErrorCode) error.code, error);
        }
    }
}

- (BOOL)responseResult:(id)resp {
    if ([self.dataVM canResponseShareResult:resp]) {
        NSError *error = [self.dataVM respError:resp];
        if (self.shareCallback) {
            self.shareCallback((LDSDKErrorCode) error.code, error);
        }
        return YES;
    }
    return NO;
}

- (BOOL)handleURL:(NSURL *)url {
    return [DTOpenAPI handleOpenURL:url delegate:self];
}

#pragma mark - DTOpenAPIDelegate

- (void)onReq:(DTBaseReq *)req {

}

- (void)onResp:(DTBaseResp *)resp {
    if ([self responseResult:resp]) {
        return;
    }
//    if ([resp isKindOfClass:[DTAuthorizeResp class]]) {
//        DTAuthorizeResp *authResp = (DTAuthorizeResp *)resp;
//        NSString *accessCode = authResp.accessCode;
//        [self showAlertTitle:@"授权登录"
//                     message:[NSString stringWithFormat:@"accessCode: %@, errorCode: %@, errorMsg: %@", accessCode, @(resp.errorCode), resp.errorMessage]];
//    }
}


#pragma mark  - getter

- (LDSDKDingTalkDataVM *)dataVM {
    if (!_dataVM) {
        _dataVM = [LDSDKDingTalkDataVM new];
    }
    return _dataVM;
}

@end