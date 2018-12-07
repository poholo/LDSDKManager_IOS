//
//  LDSDKWechatServiceImp.m
//  Pods
//
//  Created by yangning on 15-1-29.
//
//

#import "LDSDKWechatServiceImp.h"

#import <WechatOpenSDK/WXApi.h>

#import "NSString+LDSDKAdditions.h"
#import "NSDictionary+LDSDKAdditions.h"
#import "UIImage+LDExtend.h"
#import "LDSDKConfig.h"
#import "LDSDKWechatImpDataVM.h"
#import "MMShareConfigDto.h"
#import "MMBaseShareDto.h"
#import "WechatApiExtend.h"

NSString *const kWXPlatformLogin = @"login_wx";
NSString *const kWX_APPID_KEY = @"appid";
NSString *const kWX_APPSECRET_KEY = @"secret";
NSString *const kWX_APPCODE_KEY = @"code";
NSString *const kWX_GET_TOKEN_URL = @"https://api.weixin.qq.com/sns/oauth2/access_token";
NSString *const kWX_GET_USERINFO_URL = @"https://api.weixin.qq.com/sns/userinfo";

@interface LDSDKWechatServiceImp () <WXApiDelegate, NSURLConnectionDataDelegate> {
    NSDictionary *oauthDict;

    void (^MyBlock)(NSDictionary *oauthInfo, NSDictionary *userInfo, NSError *wxerror);

    BOOL _shouldHandleWXPay;
    LDSDKPayCallback _wxCallback;
}

@property(nonatomic, copy) NSString *authAppId;
@property(nonatomic, copy) NSString *authAppSecret;

@property(nonatomic, copy) LDSDKShareCallback shareCallback;
@property(nonatomic, copy) LDSDKPayCallback payCallBack;

@property(nonatomic, strong) LDSDKWechatImpDataVM *dataVM;

@end

@implementation LDSDKWechatServiceImp

#pragma mark -
#pragma mark - 配置部分

- (BOOL)isPlatformAppInstalled {
    return [self.dataVM isPlatformAppInstalled];
}

- (void)registerWithPlatformConfig:(NSDictionary *)config {
    self.dataVM.configDto = [MMShareConfigDto createDto:config];
    NSAssert(self.dataVM.configDto.appId, @"[LDSDKWechatServiceImp] appid == NULL");
    [WXApi registerApp:self.dataVM.configDto.appId enableMTA:YES];
}

- (BOOL)isRegistered {
    return (self.authAppId && [self.authAppId length] && self.authAppSecret && [self.authAppSecret length]);
}

#pragma mark -
#pragma mark - 处理URL回调

- (BOOL)handleResultUrl:(NSURL *)url {
    if ([self payProcessOrderWithPaymentResult:url standbyCallback:NULL]) {
        return YES;
    }
    return [WXApi handleOpenURL:url delegate:self];
}


#pragma mark -
#pragma mark - 登陆部分

- (BOOL)isLoginEnabledOnPlatform {
    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:kWXPlatformLogin];
    if (string.length == 0) {
        return [self isPlatformAppInstalled] && [self isRegistered];
    } else {
        return [string boolValue] && [self isPlatformAppInstalled] && [self isRegistered];
    }
}

- (void)loginToPlatformWithCallback:(LDSDKLoginCallback)callback {
    if (![WXApi isWXAppInstalled] || ![WXApi isWXAppSupportApi]) {
        NSError *error = [NSError errorWithDomain:@"WXLogin"
                                             code:0
                                         userInfo:@{@"NSLocalizedDescription": @"请先安装微信客户端"}];
        if (callback) {
            callback(nil, nil, error);
        }
        return;
    }
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    req.state = @"10000";
//    [self sendReq:req
//         callback:^(BaseResp *resp) {
//             if (callback) {
//                 MyBlock = callback;
//             }
//             if ([resp isKindOfClass:[SendAuthResp class]]) {
//                 SendAuthResp *oauth = (SendAuthResp *) resp;
//                 [self handleWeChatAuthResp:oauth];
//             }
//         }];
}

