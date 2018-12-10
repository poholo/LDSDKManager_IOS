//
//  LDSDKQQServiceImp.m
//  TestThirdPlatform
//
//  Created by ss on 15/8/17.
//  Copyright (c) 2015年 Lede. All rights reserved.
//

#import "LDSDKQQServiceImp.h"

#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

#import "UIImage+LDExtend.h"
#import "LDSDKConfig.h"
#import "LDSDKQQServiceImpDataVM.h"
#import "MMBaseShareDto.h"
#import "QQApiObject+Extend.h"
#import "MMShareConfigDto.h"


NSString const *kQQPlatformLogin = @"login_qq";

@interface LDSDKQQServiceImp () <TencentSessionDelegate, QQApiInterfaceDelegate>

@property(nonatomic, strong) TencentOAuth *tencentOAuth;
@property(nonatomic, strong) LDSDKQQServiceImpDataVM *dataVM;

@property(nonatomic, copy) LDSDKShareCallback shareCallback;
@property(nonatomic, copy) LDSDKAuthCallback loginCallback;

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
    self.dataVM.configDto = [MMShareConfigDto createDto:config];
    NSError *error = [self.dataVM registerValidate];
    self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:self.dataVM.configDto.appId andDelegate:self];
    return error;
}

- (BOOL)registerQQPlatformAppId:(NSString *)appId {

    return YES;
}

- (BOOL)isRegistered {
    return NO;
}


#pragma mark -
#pragma mark 处理URL回调

- (BOOL)handleResultUrl:(NSURL *)url {
    return [self handleOpenURL:url];
}

- (BOOL)handleOpenURL:(NSURL *)url {
    return [TencentOAuth HandleOpenURL:url] || [QQApiInterface handleOpenURL:url delegate:self];
}


#pragma mark 登陆部分

- (BOOL)isLoginEnabledOnPlatform {
    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:kQQPlatformLogin];
    if (string.length == 0) {
        return YES;
    } else {
        return [string boolValue];
    }
}

- (void)loginToPlatformWithCallback:(LDSDKAuthCallback)callback {
    self.loginCallback = callback;

    if (!self.tencentOAuth) {
        self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:self.dataVM.configDto.appId andDelegate:self];
    }

    self.tencentOAuth.authMode = kAuthModeClientSideToken;
    [self.tencentOAuth authorize:self.dataVM.permissions];
}

- (void)logoutFromPlatform {
    [self.tencentOAuth logout:self];
    self.tencentOAuth = nil;
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
    MMBaseShareDto *shareDto = [MMBaseShareDto factoryCreateShareDto:exDict];
    QQApiObject *apiObject = [QQApiObject shareObject:shareDto];

    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:apiObject];

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
    if (shareModule == LDSDKShareToContact) {
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


#pragma mark -
#pragma mark  WXApiDelegate

- (void)onReq:(QQBaseReq *)req {
    LDLog(@"%@", req);
}

- (void)onResp:(QQBaseResp *)resp {
    LDLog(@"%@", resp);
    if ([self.dataVM canResponseShareResult:resp] && [self responseResult:resp]) {
        return;
    }

}

- (void)isOnlineResponse:(NSDictionary *)response {
    LDLog(@"%@", response);
}

#pragma mark -
#pragma mark TencentLoginDelegate

- (void)tencentDidLogin {
    if (self.tencentOAuth.accessToken && 0 != [self.tencentOAuth.accessToken length]) {
        NSMutableDictionary *oauthInfo = [NSMutableDictionary dictionary];
        oauthInfo[kQQ_TOKEN_KEY] = self.tencentOAuth.accessToken;
        if (self.tencentOAuth.expirationDate) {
            oauthInfo[kQQ_EXPIRADATE_KEY] = self.tencentOAuth.expirationDate;
        }

        if (self.tencentOAuth.openId) {
            oauthInfo[kQQ_OPENID_KEY] = self.tencentOAuth.openId;
        }

        [self.tencentOAuth getUserInfo];
    } else {  //登录失败，没有获取授权accesstoken
//        error = [NSError errorWithDomain:@"QQLogin" code:0 userInfo:@{@"NSLocalizedDescription": @"登录失败"}];
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    NSError *error = [NSError errorWithDomain:kErrorDomain
                                         code:LDSDKLoginUserCancel
                                     userInfo:@{kErrorMessage: @"登录失败"}];
    if (self.loginCallback) {
        self.loginCallback(LDSDKLoginUserCancel, error, nil, nil);
    }

}

- (void)tencentDidNotNetWork {
    NSError *error = [NSError
            errorWithDomain:kErrorDomain
                       code:LDSDKLoginNoNet
                   userInfo:@{kErrorMessage: @"请检查网络"}];
    if (self.loginCallback) {
        self.loginCallback(LDSDKLoginNoNet, error, nil, nil);
    }
}


#pragma mark TencentSessionDelegate

- (void)tencentDidLogout {
    LDLog(@"退出登录");
}

// API授权不够，需增量授权
- (BOOL)tencentNeedPerformIncrAuth:(TencentOAuth *)tencentOAuth withPermissions:(NSArray *)permissions {
    return YES;
}

//获取用户个人信息回调
- (void)getUserInfoResponse:(APIResponse *)response {
    LDLog(@"getUserInfo %d  %@ \n %@", response.retCode, response.message, response.errorMsg);
//    if (response.retCode == URLREQUEST_FAILED) {  //失败
//        if (MyBlock) {
//            MyBlock(nil, nil, error);
//        }
//    } else if (response.retCode == URLREQUEST_SUCCEED) {  //成功用户资料
//        if (response.detailRetCode == kOpenSDKErrorSuccess) {
//            if (MyBlock) {
//                NSMutableDictionary *oauthInfo = [NSMutableDictionary dictionary];
//                oauthInfo[kQQ_TOKEN_KEY] = self.tencentOAuth.accessToken;
//                if (self.tencentOAuth.expirationDate) {
//                    oauthInfo[kQQ_EXPIRADATE_KEY] = self.tencentOAuth.expirationDate;
//                }
//                if (self.tencentOAuth.openId) {
//                    oauthInfo[kQQ_OPENID_KEY] = self.tencentOAuth.openId;
//                }
//
//                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
//                NSString *nickName = response.jsonResponse[kQQ_NICKNAME_KEY];
//                NSString *avatarUrl = response.jsonResponse[kQQ_AVATARURL_KEY];
//                if (nickName && [nickName length]) {
//                    userInfo[kQQ_NICKNAME_KEY] = nickName;
//                }
//                if (avatarUrl) {
//                    userInfo[kQQ_AVATARURL_KEY] = avatarUrl;
//                }
//
//                MyBlock(oauthInfo, userInfo, nil);
//            }
//        } else {  //获取失败
//            error = [NSError errorWithDomain:@"QQLogin"
//                                        code:response.detailRetCode
//                                    userInfo:@{@"NSLocalizedDescription": @"登录失败"}];
//            if (MyBlock) {
//                MyBlock(nil, nil, error);
//            }
//        }
//    }
}


#pragma mark - getter

- (LDSDKQQServiceImpDataVM *)dataVM {
    if (!_dataVM) {
        _dataVM = [LDSDKQQServiceImpDataVM new];
    }
    return _dataVM;
}

@end
