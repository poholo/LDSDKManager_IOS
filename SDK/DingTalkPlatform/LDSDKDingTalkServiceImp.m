//
// Created by majiancheng on 2018/12/17.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "LDSDKDingTalkServiceImp.h"

#import <DTShareKit/DTOpenKit.h>

#import "LDSDKDingTalkDataVM.h"
#import "MCShareConfigDto.h"
#import "MCBaseShareDto.h"
#import "DTBaseReq+Extend.h"

@interface LDSDKDingTalkServiceImp () <DTOpenAPIDelegate>

@property(nonatomic, copy) LDSDKShareCallback shareCallback;
@property(nonatomic, copy) LDSDKAuthCallback authCallback;
@property(nonatomic, strong) LDSDKDingTalkDataVM *dataVM;

@end

@implementation LDSDKDingTalkServiceImp

- (void)authPlatformCallback:(LDSDKAuthCallback)callback ext:(NSDictionary *)extDict {
    self.authCallback = callback;

    DTAuthorizeReq *authReq = [DTAuthorizeReq new];
    authReq.bundleId = [[NSBundle mainBundle] bundleIdentifier];
    BOOL result = [DTOpenAPI sendReq:authReq];
    if (!result) {
        NSError *error = [NSError errorWithDomain:kErrorDomain code:LDSDKLoginFailed userInfo:@{kErrorMessage: @"授权失败"}];
        if (self.authCallback) {
            self.authCallback(LDSDKLoginFailed, error, nil, nil);
        }
    }
}

- (void)authPlatformQRCallback:(LDSDKAuthCallback)callback ext:(NSDictionary *)extDict {

}

- (void)authLogoutPlatformCallback:(LDSDKAuthCallback)callBack {
    self.dataVM.authDict = nil;
    if (callBack) {
        callBack(LDSDKLoginSuccess, nil, nil, nil);
    }
}

- (BOOL)isPlatformAppInstalled {
    return NO;
}

- (NSError *)registerWithPlatformConfig:(NSDictionary *)config {
    self.dataVM.configDto = [MCShareConfigDto createDto:config];
    BOOL success = [DTOpenAPI registerApp:self.dataVM.configDto.appId];
    NSError *error = [self.dataVM registerValidate];
    if (!success || error.code != LDSDKSuccess) {
        self.dataVM.registerSuccess = NO;
    } else {
        self.dataVM.registerSuccess = YES;
    }
    return error;
}

- (BOOL)isRegistered {
    return self.dataVM.registerSuccess;
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
    MCBaseShareDto *shareDto = [MCBaseShareDto factoryCreateShareDto:exDict];
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
    NSError *error = [self.dataVM respError:resp];
    if ([self.dataVM canResponseShareResult:resp]) {
        if (self.shareCallback) {
            self.shareCallback((LDSDKErrorCode) error.code, error);
        }
        return YES;
    } else if ([self.dataVM canResponseAuthResult:resp]) {
        self.dataVM.authDict = [self.dataVM wrapAuth:resp];
        if (self.authCallback) {
            self.authCallback((LDSDKLoginCode) error.code, error, self.dataVM.authDict, self.dataVM.userInfo);
        }
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
}


#pragma mark  - getter

- (LDSDKDingTalkDataVM *)dataVM {
    if (!_dataVM) {
        _dataVM = [LDSDKDingTalkDataVM new];
    }
    return _dataVM;
}

@end