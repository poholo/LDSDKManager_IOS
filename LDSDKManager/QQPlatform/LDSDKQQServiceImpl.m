//
//  LDSDKQQServiceImpl.m
//  TestThirdPlatform
//
//  Created by ss on 15/8/17.
//  Copyright (c) 2015年 Lede. All rights reserved.
//

#import "LDSDKQQServiceImpl.h"
#import "UIImage+LDSDKShare.h"

#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/QQApiInterface.h>

#define kQQPlatformLogin @"login_qq"

static NSArray *permissions = nil;

@interface LDSDKQQServiceImpl () <TencentSessionDelegate, QQApiInterfaceDelegate> {
    BOOL isLogining;
    NSError *error;
    TencentOAuth *tencentOAuth;

    void (^MyBlock)(NSDictionary *oauthInfo, NSDictionary *userInfo, NSError *qqerror);

    LDSDKQQCallbackBlock shareBlock;
}

@property(nonatomic, copy) NSString *authAppId;
@property(nonatomic, copy) NSString *authAppKey;

@end

@implementation LDSDKQQServiceImpl

+ (instancetype)sharedService {
    static LDSDKQQServiceImpl *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        isLogining = NO;
        permissions = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_USER_INFO,
                                                kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, nil];
    }
    return self;
}


#pragma mark -
#pragma mark - 配置部分

//判断平台是否可用
- (BOOL)isPlatformAppInstalled {
    return [QQApi isQQInstalled] && [QQApi isQQSupportApi];
}

//注册平台
- (void)registerWithPlatformConfig:(NSDictionary *)config {
    if (config == nil || config.allKeys.count == 0) return;

    NSString *qqAppId = config[LDSDKConfigAppIdKey];
    if (qqAppId && [qqAppId length]) {
        [self registerQQPlatformAppId:qqAppId];
    }
}

- (BOOL)registerQQPlatformAppId:(NSString *)appId {
    tencentOAuth = [[TencentOAuth alloc] initWithAppId:appId andDelegate:self];
    self.authAppId = appId;
    return YES;
}

- (BOOL)isRegistered {
    return (self.authAppId && [self.authAppId length]);
}


#pragma mark -
#pragma mark - 处理URL回调

- (BOOL)handleResultUrl:(NSURL *)url {
    return [self handleOpenURL:url];
}

- (BOOL)handleOpenURL:(NSURL *)url {
    return [TencentOAuth HandleOpenURL:url] || [QQApiInterface handleOpenURL:url delegate:self];
}


#pragma mark -
#pragma mark - 登陆部分

- (BOOL)isLoginEnabledOnPlatform {
    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:kQQPlatformLogin];
    if (string.length == 0) {
        return YES;
    } else {
        return [string boolValue];
    }
}

- (void)loginToPlatformWithCallback:(LDSDKLoginCallback)callback {
    if (![QQApi isQQInstalled] || ![QQApi isQQSupportApi]) {
        error = [NSError
                errorWithDomain:@"QQLogin"
                           code:0
                       userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"请先安装QQ客户端",
                                                                           @"NSLocalizedDescription",
                                       nil]];
        if (callback) {
            callback(nil, nil, error);
        }
        return;
    }
    if ([QQApi isQQInstalled]) {  //手机QQ登录流程
        NSLog(@"login by QQ oauth = %@", tencentOAuth);
        if (callback) {
            MyBlock = callback;
        }
        error = nil;
        isLogining = YES;
        if (!tencentOAuth) {
            NSLog(@"tencentOauth && permissions = %@", permissions);
            tencentOAuth = [[TencentOAuth alloc] initWithAppId:self.authAppId andDelegate:self];
        }
        //此处可set Token、oppenId、有效期 等参数
        [tencentOAuth authorize:permissions];
    }
}

- (void)logoutFromPlatform {

    [tencentOAuth logout:self];
    MyBlock = nil;
    tencentOAuth = nil;
}


#pragma mark -
#pragma mark - 分享部分

