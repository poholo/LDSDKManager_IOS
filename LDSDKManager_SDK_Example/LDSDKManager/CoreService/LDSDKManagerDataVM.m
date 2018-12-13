//
// Created by majiancheng on 2018/12/3.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "LDSDKManagerDataVM.h"

#import "LDSDKConfig.h"
#import "LDSDKShareService.h"
#import "LDSDKPayService.h"
#import "LDSDKRegisterService.h"
#import "LDSDKAuthService.h"
#import "LDSDKHandleURLProtocol.h"

@interface LDSDKManagerDataVM ()


@property(nonatomic, strong) id <LDSDKAuthService, LDSDKRegisterService, LDSDKPayService, LDSDKHandleURLProtocol> aliPayService;
@property(nonatomic, strong) id <LDSDKAuthService, LDSDKRegisterService, LDSDKShareService, LDSDKPayService, LDSDKHandleURLProtocol> qqService;
@property(nonatomic, strong) id <LDSDKAuthService, LDSDKRegisterService, LDSDKShareService, LDSDKPayService, LDSDKHandleURLProtocol> weiboService;
@property(nonatomic, strong) id <LDSDKAuthService, LDSDKRegisterService, LDSDKShareService, LDSDKPayService, LDSDKHandleURLProtocol> wxService;

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

- (NSMutableDictionary<NSNumber *, id <LDSDKPayService>> *)payServiceDict {
    if (!_payServiceDict) {
        _payServiceDict = [NSMutableDictionary new];
    }
    return _payServiceDict;
}

- (NSMutableDictionary<NSNumber *, id <LDSDKAuthService>> *)authServiceDict {
    if (!_authServiceDict) {
        _authServiceDict = [NSMutableDictionary new];
    }
    return _authServiceDict;
}

- (id <LDSDKAuthService, LDSDKRegisterService, LDSDKPayService, LDSDKHandleURLProtocol>)aliPayService {
    if (!_aliPayService) {
        _aliPayService = (id <LDSDKAuthService, LDSDKRegisterService, LDSDKPayService, LDSDKHandleURLProtocol>) [NSClassFromString(@"LDSDKAliPayServiceImpl") new];
    }
    return _aliPayService;
}

- (id <LDSDKAuthService, LDSDKRegisterService, LDSDKShareService, LDSDKPayService, LDSDKHandleURLProtocol>)qqService {
    if (!_qqService) {
        _qqService = (id <LDSDKAuthService, LDSDKRegisterService, LDSDKShareService, LDSDKPayService, LDSDKHandleURLProtocol>) [NSClassFromString(@"LDSDKQQServiceImp") new];
    }
    return _qqService;
}

- (id <LDSDKAuthService, LDSDKRegisterService, LDSDKShareService, LDSDKPayService, LDSDKHandleURLProtocol>)weiboService {
    if (!_weiboService) {
        _weiboService = (id <LDSDKAuthService, LDSDKRegisterService, LDSDKShareService, LDSDKPayService, LDSDKHandleURLProtocol>) [NSClassFromString(@"LDSDKWeiboServiceImpl") new];
    }
    return _weiboService;
}

- (id <LDSDKAuthService, LDSDKRegisterService, LDSDKShareService, LDSDKPayService, LDSDKHandleURLProtocol>)wxService {
    if (!_wxService) {
        _wxService = (id <LDSDKAuthService, LDSDKRegisterService, LDSDKShareService, LDSDKPayService, LDSDKHandleURLProtocol>) [NSClassFromString(@"LDSDKWechatServiceImp") new];
    }
    return _wxService;
}


@end
