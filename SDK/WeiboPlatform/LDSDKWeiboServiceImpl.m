//
//  LDSDKWeiboServiceImpl.m
//  LDSDKManager
//
//  Created by ss on 15/9/1.
//  Copyright (c) 2015年 张海洋. All rights reserved.
//

//  http://open.weibo.com/wiki/2/users/show 微博个人信息
//  http://open.weibo.com/wiki/微博API

#import "LDSDKWeiboServiceImpl.h"

#import <Weibo_SDK/WeiboSDK.h>
#import <MCBase/MCLog.h>

#import "LDSDKWeiboDataVM.h"
#import "MCShareConfigDto.h"
#import "LDSDKExtendProtocol.h"
#import "MCBaseShareDto.h"
#import "WBMessageObject+Extend.h"
#import "LDNetworkManager.h"


@interface LDSDKWeiboServiceImpl () <WeiboSDKDelegate>

@property(nonatomic, strong) LDNetworkManager *networkManager;
@property(nonatomic, strong) LDSDKWeiboDataVM *dataVM;
@property(nonatomic, copy) LDSDKShareCallback shareCallback;
@property(nonatomic, copy) LDSDKAuthCallback authCallback;

@end

@implementation LDSDKWeiboServiceImpl
#pragma mark -
#pragma mark 配置部分

- (BOOL)isPlatformAppInstalled {
    return [WeiboSDK isWeiboAppInstalled];
}

- (NSError *)registerWithPlatformConfig:(NSDictionary *)config {
    self.dataVM.configDto = [MCShareConfigDto createDto:config];
    NSError *error = [self.dataVM registerValidate];
    BOOL success = [WeiboSDK registerApp:self.dataVM.configDto.appId universalLink:self.dataVM.configDto.redirectURI];
    if (!success) {
        error = [NSError errorWithDomain:kErrorDomain code:LDSDKErrorCodeCommon userInfo:@{kErrorMessage: @"Weibo register error"}];
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

#pragma mark 分享部分

- (void)shareContent:(NSDictionary *)exDict {
    LDSDKShareCallback callback = exDict[LDSDKShareCallBackKey];
    self.shareCallback = callback;
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = self.dataVM.configDto.redirectURI;
    MCBaseShareDto *shareDto = [MCBaseShareDto factoryCreateShareDto:exDict];
    WBMessageObject *messageObject = [WBMessageObject shareObject:shareDto];

    if (!shareDto || !messageObject) {
        if (self.shareCallback) {
            NSError *err = [NSError errorWithDomain:kErrorDomain code:LDSDKErrorCodeUnsupport userInfo:@{kErrorMessage: @"Not support: check params"}];
            self.shareCallback(LDSDKErrorCodeUnsupport, err);
        }
        return;
    }


    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:messageObject
                                                                                  authInfo:authRequest
                                                                              access_token:self.dataVM.token];
    
    __weak typeof(self) weakSelf = self;
    [WeiboSDK sendRequest:request completion:^(BOOL success) {
        __strong typeof(self) strongSelf = weakSelf;
        
    }];
}

- (BOOL)responseResult:(WBBaseResponse *)resp {
    NSError *error = [self.dataVM respError:resp];
    if ([resp isKindOfClass:[WBSendMessageToWeiboResponse class]]) {
        WBSendMessageToWeiboResponse *response = (WBSendMessageToWeiboResponse *) resp;
        self.dataVM.token = [response.authResponse accessToken];
        self.dataVM.userId = [response.authResponse userID];
        if (self.shareCallback) {
            self.shareCallback((LDSDKErrorCode) error.code, error);
        }
        return YES;
    } else if ([resp isKindOfClass:[WBAuthorizeResponse class]]) {
        if ((LDSDKErrorCode) error.code == LDSDKSuccess) {
            WBAuthorizeResponse *response = (WBAuthorizeResponse *) resp;
            self.dataVM.authDict = [self.dataVM wrapAuth:response];
            if (self.authCallback) {
                self.authCallback(LDSDKLoginSuccess, nil, self.dataVM.authDict, nil);
            }
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.weibo.com/2/users/show.json?access_token=%@&uid=%@", self.dataVM.token, self.dataVM.userId]];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
            [request setHTTPMethod:@"GET"];
            __weak typeof(self) weakSelf = self;
            [self.networkManager dataTaskWithRequest:request callBack:^(BOOL success, NSDictionary *data) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (success) {
                    NSError *err = [self.dataVM validateAuthToken:data];
                    if (err) {
                        if (strongSelf.authCallback) {
                            strongSelf.authCallback((LDSDKLoginCode) err.code, error, nil, nil);
                        }
                    } else {
                        strongSelf.dataVM.userInfo = [self.dataVM wrapAuthUserInfo:data];
                        if (strongSelf.authCallback) {
                            strongSelf.authCallback(LDSDKLoginSuccess, nil, self.dataVM.authDict, self.dataVM.userInfo);
                        }
                    }
                } else {
                    NSError *err = [NSError errorWithDomain:kErrorDomain code:LDSDKLoginFailed userInfo:@{kErrorMessage: @"取用户数据失败"}];
                    strongSelf.authCallback(LDSDKLoginFailed, err, nil, nil);
                }
            }];
            return YES;
        } else {
            if (self.authCallback) {
                self.authCallback((LDSDKLoginCode) error.code, error, nil, nil);
            }
        }
    }
    return NO;
}

