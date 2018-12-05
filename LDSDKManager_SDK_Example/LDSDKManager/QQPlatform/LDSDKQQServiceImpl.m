//
//  LDSDKQQServiceImpl.m
//  TestThirdPlatform
//
//  Created by ss on 15/8/17.
//  Copyright (c) 2015年 Lede. All rights reserved.
//

#import "LDSDKQQServiceImpl.h"

#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

#import "UIImage+LDExtend.h"
#import "LDSDKConfig.h"
#import "LDSDKQQServiceImplDataVM.h"
#import "MMBaseShareDto.h"
#import "QQApiObject+Extend.h"
#import "MMShareConfigDto.h"


NSString const *kQQPlatformLogin = @"login_qq";

static NSArray *permissions = nil;

@interface LDSDKQQServiceImpl () <TencentSessionDelegate, QQApiInterfaceDelegate> {
    BOOL isLogining;
    NSError *error;

    void (^MyBlock)(NSDictionary *oauthInfo, NSDictionary *userInfo, NSError *qqerror);

    LDSDKQQCallbackBlock shareBlock;
}

@property(nonatomic, strong) TencentOAuth *tencentOAuth;
@property(nonatomic, strong) LDSDKQQServiceImplDataVM *dataVM;

@end

@implementation LDSDKQQServiceImpl

- (instancetype)init {
    if (self = [super init]) {
        isLogining = NO;
        permissions = @[kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO];
    }
    return self;
}


#pragma mark -
#pragma mark - 配置部分

//判断平台是否可用
- (BOOL)isPlatformAppInstalled {
    return [self.dataVM isPlatformAppInstalled];
}

//注册平台
- (void)registerWithPlatformConfig:(NSDictionary *)config {
    self.dataVM.configDto = [MMShareConfigDto createDto:config];
    NSAssert(self.dataVM.configDto.appId, @"[LDSDKQQServiceImpl] appid == NULL");
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
        if (callback) {
            callback(nil, nil, error);
        }
        return;
    }

    if ([QQApiInterface isQQInstalled]) {  //手机QQ登录流程
        NSLog(@"login by QQ oauth = %@", self.tencentOAuth);
        if (callback) {
            MyBlock = callback;
        }
        error = nil;
        isLogining = YES;
        if (!tencentOAuth) {
            NSLog(@"tencentOauth && permissions = %@", permissions);
            self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:self.authAppId andDelegate:self];
        }
        //此处可set Token、oppenId、有效期 等参数
        [tencentOAuth authorize:permissions];
    }
}

- (void)logoutFromPlatform {

    [tencentOAuth logout:self];
    MyBlock = nil;
    self.tencentOAuth = nil;
}


#pragma mark -
#pragma mark 分享部分

- (void)shareContent:(NSDictionary *)exDict {
    NSError *error = [self.dataVM supportContinue:@"QQShare"];
    LDSDKShareCallback callback = exDict[LDSDKShareCallBackKey];
    if (error) {
        if (callback) {
            callback(NO, error);
        }
        return;
    }
    MMBaseShareDto *shareDto = [MMBaseShareDto factoryCreateShareDto:exDict];
    QQApiObject *apiObject = [QQApiObject shareObject:shareDto];

    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:apiObject];

    QQApiSendResultCode resultCode = [self sendReq:req shareModule:shareDto.shareType
                                          callback:^(QQBaseResp *resp) {
                                              if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
                                                  [self handleShareResultInActivity:resp onComplete:callback];
                                              }
                                          }];

    if (resultCode != EQQAPISENDSUCESS) {
        error = [NSError errorWithDomain:@"QQShare"
                                    code:-2
                                userInfo:@{@"NSLocalizedDescription": @"分享失败"}];
        if (callback) {
            callback(NO, error);
        }
    }
}


- (QQApiSendResultCode)sendReq:(QQBaseReq *)req shareModule:(LDSDKShareToModule)shareModule callback:(LDSDKQQCallbackBlock)callbackBlock {
    shareBlock = callbackBlock;
    if (shareModule == 1) {
        return [QQApiInterface sendReq:req];
    } else if (shareModule == 2) {
        return [QQApiInterface SendReqToQZone:req];
    } else {
        return EQQAPIMESSAGETYPEINVALID;
    }
}