- (BOOL)handleWeChatAuthResp:(SendAuthResp *)resp {
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        if (resp.errCode == 0) {  //用户同意
            if (resp.code) {
                [self wxTokenWithCode:resp.code];
            }
        } else {  // authResp.errCode == -4 //用户拒绝授权 authResp.errCode == -2 //用户取消
            NSError *error = [NSError errorWithDomain:@"WXLogin"
                                                 code:0
                                             userInfo:@{@"NSLocalizedDescription": @"登录失败"}];

        }
        return YES;
    } else {
        return NO;
    }
}

- (void)wxTokenWithCode:(NSString *)code {
    NSError *error = nil;
    oauthDict = nil;

    if (!code || ![code length]) {
        error = [NSError
                errorWithDomain:@"WXLogin"
                           code:0
                       userInfo:@{@"NSLocalizedDescription": @"登录失败"}];
        if (MyBlock) {
            MyBlock(nil, nil, error);
        }
        return;
    }

    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    paramDict[kWX_APPID_KEY] = self.authAppId;
    paramDict[kWX_APPSECRET_KEY] = self.authAppSecret;//@"wxfe3c0a50a4cd3f92"
    paramDict[@"grant_type"] = @"authorization_code";//@"695852ffc8626d9c4c65a394cc4a7eb7"
    paramDict[kWX_APPCODE_KEY] = code;

    NSMutableURLRequest *request =
            [self requestWithMethod:@"POST" path:kWX_GET_TOKEN_URL parameters:paramDict];

    // 设置

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection == nil) {
        error = [NSError errorWithDomain:@"WXLogin"
                                    code:0
                                userInfo:@{@"NSLocalizedDescription": @"登录失败"}];
        if (MyBlock) {
            MyBlock(nil, nil, error);
        }
    }
}

- (void)getWXUserInfoWithToken:(NSString *)accessToken openId:(NSString *)openId {
    if (!accessToken || ![accessToken length] || !openId || ![openId length]) {
        NSError *error = [NSError
                errorWithDomain:@"WXLogin"
                           code:0
                       userInfo:@{@"NSLocalizedDescription": @"登录失败"}];
        if (MyBlock) {
            MyBlock(nil, nil, error);
        }
        return;
    }

    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    paramDict[kWX_ACCESSTOKEN_KEY] = accessToken;
    paramDict[kWX_OPENID_KEY] = openId;

    NSMutableURLRequest *request =
            [self requestWithMethod:@"POST" path:kWX_GET_USERINFO_URL parameters:paramDict];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection == nil) {
        NSError *error = [NSError errorWithDomain:@"WXLogin"
                                             code:0
                                         userInfo:@{@"NSLocalizedDescription": @"登录失败"}];
        if (MyBlock) {
            MyBlock(nil, nil, error);
        }
    }
}

- (void)logoutFromPlatform {
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
    if (_shouldHandleWXPay) {
        return [WXApi handleOpenURL:url delegate:self];
    }

    return NO;
}

