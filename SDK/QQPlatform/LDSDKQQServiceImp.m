//
//  LDSDKQQServiceImp.m
//  TestThirdPlatform
//
//  Created by ss on 15/8/17.
//  Copyright (c) 2015年 Lede. All rights reserved.
//

#import "LDSDKQQServiceImp.h"


#import <MCBase/MCLog.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

#import "UIImage+LDExtend.h"
#import "LDSDKConfig.h"
#import "LDSDKQQServiceImpDataVM.h"
#import "MCBaseShareDto.h"
#import "QQApiObject+Extend.h"
#import "MCShareConfigDto.h"


@interface LDSDKQQServiceImp () <TencentSessionDelegate, QQApiInterfaceDelegate>

@property(nonatomic, strong) TencentOAuth *tencentAuth;
@property(nonatomic, strong) LDSDKQQServiceImpDataVM *dataVM;

@property(nonatomic, copy) LDSDKShareCallback shareCallback;
@property(nonatomic, copy) LDSDKAuthCallback authCallback;

@end

@implementation LDSDKQQServiceImp


#pragma mark -
#pragma mark - 配置部分

//判断平台是否可用
- (BOOL)isPlatformAppInstalled {
    return [self.dataVM isPlatformAppInstalled];
}

//注册平台
- (NSError *)registerWithPlatformConfig:(NSDictionary *)config {
    self.dataVM.configDto = [MCShareConfigDto createDto:config];
    NSError *error = [self.dataVM registerValidate];
    self.tencentAuth = [[TencentOAuth alloc] initWithAppId:self.dataVM.configDto.appId andDelegate:self];
    if (error.code != LDSDKSuccess) {
        self.dataVM.registerSuccess = NO;
    } else {
        self.dataVM.registerSuccess = YES;
    }
    return error;
}

- (BOOL)registerQQPlatformAppId:(NSString *)appId {

    return YES;
}

- (BOOL)isRegistered {
    return self.dataVM.registerSuccess;
}


#pragma mark -
#pragma mark 处理URL回调

- (BOOL)handleResultUrl:(NSURL *)url {
    return [self handleOpenURL:url];
}

- (BOOL)handleOpenURL:(NSURL *)url {
    return [TencentOAuth HandleOpenURL:url] || [QQApiInterface handleOpenURL:url delegate:self];
}

#pragma mark 分享部分

- (void)shareContent:(NSDictionary *)exDict {
    NSError *error = [self.dataVM supportContinue:@"QQShare"];
    LDSDKShareCallback callback = exDict[LDSDKShareCallBackKey];
    if (error) {
        if (callback) {
            callback(LDSDKErrorUninstallPlatformApp, error);
        }
        return;
    }
    self.shareCallback = callback;
    MCBaseShareDto *shareDto = [MCBaseShareDto factoryCreateShareDto:exDict];
    QQApiObject *apiObject = [QQApiObject shareObject:shareDto];
    if (!shareDto || !apiObject) {
        if (self.shareCallback) {
            NSError *err = [NSError errorWithDomain:kErrorDomain code:LDSDKErrorCodeUnsupport userInfo:@{kErrorMessage: @"Not support: check params"}];
            self.shareCallback(LDSDKErrorCodeUnsupport, err);
        }
        return;
    }

    SendMessageToQQReq *req;

    if (apiObject.cflag > kQQAPICtrlFlagQQShare) {
        ArkObject *arkObject = [ArkObject objectWithData:[self.dataVM arkJson] qqApiObject:apiObject];
        req = [SendMessageToQQReq reqWithArkContent:arkObject];
    } else {
        req = [SendMessageToQQReq reqWithContent:apiObject];
    }

    QQApiSendResultCode resultCode = [self sendReq:req shareModule:shareDto.shareToModule];
    LDSDKErrorCode errorCode = [self.dataVM errorCodePlatform:resultCode];
    if (errorCode != LDSDKSuccess) {
        error = [self.dataVM respErrorCode:resultCode];
        if (self.shareCallback) {
            self.shareCallback((LDSDKErrorCode) error.code, error);
        }
    }
}

- (BOOL)handleURL:(NSURL *)url {
    BOOL success = [QQApiInterface handleOpenURL:url delegate:self];
    if ([TencentOAuth CanHandleOpenURL:url]) {
        [TencentOAuth HandleOpenURL:url];
    }
    return success;
}

- (QQApiSendResultCode)sendReq:(QQBaseReq *)req shareModule:(LDSDKShareToModule)shareModule {
    if (shareModule == LDSDKShareToContact || shareModule == LDSDKShareToDataLine || shareModule == LDSDKShareToFavorites) {
        return [QQApiInterface sendReq:req];
    } else if (shareModule == LDSDKShareToTimeLine) {
        return [QQApiInterface SendReqToQZone:req];
    } else {
        return EQQAPIMESSAGETYPEINVALID;
    }
}

