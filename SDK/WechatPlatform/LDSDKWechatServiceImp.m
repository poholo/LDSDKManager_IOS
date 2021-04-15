//
//  LDSDKWechatServiceImp.m
//  Pods
//
//  Created by yangning on 15-1-29.
//
//

#import "LDSDKWechatServiceImp.h"

#import <WechatOpenSDK/WXApi.h>
#import <MCBase/MCLog.h>

#import "NSString+LDSDKAdditions.h"
#import "NSDictionary+LDSDKAdditions.h"
#import "LDSDKWechatImpDataVM.h"
#import "MCShareConfigDto.h"
#import "MCBaseShareDto.h"
#import "WechatApiExtend.h"
#import "NSDictionary+LDExtend.h"

NSString *const kWX_APPID_KEY = @"appid";
NSString *const kWX_APPSECRET_KEY = @"secret";
NSString *const kWX_APPCODE_KEY = @"code";
NSString *const kWX_GET_TOKEN_URL = @"https://api.weixin.qq.com/sns/oauth2/access_token";
NSString *const kWX_GET_USERINFO_URL = @"https://api.weixin.qq.com/sns/userinfo";


@interface LDSDKWechatServiceImp () <WXApiDelegate, NSURLConnectionDataDelegate>

@property(nonatomic, copy) LDSDKShareCallback shareCallback;
@property(nonatomic, copy) LDSDKPayCallback payCallBack;
@property(nonatomic, copy) LDSDKAuthCallback authCallback;


@property(nonatomic, strong) LDSDKWechatImpDataVM *dataVM;

@end

@implementation LDSDKWechatServiceImp

#pragma mark -
#pragma mark - 配置部分

- (BOOL)isPlatformAppInstalled {
    return [self.dataVM isPlatformAppInstalled];
}

- (NSError *)registerWithPlatformConfig:(NSDictionary *)config {
    self.dataVM.configDto = [MCShareConfigDto createDto:config];
    NSError *error = [self.dataVM registerValidate];
    BOOL success = [WXApi registerApp:self.dataVM.configDto.appId universalLink:self.dataVM.configDto.redirectURI];
    if (!success) {
        error = [NSError errorWithDomain:kErrorDomain code:LDSDKErrorCodeCommon userInfo:@{kErrorMessage: @"Wechat register error"}];
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

#pragma mark - auth

- (void)authPlatformCallback:(LDSDKAuthCallback)callback ext:(NSDictionary *)extDict {
    self.authCallback = callback;
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    req.state = @"10000";
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [WXApi sendAuthReq:req viewController:viewController delegate:self completion:nil];
}


- (void)authPlatformQRCallback:(LDSDKAuthCallback)callback ext:(NSDictionary *)extDict {
    self.authCallback = callback;
    if (self.authCallback) {
        NSError *error = [NSError errorWithDomain:kErrorDomain code:LDSDKLoginFailed userInfo:@{kErrorMessage: @"Not support QR Auth except[公众号登录]"}];
        self.authCallback(LDSDKLoginFailed, error, nil, nil);
    }
}

- (void)reqAuthCode:(NSString *)code {
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    paramDict[kWX_APPID_KEY] = self.dataVM.configDto.appId;
    paramDict[kWX_APPSECRET_KEY] = self.dataVM.configDto.appSecret;//@"wxfe3c0a50a4cd3f92"
    paramDict[@"grant_type"] = @"authorization_code";//@"695852ffc8626d9c4c65a394cc4a7eb7"
    paramDict[kWX_APPCODE_KEY] = code;

    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:kWX_GET_TOKEN_URL parameters:paramDict];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)reqUserInfo:(NSString *)accessToken openId:(NSString *)openId {
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    paramDict[@"access_token"] = accessToken;
    paramDict[@"openid"] = openId;

    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:kWX_GET_USERINFO_URL parameters:paramDict];

    [[NSURLSession sharedSession] dataTaskWithRequest:request];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

}