- (void)wxpayOrder:(NSString *)orderString callback:(LDSDKPayCallback)callback {
    NSDictionary *orderDict = [orderString urlParamsDecodeDictionary];

    PayReq *request = [[PayReq alloc] init];
    request.partnerId = [[[orderDict stringForKey:@"partnerId"] URLDecodedString]
            stringByReplacingOccurrencesOfString:@"\""
                                      withString:@""];
    request.prepayId = [[[orderDict stringForKey:@"prepayId"] URLDecodedString]
            stringByReplacingOccurrencesOfString:@"\""
                                      withString:@""];
    request.package = [[[orderDict stringForKey:@"packageValue"] URLDecodedString]
            stringByReplacingOccurrencesOfString:@"\""
                                      withString:@""];
    request.nonceStr = [[[orderDict stringForKey:@"nonceStr"] URLDecodedString]
            stringByReplacingOccurrencesOfString:@"\""
                                      withString:@""];
    NSString *time = [[[orderDict stringForKey:@"timeStamp"] URLDecodedString]
            stringByReplacingOccurrencesOfString:@"\""
                                      withString:@""];
    request.timeStamp = (UInt32) [time longLongValue];
    request.sign = [[[orderDict stringForKey:@"weixinSign"] URLDecodedString]
            stringByReplacingOccurrencesOfString:@"\""
                                      withString:@""];

    _shouldHandleWXPay = YES;
    BOOL result = [WXApi sendReq:request];

    if (!result) {
        _shouldHandleWXPay = NO;
        if (callback) {
            NSError *error = [NSError errorWithDomain:@"wxPay"
                                                 code:0
                                             userInfo:@{@"NSLocalizedDescription": @"无法支付"}];
            callback(nil, error);
        }
    }

    _wxCallback = callback;
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
    MMBaseShareDto *shareDto = [MMBaseShareDto factoryCreateShareDto:exDict];
    SendMessageToWXReq *sendMessageToWXReq = [WechatApiExtend shareObject:shareDto];
    BOOL success = [WXApi sendReq:sendMessageToWXReq];
    if(!success) {
        NSLog(@"WX error");
    }
}


- (void)handleShareResultInActivity:(id)result onComplete:(void (^)(BOOL, NSError *))complete {
    SendMessageToWXResp *response = (SendMessageToWXResp *) result;

    switch (response.errCode) {
        case WXSuccess:
            if (complete) {
                complete(YES, nil);
            }

            break;
        case WXErrCodeUserCancel: {
            NSError *error = [NSError errorWithDomain:@"WXShare"
                                                 code:-2
                                             userInfo:@{@"NSLocalizedDescription": @"用户取消分享"}];
            if (complete) {
                complete(NO, error);
            }
        }
            break;
        default: {
            NSError *error = [NSError errorWithDomain:@"WXShare"
                                                 code:-1
                                             userInfo:@{@"NSLocalizedDescription": @"分享失败"}];
            if (complete) {
                complete(NO, error);
            }
        }

            break;
    }
}

- (BOOL)responseResult:(BaseResp *)resp {
    NSError *error = [self.dataVM respError:resp];
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if (self.shareCallback) {
            self.shareCallback((LDSDKErrorCode) resp.errCode, error);
        }
    }
    return NO;
}

- (BOOL)handleURL:(NSURL *)url {
    BOOL success = [WXApi handleOpenURL:url delegate:self];
    return success;
}