- (BOOL)responseResult:(SendMessageToQQResp *)resp {
    NSError *error = [self.dataVM respError:resp];
    if (self.shareCallback) {
        self.shareCallback((LDSDKErrorCode) error.code, error);
        return YES;
    }
    return NO;
}


#pragma mark 登陆部分

- (void)authPlatformCallback:(LDSDKAuthCallback)callback ext:(NSDictionary *)extDict {
    self.authCallback = callback;

    if (!self.tencentAuth) {
        self.tencentAuth = [[TencentOAuth alloc] initWithAppId:self.dataVM.configDto.appId andDelegate:self];
    }

    self.tencentAuth.authMode = kAuthModeClientSideToken;
    [self.tencentAuth authorize:self.dataVM.permissions];
}

- (void)authPlatformQRCallback:(LDSDKAuthCallback)callback ext:(NSDictionary *)extDict {
    self.authCallback = callback;
    if (!self.tencentAuth) {
        self.tencentAuth = [[TencentOAuth alloc] initWithAppId:self.dataVM.configDto.appId andDelegate:self];
    }

    self.tencentAuth.authMode = kAuthModeClientSideToken;
    [self.tencentAuth authorizeWithQRlogin:self.dataVM.permissions];
}

- (void)authLogoutPlatformCallback:(LDSDKAuthCallback)callBack {
    self.authCallback = callBack;
    if (!self.tencentAuth) {
        if (self.authCallback) {
            self.authCallback(LDSDKLoginSuccess, nil, nil, nil);
        }
    } else {
        [self.tencentAuth logout:self];
    }
}


#pragma mark -
#pragma mark  WXApiDelegate

- (void)onReq:(QQBaseReq *)req {
    MCLog(@"%@", req);
}

- (void)onResp:(QQBaseResp *)resp {
    MCLog(@"%@", resp);
    if ([self.dataVM canResponseShareResult:resp] && [self responseResult:resp]) {
        return;
    }

}

- (void)isOnlineResponse:(NSDictionary *)response {
    MCLog(@"%@", response);
}

#pragma mark -
#pragma mark TencentLoginDelegate

- (void)tencentDidLogin {
    self.dataVM.authDict = [self.dataVM wrapAuth:self.tencentAuth];
    if (self.authCallback) {
        self.authCallback(LDSDKLoginSuccess, nil, self.dataVM.authDict, nil);
    }
    [self.tencentAuth getUserInfo];
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    NSError *error = [NSError errorWithDomain:kErrorDomain
                                         code:LDSDKLoginUserCancel
                                     userInfo:@{kErrorMessage: @"用户取消"}];
    if (self.authCallback) {
        self.authCallback(LDSDKLoginUserCancel, error, nil, nil);
    }

}

- (void)tencentDidNotNetWork {
    NSError *error = [NSError errorWithDomain:kErrorDomain
                                         code:LDSDKLoginNoNet
                                     userInfo:@{kErrorMessage: @"请检查网络"}];
    if (self.authCallback) {
        self.authCallback(LDSDKLoginNoNet, error, nil, nil);
    }
}


#pragma mark TencentSessionDelegate

- (void)tencentDidLogout {
    self.dataVM.authDict = nil;
    self.dataVM.userInfo = nil;
    self.tencentAuth = nil;
    if (self.authCallback) {
        self.authCallback(LDSDKLoginSuccess, nil, nil, nil);
    }
}

- (BOOL)tencentNeedPerformIncrAuth:(TencentOAuth *)tencentAuth withPermissions:(NSArray *)permissions {
    return YES;
}

//获取用户个人信息回调
- (void)getUserInfoResponse:(APIResponse *)response {
    MCLog(@"getUserInfo %d  %@ \n %@", response.retCode, response.message, response.errorMsg);
    if (response.retCode == URLREQUEST_SUCCEED) {  //成功用户资料
        if (response.detailRetCode == kOpenSDKErrorSuccess) {
            if (self.authCallback) {
                self.dataVM.authDict = [self.dataVM wrapAuth:self.tencentAuth];
                self.dataVM.userInfo = [self.dataVM wrapAuthUserInfo:response];
                self.authCallback(LDSDKLoginSuccess, nil, self.dataVM.authDict, self.dataVM.userInfo);
            }
        } else {  //获取失败
            if (self.authCallback) {
                NSString *msg = response.errorMsg.length > 0 ? response.errorMsg : @"网络异常";
                NSError *error = [NSError errorWithDomain:kErrorDomain code:LDSDKLoginFailed userInfo:@{kErrorMessage: msg}];
                self.authCallback(LDSDKLoginFailed, error, nil, nil);
            }
        }
    }
}


#pragma mark - getter

- (LDSDKQQServiceImpDataVM *)dataVM {
    if (!_dataVM) {
        _dataVM = [LDSDKQQServiceImpDataVM new];
    }
    return _dataVM;
}

@end