- (void)authLogoutPlatformCallback:(LDSDKAuthCallback)callBack {
    self.authCallback = callBack;
    self.dataVM.authDict = nil;
    self.dataVM.code = nil;
    self.dataVM.userInfo = nil;
    if (self.authCallback) {
        self.authCallback(LDSDKLoginSuccess, nil, nil, nil);
    }
}


#pragma mark -
#pragma mark - 支付部分

- (void)payOrder:(NSString *)orderString callback:(LDSDKPayCallback)callback {
    if (![WXApi isWXAppInstalled] || ![WXApi isWXAppSupportApi]) {
        if (callback) {
            NSError *error = [NSError
                    errorWithDomain:@"wxPay"
                               code:0
                           userInfo:@{@"NSLocalizedDescription": @"请先安装微信客户端"}];
            callback(nil, error);
        }
        return;
    }
    [self wxpayOrder:orderString callback:callback];
}

- (BOOL)payProcessOrderWithPaymentResult:(NSURL *)url
                         standbyCallback:(void (^)(NSDictionary *))callback {
    return [WXApi handleOpenURL:url delegate:self];

}

- (void)wxpayOrder:(NSString *)orderString callback:(LDSDKPayCallback)callback {
    self.payCallBack = callback;
    NSDictionary *orderDict = [orderString urlParamsDecodeDictionary];

    PayReq *request = [[PayReq alloc] init];
    request.partnerId = orderDict[@"partnerId"];
    request.prepayId = orderDict[@"prepayId"];
    request.package = orderDict[@"packageValue"];
    request.nonceStr = orderDict[@"nonceStr"];
    request.timeStamp = (UInt32)[orderDict[@"timeStamp"] longLongValue];
    request.sign = orderDict[@"sign"];

    [WXApi sendReq:request completion:^(BOOL success) {
        if (!success) {
            if (callback) {
                NSError *error = [NSError errorWithDomain:@"wxPay"
                                                     code:0
                                                 userInfo:@{@"NSLocalizedDescription": @"无法支付"}];
                callback(nil, error);
            }
        }

    }];

    
}


#pragma mark -
#pragma mark - 分享部分

- (void)shareContent:(NSDictionary *)exDict {
    NSError *error = [self.dataVM supportContinue:@"WechatShare"];
    LDSDKShareCallback callback = exDict[LDSDKShareCallBackKey];
    if (error) {
        if (callback) {
            callback(LDSDKErrorUninstallPlatformApp, error);
        }
        return;
    }
    self.shareCallback = callback;
    MCBaseShareDto *shareDto = [MCBaseShareDto factoryCreateShareDto:exDict];
    SendMessageToWXReq *sendMessageToWXReq = [WechatApiExtend shareObject:shareDto];

    if (!shareDto || !sendMessageToWXReq) {
        if (self.shareCallback) {
            NSError *err = [NSError errorWithDomain:kErrorDomain code:LDSDKErrorCodeUnsupport userInfo:@{kErrorMessage: @"Not support: check params"}];
            self.shareCallback(LDSDKErrorCodeUnsupport, err);
        }
        return;
    }

    __weak typeof (self) weakSelf = self;
    [WXApi sendReq:sendMessageToWXReq completion:^(BOOL success) {
        if (!success) {
            __strong typeof (weakSelf) strongSelf = weakSelf;
              NSError *err = [NSError errorWithDomain:kErrorDomain code:LDSDKErrorCodeCommon userInfo:@{kErrorMessage: @"初始化请求失败"}];
              if (strongSelf.shareCallback) {
                  strongSelf.shareCallback((LDSDKErrorCode) err.code, err);
              }
          }
    }];
  
}

- (BOOL)responseResult:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if (self.shareCallback) {
            NSError *error = [self.dataVM respError:resp];
            self.shareCallback((LDSDKErrorCode) error.code, error);
            return YES;
        }
    } else if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthResp *) resp;
        self.dataVM.code = authResp.code;
        if (self.dataVM.code.length > 0) {
            [self reqAuthCode:self.dataVM.code];
        } else {
            if (self.authCallback) {
                NSError *error = [NSError errorWithDomain:kErrorDomain code:LDSDKLoginUserCancel userInfo:@{kErrorMessage: @"用户取消"}];
                self.authCallback(LDSDKLoginUserCancel, error, nil, nil);
            }
        }
        return YES;
    }
    return NO;
}

