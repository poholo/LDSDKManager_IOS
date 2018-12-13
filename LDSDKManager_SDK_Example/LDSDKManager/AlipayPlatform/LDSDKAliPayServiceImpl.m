//
//  LDSDKAliPayServiceImpl.m
//  LDSDKManager
//
//  Created by ss on 15/8/21.
//  Copyright (c) 2015年 张海洋. All rights reserved.
//

#import "LDSDKAliPayServiceImpl.h"

#import <AlipaySDK/AlipaySDK.h>

#import "LDSDKConfig.h"

@interface LDSDKAliPayServiceImpl ()

@property(strong, nonatomic) NSString *aliPayScheme;

@end

@implementation LDSDKAliPayServiceImpl

+ (instancetype)sharedService {
    static LDSDKAliPayServiceImpl *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)authPlatformCallback:(LDSDKAuthCallback)callback {

}

- (void)authPlatformQRCallback:(LDSDKAuthCallback)callBack {

}

- (void)authLogoutPlatformCallback:(LDSDKAuthCallback)callBack {

}


#pragma mark -
#pragma mark - 配置部分

- (BOOL)isPlatformAppInstalled {
    return YES;
}


- (NSError *)registerWithPlatformConfig:(NSDictionary *)config {
    if (config == nil || config.allKeys.count == 0) return nil;

    NSString *appScheme = config[LDSDKConfigAppSchemeKey];
    if (appScheme && [appScheme length]) {
        self.aliPayScheme = appScheme;
    }
    return nil;
}

- (BOOL)isRegistered {
    return (self.aliPayScheme && [self.aliPayScheme length]);
}

- (BOOL)handleResultUrl:(NSURL *)url {
    return [self payProcessOrderWithPaymentResult:url standbyCallback:NULL];
}


#pragma mark -
#pragma mark -  支付部分

- (void)payOrder:(NSString *)orderString callback:(LDSDKPayCallback)callback {
    NSLog(@"AliPay");
    [self alipayOrder:orderString callback:callback];
}

- (BOOL)payProcessOrderWithPaymentResult:(NSURL *)url
                         standbyCallback:(void (^)(NSDictionary *))callback {
    if ([url.scheme.lowercaseString isEqualToString:self.aliPayScheme]) {
        [self aliPayProcessOrderWithPaymentResult:url standbyCallback:callback];
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - alipay

- (void)alipayOrder:(NSString *)orderString callback:(LDSDKPayCallback)callback {
    [[AlipaySDK defaultService]
            payOrder:orderString
          fromScheme:self.aliPayScheme
            callback:^(NSDictionary *resultDic) {
                NSString *signString = resultDic[@"result"];
                NSString *memo = resultDic[@"memo"];
                NSInteger resultStatus = [resultDic[@"resultStatus"] integerValue];
                if (callback) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (resultStatus == 9000) {
                            callback(signString, nil);
                        } else {
                            NSError *error = [NSError errorWithDomain:@"AliPay"
                                                                 code:0
                                                             userInfo:@{@"NSLocalizedDescription": memo}];
                            callback(signString, error);
                        }

                    });
                }
            }];
}

- (void)aliPayProcessOrderWithPaymentResult:(NSURL *)url
                            standbyCallback:(void (^)(NSDictionary *resultDic))callback {
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:callback];
}

@end
