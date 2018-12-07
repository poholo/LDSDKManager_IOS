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

@end

@implementation LDSDKQQServiceImp


#pragma mark -
#pragma mark - 配置部分

//判断平台是否可用
- (BOOL)isPlatformAppInstalled {
    return [self.dataVM isPlatformAppInstalled];
}

//注册平台
- (void)registerWithPlatformConfig:(NSDictionary *)config {
    self.dataVM.configDto = [MMShareConfigDto createDto:config];
    NSAssert(self.dataVM.configDto.appId, @"[LDSDKQQServiceImp] appid == NULL");
    self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:self.dataVM.configDto.appId andDelegate:self];
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


#pragma mark -
#pragma mark 登陆部分

- (BOOL)isLoginEnabledOnPlatform {
    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:kQQPlatformLogin];
    if (string.length == 0) {
        return YES;
    } else {
        return [string boolValue];
    }
}

- (void)loginToPlatformWithCallback:(LDSDKLoginCallback)callback {
    NSError *error = [self.dataVM supportContinue:@"QQLogin"];
    if (error) {

        return;
    }

    if ([QQApiInterface isQQInstalled]) {  //手机QQ登录流程
        NSLog(@"login by QQ oauth = %@", self.tencentOAuth);
        if (callback) {
        }
        error = nil;
        if (!self.tencentOAuth) {
            NSLog(@"tencentOauth && permissions = %@", self.dataVM.permissions);
            self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:self.dataVM.configDto.appId andDelegate:self];
        }
        //此处可set Token、oppenId、有效期 等参数
        [self.tencentOAuth authorize:self.dataVM.permissions];
    }
}

- (void)logoutFromPlatform {
    [self.tencentOAuth logout:self];
    self.tencentOAuth = nil;
}


#pragma mark -
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

    QQApiSendResultCode resultCode = [self sendReq:req shareModule:shareDto.shareToModule
                                          callback:^(QQBaseResp *resp) {
                                              if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
                                                  [self handleShareResultInActivity:resp onComplete:callback];
                                              }
                                          }];

    if (resultCode != EQQAPISENDSUCESS) {
        error = [NSError errorWithDomain:@"QQShare"
                                    code:-2
                                userInfo:@{kErrorMessage: @"分享失败"}];
        if (callback) {
            callback([self.dataVM errorCodePlatform:resultCode], error);
        }
    }
}


- (QQApiSendResultCode)sendReq:(QQBaseReq *)req shareModule:(LDSDKShareToModule)shareModule callback:(LDSDKQQCallbackBlock)callbackBlock {
    if (shareModule == LDSDKShareToContact) {
        return [QQApiInterface sendReq:req];
    } else if (shareModule == LDSDKShareToTimeLine) {
        return [QQApiInterface SendReqToQZone:req];
    } else {
        return EQQAPIMESSAGETYPEINVALID;
    }
}

- (void)handleShareResultInActivity:(id)result onComplete:(LDSDKShareCallback)complete {
    SendMessageToQQResp *response = (SendMessageToQQResp *) result;

    NSError *error = [self.dataVM respError:response];

    if (complete) {
        complete(YES, nil);
    }
}

#pragma mark -
#pragma mark  WXApiDelegate

- (void)onReq:(QQBaseReq *)req {
#ifdef DEBUG
    NSLog(@"[%@]%s", NSStringFromClass([self class]), __FUNCTION__);
#endif
}

- (void)onResp:(QQBaseResp *)resp {
#ifdef DEBUG
    NSLog(@"[%@]%s", NSStringFromClass([self class]), __FUNCTION__);
#endif
    NSError *error = [self.dataVM respError:resp];

    if (self.shareCallback) {
        self.shareCallback((LDSDKErrorCode) error.code, error);
    }
}

- (void)isOnlineResponse:(NSDictionary *)response {
#ifdef DEBUG
    NSLog(@"[%@]%s", NSStringFromClass([self class]), __FUNCTION__);
#endif
}


#pragma mark -
#pragma mark - TencentLoginDelegate

//登录成功后的回调
- (void)tencentDidLogin {
    NSLog(@"did login");
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
        //TODO::
    } else {  //登录失败，没有获取授权accesstoken
//        error = [NSError errorWithDomain:@"QQLogin" code:0 userInfo:@{@"NSLocalizedDescription": @"登录失败"}];
    }
}

//登录失败后的回调
- (void)tencentDidNotLogin:(BOOL)cancelled {
    NSError *error = [NSError errorWithDomain:@"QQLogin"
                                         code:LDSDKErrorUnknow
                                     userInfo:@{@"NSLocalizedDescription": @"登录失败"}];
    if (self.shareCallback) {
        self.shareCallback((LDSDKErrorCode) error.code, error);
    }
}

//登录时网络有问题的回调
- (void)tencentDidNotNetWork {
    NSLog(@"did not network");
    NSError *error = [NSError
            errorWithDomain:@"QQLogin"
                       code:LDSDKErrorUnknow
                   userInfo:@{@"NSLocalizedDescription": @"请检查网络"}];
    if (self.shareCallback) {
        self.shareCallback((LDSDKErrorCode) error.code, error);
    }
}


#pragma mark -
#pragma mark TencentSessionDelegate

//退出登录的回调
- (void)tencentDidLogout {
    NSLog(@"退出登录");
}

// API授权不够，需增量授权
- (BOOL)tencentNeedPerformIncrAuth:(TencentOAuth *)tencentOAuth withPermissions:(NSArray *)permissions {
    return YES;
}

//获取用户个人信息回调
- (void)getUserInfoResponse:(APIResponse *)response {
    NSLog(@"getUserInfo %d  %@ \n %@", response.retCode, response.message, response.errorMsg);
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