- (BOOL)handleURL:(NSURL *)url {
    BOOL success = [WXApi handleOpenURL:url delegate:self];
    if (!success) {
        success = [self payProcessOrderWithPaymentResult:url standbyCallback:NULL];
    }
    return success;
}

- (BOOL)handleActivity:(NSUserActivity *)activity {
    BOOL success = [WXApi handleOpenUniversalLink:activity delegate:self];
    return success;
}

#pragma mark - WXApiDelegate

- (void)onReq:(BaseReq *)req {
    MCLog(@"[%@]%s", NSStringFromClass([self class]), __FUNCTION__);
}

- (void)onResp:(BaseResp *)resp {
    MCLog(@"[%@]%s", NSStringFromClass([self class]), __FUNCTION__);

    if ([self.dataVM canResponseShareResult:resp] && [self responseResult:resp]) {
        return;
    }

    if ([self.dataVM canResponseAuthResult:resp] && [self responseResult:resp]) {
        return;
    }

    NSError *error = [self.dataVM respError:resp];
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if (self.shareCallback) {
            self.shareCallback((LDSDKErrorCode) error.code, error);
        }
    } else if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *payResp = (PayResp *) resp;
        error = [NSError errorWithDomain:@"wxPay"
                                    code:resp.errCode
                                userInfo:@{@"NSLocalizedDescription": resp.errStr}];
        if (self.payCallBack) {
            self.payCallBack(payResp.returnKey, error);
        }
    }
}


#pragma mark -
#pragma mark - 构建HTTP请求

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
    NSParameterAssert(method);
    if (!path) {
        path = @"";
    }

    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:10];
    [request setHTTPMethod:method];

    if (parameters) {
        NSString *charset = (__bridge NSString *) CFStringConvertEncodingToIANACharSetName(
                CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[[parameters query] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    return request;
}

#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    if ([urlStr isEqualToString:kWX_GET_TOKEN_URL]) {
        NSError *error = [self.dataVM validateAuthToken:resultDict];
        if (error) {
            if (self.authCallback) {
                self.authCallback((LDSDKLoginCode) error.code, error, nil, nil);
            }
        } else {
            self.dataVM.authDict = [self.dataVM wrapAuth:resultDict];
            if (self.authCallback) {
                self.authCallback(LDSDKLoginSuccess, nil, self.dataVM.authDict, nil);
            }
            [self reqUserInfo:self.dataVM.authDict[LDSDK_TOKEN_KEY] openId:self.dataVM.authDict[LDSDK_OPENID_KEY]];
        }
    } else if ([urlStr isEqualToString:kWX_GET_USERINFO_URL]) {
        NSError *error = [self.dataVM validateAuthToken:resultDict];
        if (error) {
            if (self.authCallback) {
                self.authCallback((LDSDKLoginCode) error.code, error, nil, nil);
            }
        } else {
            self.dataVM.userInfo = [self.dataVM wrapAuthUserInfo:resultDict];
            if (self.authCallback) {
                self.authCallback(LDSDKLoginSuccess, nil, self.dataVM.authDict, self.dataVM.userInfo);
            }
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    MCLog(@"connectionDidFinishLoading");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (self.authCallback) {
        NSError *err = [NSError errorWithDomain:kErrorDomain code:LDSDKLoginNoNet userInfo:error.userInfo];
        self.authCallback(LDSDKLoginNoNet, err, nil, nil);
    }
}


#pragma mark - getter

- (LDSDKWechatImpDataVM *)dataVM {
    if (!_dataVM) {
        _dataVM = [LDSDKWechatImpDataVM new];
    }
    return _dataVM;
}
@end
