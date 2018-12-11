//
// Created by majiancheng on 2018/12/3.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "LDSDKManagerDataVM.h"

#import "LDSDKConfig.h"
#import "LDSDKShareService.h"
#import "LDSDKWeiboServiceImpl.h"
#import "LDSDKQQServiceImp.h"
#import "LDSDKAliPayServiceImpl.h"
#import "LDSDKWechatServiceImp.h"
#import "LDSDKPayService.h"
#import "LDSDKRegisterService.h"
#import "LDSDKAuthService.h"
#import "LDSDKHandleURLProtocol.h"

@interface LDSDKManagerDataVM ()


@property(nonatomic, strong) LDSDKAliPayServiceImpl *aliPayService;
@property(nonatomic, strong) LDSDKQQServiceImp *qqService;
@property(nonatomic, strong) LDSDKWeiboServiceImpl *weiboService;
@property(nonatomic, strong) LDSDKWechatServiceImp *wxService;

@end

@implementation LDSDKManagerDataVM

- (void)prepare {
    self.registerServiceDict[@(LDSDKPlatformQQ)] = self.qqService;
    self.registerServiceDict[@(LDSDKPlatformWeChat)] = self.wxService;
    self.registerServiceDict[@(LDSDKPlatformWeibo)] = self.weiboService;
    self.registerServiceDict[@(LDSDKPlatformAliPay)] = self.aliPayService;

    self.shareServiceDict[@(LDSDKPlatformQQ)] = self.qqService;
    self.shareServiceDict[@(LDSDKPlatformWeChat)] = self.wxService;
    self.shareServiceDict[@(LDSDKPlatformWeibo)] = self.weiboService;

    self.payServiceDict[@(LDSDKPlatformWeChat)] = self.wxService;
    self.payServiceDict[@(LDSDKPlatformAliPay)] = self.aliPayService;

    self.authServiceDict[@(LDSDKPlatformWeChat)] = self.wxService;
    self.authServiceDict[@(LDSDKPlatformAliPay)] = self.aliPayService;
    self.authServiceDict[@(LDSDKPlatformQQ)] = self.qqService;
    self.authServiceDict[@(LDSDKPlatformWeibo)] = self.weiboService;
}

- (void)register:(NSArray<NSDictionary *> *)configs {
    LDLog(@"*******[PlatformRegister]Start************");
    for (NSDictionary *config in configs) {
        NSNumber *platformType = config[LDSDKConfigAppPlatformTypeKey];
        id <LDSDKRegisterService> service = self.registerServiceDict[platformType];
        NSError *error = [service registerWithPlatformConfig:config];
        LDLog(@"[Code]%zd %@", error.code, error.userInfo[kErrorMessage]);
    }
    LDLog(@"*******[PlatformRegister]End************");
}

#pragma mark - getter

- (NSMutableDictionary<NSNumber *, id <LDSDKRegisterService, LDSDKHandleURLProtocol>> *)registerServiceDict {
    if (!_registerServiceDict) {
        _registerServiceDict = [NSMutableDictionary new];
    }
    return _registerServiceDict;
}

- (NSMutableDictionary<NSNumber *, id <LDSDKShareService>> *)shareServiceDict {
    if (!_shareServiceDict) {
        _shareServiceDict = [NSMutableDictionary new];
    }
    return _shareServiceDict;
}

- (NSMutableDictionary<NSNumber *, id <LDSDKShareService>> *)payServiceDict {
    if (!_payServiceDict) {
        _payServiceDict = [NSMutableDictionary new];
    }
    return _payServiceDict;
}

- (NSMutableDictionary<NSNumber *, id <LDSDKShareService>> *)authServiceDict {
    if (!_authServiceDict) {
        _authServiceDict = [NSMutableDictionary new];
    }
    return _authServiceDict;
}

- (LDSDKAliPayServiceImpl *)aliPayService {
    if (!_aliPayService) {
        _aliPayService = [LDSDKAliPayServiceImpl new];
    }
    return _aliPayService;
}

- (LDSDKQQServiceImp *)qqService {
    if (!_qqService) {
        _qqService = [LDSDKQQServiceImp new];
    }
    return _qqService;
}

- (LDSDKWeiboServiceImpl *)weiboService {
    if (!_weiboService) {
        _weiboService = [LDSDKWeiboServiceImpl new];
    }
    return _weiboService;
}

- (LDSDKWechatServiceImp *)wxService {
    if (!_wxService) {
        _wxService = [LDSDKWechatServiceImp new];
    }
    return _wxService;
}


@end