- (void)shareWithContent:(NSDictionary *)content
             shareModule:(NSUInteger)shareModule
              onComplete:(LDSDKShareCallback)complete {
    if (![QQApi isQQInstalled] || ![QQApi isQQSupportApi]) {
        error = [NSError
                errorWithDomain:@"QQShare"
                           code:0
                       userInfo:@{@"NSLocalizedDescription": @"请先安装QQ客户端"}];
        if (complete) {
            complete(NO, error);
        }
        return;
    }


    //构造QQ、空间分享内容
    NSString *title = content[LDSDKShareContentTitleKey];
    NSString *description = content[LDSDKShareContentDescriptionKey];
    NSString *urlString = content[LDSDKShareContentWapUrlKey];
    LDSDKShareType shareType = (LDSDKShareType) [content[LDSDKShareTypeKey] integerValue];

    QQApiObject *messageObj = nil;
    UIImage *oldImage = content[@"image"];
    switch (shareType) {
        case LDSDKShareTypeContent: {
            //原图图片信息
            UIImage *image = oldImage;
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
            NSData *thumbData = [NSData dataWithData:imageData];
            if (oldImage) {
                //缩略图片
                CGSize thumbSize = image.size;
                UIImage *thumbImage = image;
                NSData *thumbData = imageData;
                while (thumbData.length > 1000 * 1024) {  //缩略图不能超过1M
                    thumbSize = CGSizeMake(thumbSize.width / 1.5f, thumbSize.height / 1.5f);
                    thumbImage = [thumbImage LDSDKShare_resizedImage:thumbSize
                                                interpolationQuality:kCGInterpolationDefault];
                    thumbData = UIImageJPEGRepresentation(thumbImage, 0.5);
                }
            }
            messageObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:urlString]
                                                  title:title
                                            description:description
                                       previewImageData:thumbData];

        }
            break;
        case LDSDKShareTypeImage: {
            //原图图片信息
            UIImage *image = oldImage;
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
            //内容图片(大图)
            CGSize contentSize = image.size;
            UIImage *contentImage = image;
            NSData *contentData = [NSData dataWithData:imageData];
            if (contentData.length > 5000 * 1024) {  //图片不能超过5M
                contentSize = CGSizeMake(contentSize.width / 1.5f, contentSize.height / 1.5f);
                contentImage = [contentImage LDSDKShare_resizedImage:contentSize
                                                interpolationQuality:kCGInterpolationDefault];
                contentData = UIImageJPEGRepresentation(contentImage, 0.5);
            }

            //缩略图片
            CGSize thumbSize = image.size;
            UIImage *thumbImage = image;
            NSData *thumbData = [NSData dataWithData:imageData];
            while (thumbData.length > 1000 * 1024) {  //缩略图不能超过1M
                thumbSize = CGSizeMake(thumbSize.width / 1.5f, thumbSize.height / 1.5f);
                thumbImage = [thumbImage LDSDKShare_resizedImage:thumbSize
                                            interpolationQuality:kCGInterpolationDefault];
                thumbData = UIImageJPEGRepresentation(thumbImage, 0.5);
            }

            messageObj = [QQApiImageObject objectWithData:contentData
                                         previewImageData:thumbData
                                                    title:title
                                              description:description];
        }
            break;
        case LDSDKShareTypeOther: {

        }
            break;
    }

    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:messageObj];
    QQApiSendResultCode resultCode =
            [self sendReq:req
              shareModule:shareModule
                 callback:^(QQBaseResp *resp) {
                     if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
                         [self handleShareResultInActivity:resp onComplete:complete];
                     }
                 }];
    if (resultCode != EQQAPISENDSUCESS) {
        error = [NSError
                errorWithDomain:@"QQShare"
                           code:-2
                       userInfo:@{@"NSLocalizedDescription": @"分享失败"}];
        if (complete) {
            complete(NO, error);
        }
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

//发送请求
- (QQApiSendResultCode)sendReq:(QQBaseReq *)req
                   shareModule:(NSUInteger)shareModule
                      callback:(LDSDKQQCallbackBlock)callbackBlock {
    shareBlock = callbackBlock;
    if (shareModule == 1) {
        return [QQApiInterface sendReq:req];
    } else if (shareModule == 2) {
        return [QQApiInterface SendReqToQZone:req];
    } else {
        return EQQAPIMESSAGETYPEINVALID;
    }
}


#pragma mark -
#pragma mark - WXApiDelegate

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
    if (tencentOAuth.accessToken && 0 != [tencentOAuth.accessToken length]) {
        NSMutableDictionary *oauthInfo = [NSMutableDictionary dictionary];
        [oauthInfo setObject:tencentOAuth.accessToken forKey:kQQ_TOKEN_KEY];
        if (tencentOAuth.expirationDate) {
            [oauthInfo setObject:tencentOAuth.expirationDate forKey:kQQ_EXPIRADATE_KEY];
        }
        if (tencentOAuth.openId) {
            [oauthInfo setObject:tencentOAuth.openId forKey:kQQ_OPENID_KEY];
        }
        if (MyBlock) {
            MyBlock(oauthInfo, nil, nil);
        }
        [tencentOAuth getUserInfo];

    } else {  //登录失败，没有获取授权accesstoken
        error = [NSError
                errorWithDomain:@"QQLogin"
                           code:0
                       userInfo:@{@"NSLocalizedDescription": @"登录失败"}];
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
#pragma mark - TencentSessionDelegate

//退出登录的回调
- (void)tencentDidLogout {
    NSLog(@"退出登录");
}

// API授权不够，需增量授权
- (BOOL)tencentNeedPerformIncrAuth:(TencentOAuth *)tencentOAuth
                   withPermissions:(NSArray *)permissions {
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
                [oauthInfo setObject:tencentOAuth.accessToken forKey:kQQ_TOKEN_KEY];
                if (tencentOAuth.expirationDate) {
                    [oauthInfo setObject:tencentOAuth.expirationDate forKey:kQQ_EXPIRADATE_KEY];
                }
                if (tencentOAuth.openId) {
                    [oauthInfo setObject:tencentOAuth.openId forKey:kQQ_OPENID_KEY];
                }

                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                NSString *nickName = [response.jsonResponse objectForKey:kQQ_NICKNAME_KEY];
                NSString *avatarUrl = [response.jsonResponse objectForKey:kQQ_AVATARURL_KEY];
                if (nickName && [nickName length]) {
                    [userInfo setObject:nickName forKey:kQQ_NICKNAME_KEY];
                }
                if (avatarUrl) {
                    [userInfo setObject:avatarUrl forKey:kQQ_AVATARURL_KEY];
                }

                MyBlock(oauthInfo, userInfo, nil);
            }
        } else {  //获取失败
            error = [NSError
                    errorWithDomain:@"QQLogin"
                               code:response.detailRetCode
                           userInfo:@{@"NSLocalizedDescription": @"登录失败"}];
            if (MyBlock) {
                MyBlock(nil, nil, error);
            }
        }
    }
}

@end
