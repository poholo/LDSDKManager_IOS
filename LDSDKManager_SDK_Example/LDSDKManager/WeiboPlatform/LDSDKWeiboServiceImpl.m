//
//  LDSDKWeiboServiceImpl.m
//  LDSDKManager
//
//  Created by ss on 15/9/1.
//  Copyright (c) 2015年 张海洋. All rights reserved.
//

#import "LDSDKWeiboServiceImpl.h"

#import <Weibo_SDK/WeiboSDK.h>

#import "LDSDKConfig.h"
#import "LDSDKWeiboDataVM.h"
#import "MMShareConfigDto.h"
#import "LDSDKExtendProtocol.h"
#import "MMBaseShareDto.h"
#import "WBMessageObject+Extend.h"

@interface LDSDKWeiboServiceImpl () <WeiboSDKDelegate> {
    BOOL isRegistered;
}

@property(strong, nonatomic) NSString *wbtoken;
@property(strong, nonatomic) NSString *wbCurrentUserID;

@property(nonatomic, strong) LDSDKWeiboDataVM *dataVM;
@property(nonatomic, copy) LDSDKShareCallback shareCallback;

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
    if(!success) {
        error = [NSError errorWithDomain:kErrorDomain code:LDSDKErrorCodeCommon userInfo:@{kErrorMessage: @"Weibo register error"}];
    }
    return error;
}

- (BOOL)isRegistered {
    return isRegistered;
}


#pragma mark -
#pragma mark 处理URL回调

- (BOOL)handleResultUrl:(NSURL *)url {
    return [WeiboSDK handleOpenURL:url delegate:self];
}


#pragma mark -
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
                                                                              access_token:self.wbtoken];

    [WeiboSDK sendRequest:request];
}

- (BOOL)responseResult:(WBSendMessageToWeiboResponse *)resp {
    NSError *error = [self.dataVM respError:resp];
    //        NSString *title = NSLocalizedString(@"发送结果", nil);
    //        NSString *message = [NSString stringWithFormat:@"%@: %d\n%@: %@\n%@: %@",
    //        NSLocalizedString(@"响应状态", nil), (int)response.statusCode,
    //        NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo,
    //        NSLocalizedString(@"原请求UserInfo数据", nil),response.requestUserInfo];

    NSString *accessToken = [resp.authResponse accessToken];
    if (accessToken) {
        self.wbtoken = accessToken;
    }
    NSString *userID = [resp.authResponse userID];
    if (userID) {
        self.wbCurrentUserID = userID;
    }
    if (self.shareCallback) {
        self.shareCallback((LDSDKErrorCode) error.code, error);
    }
    return NO;
}

- (BOOL)handleURL:(NSURL *)url {
    BOOL success = [WeiboSDK handleOpenURL:url delegate:self];
    return success;
}


#pragma mark - WeiboSDKDelegate

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request; {
#ifdef DEBUG
    NSLog(@"[%@]%s", NSStringFromClass([self class]), __FUNCTION__);
#endif
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
#ifdef DEBUG
    NSLog(@"[%@]%s", NSStringFromClass([self class]), __FUNCTION__);
#endif
    if ([self.dataVM canResponseResult:response] & [self responseResult:response]) {
        return;
    }
    NSError *error = [self.dataVM respError:response];
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class]) {
        //        NSString *title = NSLocalizedString(@"发送结果", nil);
        //        NSString *message = [NSString stringWithFormat:@"%@: %d\n%@: %@\n%@: %@",
        //        NSLocalizedString(@"响应状态", nil), (int)response.statusCode,
        //        NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo,
        //        NSLocalizedString(@"原请求UserInfo数据", nil),response.requestUserInfo];

        WBSendMessageToWeiboResponse *sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse *) response;
        NSString *accessToken = [sendMessageToWeiboResponse.authResponse accessToken];
        if (accessToken) {
            self.wbtoken = accessToken;
        }
        NSString *userID = [sendMessageToWeiboResponse.authResponse userID];
        if (userID) {
            self.wbCurrentUserID = userID;
        }
        if (self.shareCallback) {
            self.shareCallback((LDSDKErrorCode) error.code, error);
        }
    } else if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        //        NSString *title = NSLocalizedString(@"认证结果", nil);
        //        NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.userId:
        //        %@\nresponse.accessToken: %@\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态",
        //        nil), (int)response.statusCode,[(WBAuthorizeResponse *)response userID],
        //        [(WBAuthorizeResponse *)response accessToken],
        //        NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo,
        //        NSLocalizedString(@"原请求UserInfo数据", nil), response.requestUserInfo];

        self.wbtoken = [(WBAuthorizeResponse *) response accessToken];
        self.wbCurrentUserID = [(WBAuthorizeResponse *) response userID];
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

- (LDSDKWeiboDataVM *)dataVM {
    if (!_dataVM) {
        _dataVM = [LDSDKWeiboDataVM new];
    }
    return _dataVM;
}


@end