- (void)handleShareResultInActivity:(id)result onComplete:(LDSDKShareCallback)complete {
    SendMessageToQQResp *response = (SendMessageToQQResp *) result;

    NSString *resultStr = response.result;

    if ([resultStr isEqualToString:@"0"]) {  //成功
        if (complete) {
            complete(YES, nil);
        }
    } else if ([resultStr isEqualToString:@"-4"]) {
        error = [NSError
                errorWithDomain:@"QQShare"
                           code:-2
                       userInfo:@{@"NSLocalizedDescription": @"用户取消分享"}];

        if (complete) {
            complete(NO, error);
        }
    } else {
        error = [NSError
                errorWithDomain:@"QQShare"
                           code:-1
                       userInfo:@{@"NSLocalizedDescription": @"分享失败"}];
        if (complete) {
            complete(NO, error);
        }
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
    if (shareBlock) {
        shareBlock(resp);
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
    isLogining = NO;
    if (self.tencentOAuth.accessToken && 0 != [tencentOAuth.accessToken length]) {
        NSMutableDictionary *oauthInfo = [NSMutableDictionary dictionary];
        oauthInfo[kQQ_TOKEN_KEY] = self.tencentOAuth.accessToken;
        if (self.tencentOAuth.expirationDate) {
            oauthInfo[kQQ_EXPIRADATE_KEY] = self.tencentOAuth.expirationDate;
        }

        if (self.tencentOAuth.openId) {
            oauthInfo[kQQ_OPENID_KEY] = self.tencentOAuth.openId;
        }

        if (MyBlock) {
            MyBlock(oauthInfo, nil, nil);
        }

        [tencentOAuth getUserInfo];

    } else {  //登录失败，没有获取授权accesstoken
        error = [NSError errorWithDomain:@"QQLogin" code:0 userInfo:@{@"NSLocalizedDescription": @"登录失败"}];
        if (MyBlock) {
            MyBlock(nil, nil, error);
        }
    }
}

//登录失败后的回调
- (void)tencentDidNotLogin:(BOOL)cancelled {
    NSLog(@"did not login");
    isLogining = NO;
    error = [NSError
            errorWithDomain:@"QQLogin"
                       code:0
                   userInfo:@{@"NSLocalizedDescription": @"登录失败"}];
    if (MyBlock) {
        MyBlock(nil, nil, error);
    }
    if (cancelled) {  // NSLog(@"用户取消登录");
    } else {          // NSLog(@"登录失败");
    }
}

//登录时网络有问题的回调
- (void)tencentDidNotNetWork {
    NSLog(@"did not network");
    isLogining = NO;
    error = [NSError
            errorWithDomain:@"QQLogin"
                       code:0
                   userInfo:@{@"NSLocalizedDescription": @"请检查网络"}];
    if (MyBlock) {
        MyBlock(nil, nil, error);
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
    NSLog(@"wufashouquan");
    return YES;
}

//获取用户个人信息回调
- (void)getUserInfoResponse:(APIResponse *)response {
    NSLog(@"getUserInfo %d  %@ \n %@", response.retCode, response.message, response.errorMsg);
    if (response.retCode == URLREQUEST_FAILED) {  //失败
        if (MyBlock) {
            MyBlock(nil, nil, error);
        }
    } else if (response.retCode == URLREQUEST_SUCCEED) {  //成功用户资料
        if (response.detailRetCode == kOpenSDKErrorSuccess) {
            if (MyBlock) {
                NSMutableDictionary *oauthInfo = [NSMutableDictionary dictionary];
                oauthInfo[kQQ_TOKEN_KEY] = self.tencentOAuth.accessToken;
                if (self.tencentOAuth.expirationDate) {
                    oauthInfo[kQQ_EXPIRADATE_KEY] = self.tencentOAuth.expirationDate;
                }
                if (self.tencentOAuth.openId) {
                    oauthInfo[kQQ_OPENID_KEY] = self.tencentOAuth.openId;
                }

                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                NSString *nickName = response.jsonResponse[kQQ_NICKNAME_KEY];
                NSString *avatarUrl = response.jsonResponse[kQQ_AVATARURL_KEY];
                if (nickName && [nickName length]) {
                    userInfo[kQQ_NICKNAME_KEY] = nickName;
                }
                if (avatarUrl) {
                    userInfo[kQQ_AVATARURL_KEY] = avatarUrl;
                }

                MyBlock(oauthInfo, userInfo, nil);
            }
        } else {  //获取失败
            error = [NSError errorWithDomain:@"QQLogin"
                                        code:response.detailRetCode
                                    userInfo:@{@"NSLocalizedDescription": @"登录失败"}];
            if (MyBlock) {
                MyBlock(nil, nil, error);
            }
        }
    }
}


#pragma mark - getter

- (LDSDKQQServiceImplDataVM *)dataVM {
    if (!_dataVM) {
        _dataVM = [LDSDKQQServiceImplDataVM new];
    }
    return _dataVM;
}

@end