#pragma mark -
#pragma mark - 构建HTTP请求

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters {
    NSParameterAssert(method);

    if (!path) {
        path = @"";
    }

    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *request =
            [[NSMutableURLRequest alloc] initWithURL:url
                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                     timeoutInterval:10];
    [request setHTTPMethod:method];

    if (parameters) {
        NSString *charset = (__bridge NSString *) CFStringConvertEncodingToIANACharSetName(
                CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        [request setValue:[NSString
                        stringWithFormat:@"application/x-www-form-urlencoded; charset=%@",
                                         charset]
       forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[[self LDSDKQueryStringFromParametersWithEncoding:parameters
                                                                      encoding:NSUTF8StringEncoding]
                dataUsingEncoding:NSUTF8StringEncoding]];
    }

    return request;
}

- (NSString *)LDSDKQueryStringFromParametersWithEncoding:(NSDictionary *)parameters
                                                encoding:(NSStringEncoding)stringEncoding {
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (NSString *key in [parameters allKeys]) {
        NSString *value = parameters[key];
        if (!value || [value isEqual:[NSNull null]]) {
            [mutablePairs addObject:LDSDKAFPercentEscapedQueryStringKeyFromStringWithEncoding(
                    [key description], stringEncoding)];
        } else {
            [mutablePairs
                    addObject:[NSString stringWithFormat:
                            @"%@=%@",
                            LDSDKAFPercentEscapedQueryStringKeyFromStringWithEncoding(
                                    [key description], stringEncoding),
                            LDSDKAFPercentEscapedQueryStringValueFromStringWithEncoding(
                                    [value description], stringEncoding)]];
        }
    }
    return [mutablePairs componentsJoinedByString:@"&"];
}

static NSString *const kLDSDKAFCharactersToBeEscapedInQueryString = @":/?&=;+!@#$()',*";

static NSString *LDSDKAFPercentEscapedQueryStringKeyFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    static NSString *const kLDSDKAFCharactersToLeaveUnescapedInQueryStringPairKey = @"[].";
    return (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(
            kCFAllocatorDefault, (__bridge CFStringRef) string,
            (__bridge CFStringRef) kLDSDKAFCharactersToLeaveUnescapedInQueryStringPairKey,
            (__bridge CFStringRef) kLDSDKAFCharactersToBeEscapedInQueryString,
            CFStringConvertNSStringEncodingToEncoding(encoding));
}

static NSString *LDSDKAFPercentEscapedQueryStringValueFromStringWithEncoding(NSString *string,
        NSStringEncoding encoding) {
    return (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(
            kCFAllocatorDefault, (__bridge CFStringRef) string, NULL,
            (__bridge CFStringRef) kLDSDKAFCharactersToBeEscapedInQueryString,
            CFStringConvertNSStringEncodingToEncoding(encoding));
}

#pragma mark - WXApiDelegate

- (void)onReq:(BaseReq *)req {
#ifdef DEBUG
    NSLog(@"[%@]%s", NSStringFromClass([self class]), __FUNCTION__);
#endif
}

- (void)onResp:(BaseResp *)resp {
#ifdef DEBUG
    NSLog(@"[%@]%s", NSStringFromClass([self class]), __FUNCTION__);
#endif
    if ([self.dataVM canResponseResult:resp] && [self responseResult:resp]) {
        return;
    }
    NSError *error = [self.dataVM respError:resp];
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if (self.shareCallback) {
            self.shareCallback((LDSDKErrorCode) resp.errCode, error);
        }
    } else if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *pResp = (PayResp *) resp;
        NSError *error = [NSError errorWithDomain:@"wxPay"
                                             code:resp.errCode
                                         userInfo:@{@"NSLocalizedDescription": resp.errStr}];
        _wxCallback(nil, error);
    }
}


#pragma mark -
#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
}

// 接收数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    if ([urlStr isEqualToString:kWX_GET_TOKEN_URL]) {
        if (data) {
            NSDictionary *resultDic =
                    [NSJSONSerialization JSONObjectWithData:data
                                                    options:NSJSONReadingAllowFragments
                                                      error:nil];
            oauthDict = resultDic;
            if (MyBlock) {
                MyBlock(resultDic, nil, nil);
            }
            [self getWXUserInfoWithToken:resultDic[kWX_ACCESSTOKEN_KEY]
                                  openId:resultDic[kWX_OPENID_KEY]];
        } else {
            NSError *error = [NSError
                    errorWithDomain:@"WXLogin"
                               code:0
                           userInfo:@{@"NSLocalizedDescription": @"登录失败"}];
            if (MyBlock) {
                MyBlock(nil, nil, error);
            }
        }
    } else if ([urlStr isEqualToString:kWX_GET_USERINFO_URL]) {
        if (data) {
            NSDictionary *resultDic =
                    [NSJSONSerialization JSONObjectWithData:data
                                                    options:NSJSONReadingAllowFragments
                                                      error:nil];
            if (MyBlock) {
                MyBlock(oauthDict, resultDic, nil);
            }
        } else {
            NSError *error = [NSError errorWithDomain:@"WXLogin"
                                                 code:0
                                             userInfo:@{@"NSLocalizedDescription": @"登录失败"}];
            if (MyBlock) {
                MyBlock(nil, nil, error);
            }
        }
    }
}

// 数据接收完毕
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
}

// 返回错误
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (MyBlock) {
        MyBlock(nil, nil, error);
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