- (BOOL)handleURL:(NSURL *)url {
    BOOL success = [WeiboSDK handleOpenURL:url delegate:self];
    return success;
}

#pragma mark - Auth

- (void)authPlatformCallback:(LDSDKAuthCallback)callback ext:(NSDictionary *)extDict {
    self.authCallback = callback;
    if (self.dataVM.configDto.redirectURI.length == 0) {
        NSError *error = [NSError errorWithDomain:kErrorDomain code:LDSDKLoginMissParams userInfo:@{kErrorMessage: @"MissParams: redirectURI"}];
        if (self.authCallback) {
            self.authCallback(LDSDKLoginMissParams, error, nil, nil);
        }
        return;
    }
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = self.dataVM.configDto.redirectURI;
    request.scope = @"all";
    [WeiboSDK sendRequest:request completion:NULL];
}

- (void)authPlatformQRCallback:(LDSDKAuthCallback)callback ext:(NSDictionary *)extDict {
    self.authCallback = callback;
    if (self.authCallback) {
        NSError *error = [NSError errorWithDomain:kErrorDomain code:LDSDKLoginFailed userInfo:@{kErrorMessage: @"Not support QR Auth"}];
        self.authCallback(LDSDKLoginFailed, error, nil, nil);
    }
}

- (void)authLogoutPlatformCallback:(LDSDKAuthCallback)callBack {
    self.authCallback = callBack;
    if (self.dataVM.token) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.weibo.com/oauth2/revokeoauth2?access_token=%@", self.dataVM.token]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        [request setHTTPMethod:@"GET"];
        __weak typeof(self) weakSelf = self;
        [self.networkManager dataTaskWithRequest:request callBack:^(BOOL success, NSDictionary *data) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (success && [data[@"result"] boolValue]) {
                if (strongSelf.authCallback) {
                    strongSelf.authCallback(LDSDKLoginSuccess, nil, nil, nil);
                    strongSelf.dataVM.userInfo = nil;
                    strongSelf.dataVM.authDict = nil;
                    strongSelf.dataVM.userId = nil;
                    strongSelf.dataVM.token = nil;
                }
            } else {
                NSError *err = [NSError errorWithDomain:kErrorDomain code:LDSDKLogoutFailed userInfo:@{kErrorMessage: @"取消授权失败"}];
                strongSelf.authCallback(LDSDKLogoutFailed, err, nil, nil);
            }
        }];
    } else {
        if (self.authCallback) {
            self.authCallback(LDSDKLoginSuccess, nil, nil, nil);
        }
    }
}

#pragma mark - WeiboSDKDelegate

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request; {
    MCLog(@"[%@]%s", NSStringFromClass([self class]), __FUNCTION__);
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    MCLog(@"[%@]%s", NSStringFromClass([self class]), __FUNCTION__);
    if ([self.dataVM canResponseShareResult:response] && [self responseResult:response]) {
        return;
    }

    if ([self.dataVM canResponseAuthResult:response] && [self responseResult:response]) {
        return;
    }
//    else if ([response isKindOfClass:WBPaymentResponse.class]) {
    //        NSString *title = NSLocalizedString(@"支付结果", nil);
    //        NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.payStatusCode:
    //        %@\nresponse.payStatusMessage: %@\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态",
    //        nil), (int)response.statusCode,[(WBPaymentResponse *)response payStatusCode],
    //        [(WBPaymentResponse *)response payStatusMessage],
    //        NSLocalizedString(@"响应UserInfo数据", nil),response.userInfo,
    //        NSLocalizedString(@"原请求UserInfo数据", nil), response.requestUserInfo];
//    }
//
}

#pragma mark - getter

- (LDNetworkManager *)networkManager {
    if (!_networkManager) {
        _networkManager = [LDNetworkManager new];
    }
    return _networkManager;
}

- (LDSDKWeiboDataVM *)dataVM {
    if (!_dataVM) {
        _dataVM = [LDSDKWeiboDataVM new];
    }
    return _dataVM;
}


@end
