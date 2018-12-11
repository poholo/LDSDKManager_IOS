//
//  LDSDKWeiboServiceImpl.m
//  LDSDKManager
//
//  Created by ss on 15/9/1.
//  Copyright (c) 2015年 张海洋. All rights reserved.
//

//  http://open.weibo.com/wiki/2/users/show 微博个人信息

#import "LDSDKWeiboServiceImpl.h"

#import <Weibo_SDK/WeiboSDK.h>

#import "LDSDKConfig.h"
#import "LDSDKWeiboDataVM.h"
#import "MMShareConfigDto.h"
#import "LDSDKExtendProtocol.h"
#import "MMBaseShareDto.h"
#import "WBMessageObject+Extend.h"
#import "LDNetworkManager.h"


@interface LDSDKWeiboServiceImpl () <WeiboSDKDelegate, WBHttpRequestDelegate>

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
    self.dataVM.configDto = [MMShareConfigDto createDto:config];
    NSError *error = [self.dataVM registerValidate];
    BOOL success = [WeiboSDK registerApp:self.dataVM.configDto.appId];
    if (!success) {
        error = [NSError errorWithDomain:kErrorDomain code:LDSDKErrorCodeCommon userInfo:@{kErrorMessage: @"Weibo register error"}];
    }
    return error;
}

#pragma mark 处理URL回调

- (BOOL)handleResultUrl:(NSURL *)url {
    return [WeiboSDK handleOpenURL:url delegate:self];
}


#pragma mark 分享部分

- (void)shareContent:(NSDictionary *)exDict {
    LDSDKShareCallback callback = exDict[LDSDKShareCallBackKey];
    self.shareCallback = callback;
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = self.dataVM.configDto.redirectURI;
    MMBaseShareDto *shareDto = [MMBaseShareDto factoryCreateShareDto:exDict];
    WBMessageObject *messageObject = [WBMessageObject shareObject:shareDto];

    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:messageObject
                                                                                  authInfo:authRequest
                                                                              access_token:self.dataVM.token];

    [WeiboSDK sendRequest:request];
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

- (void)authPlatformCallback:(LDSDKAuthCallback)callback {
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
    [WeiboSDK sendRequest:request];
}

- (void)authPlatformQRCallback:(LDSDKAuthCallback)callBack {

}

- (void)authLogoutPlatformCallback:(LDSDKAuthCallback)callBack {
    self.authCallback = callBack;
    if (self.dataVM.token) {
        [WeiboSDK logOutWithToken:self.dataVM.token delegate:self withTag:nil];
    } else {
        if (self.authCallback) {
            self.authCallback(LDSDKLoginSuccess, nil, nil, nil);
        }
    }
}

#pragma mark - WeiboSDKDelegate

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request; {
    LDLog(@"[%@]%s", NSStringFromClass([self class]), __FUNCTION__);
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    LDLog(@"[%@]%s", NSStringFromClass([self class]), __FUNCTION__);
    if ([self.dataVM canResponseShareResult:response] && [self responseResult:response]) {
        return;
    }

    if ([self.dataVM canResponseAuthResult:response] && [self responseResult:response]) {
        return;
    }

    NSError *error = [self.dataVM respError:response];
    if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        //        NSString *title = NSLocalizedString(@"认证结果", nil);
        //        NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.userId:
        //        %@\nresponse.accessToken: %@\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态",
        //        nil), (int)response.statusCode,[(WBAuthorizeResponse *)response userID],
        //        [(WBAuthorizeResponse *)response accessToken],
        //        NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo,
        //        NSLocalizedString(@"原请求UserInfo数据", nil), response.requestUserInfo];

        self.dataVM.token = [(WBAuthorizeResponse *) response accessToken];
        self.dataVM.userId = [(WBAuthorizeResponse *) response userID];
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

#pragma mark WBHttpRequestDelegate

/**
 收到一个来自微博Http请求的响应
 */
- (void)request:(WBHttpRequest *)request didReceiveResponse:(NSURLResponse *)response {

}

/**
 收到一个来自微博Http请求失败的响应
 */
- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error {

}

/**
 收到一个来自微博Http请求的网络返回
 */
- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result {

}

/**
 收到一个来自微博Http请求的网络返回
 */
- (void)request:(WBHttpRequest *)request didFinishLoadingWithDataResult:(NSData *)data {

}

/**
 收到快速SSO授权的重定向
 */
- (void)request:(WBHttpRequest *)request didReciveRedirectResponseWithURI:(NSURL *)redirectUrl {

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
