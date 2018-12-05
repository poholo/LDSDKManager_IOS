//
// Created by majiancheng on 2018/12/3.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "LDSDKManagerDataVM.h"

#import "LDSDKConfig.h"
#import "LDSDKShareService.h"
#import "LDSDKYXServiceImpl.h"
#import "LDSDKWeiboServiceImpl.h"
#import "LDSDKQQServiceImpl.h"
#import "LDSDKAliPayServiceImpl.h"
#import "LDSDKWXServiceImpl.h"
#import "LDSDKPayService.h"
#import "LDSDKAuthService.h"

@interface LDSDKManagerDataVM ()


@property(nonatomic, strong) LDSDKAliPayServiceImpl *aliPayService;
@property(nonatomic, strong) LDSDKQQServiceImpl *qqService;
@property(nonatomic, strong) LDSDKWeiboServiceImpl *weiboService;
@property(nonatomic, strong) LDSDKWXServiceImpl *wxService;
@property(nonatomic, strong) LDSDKYXServiceImpl *yxService;

@end

@implementation LDSDKManagerDataVM

- (void)prepare {
    self.shareServiceDict[@(LDSDKPlatformQQ)] = self.qqService;
    self.shareServiceDict[@(LDSDKPlatformWeChat)] = self.wxService;
    self.shareServiceDict[@(LDSDKPlatformYiXin)] = self.yxService;
    self.shareServiceDict[@(LDSDKPlatformWeibo)] = self.weiboService;

    self.payServiceDict[@(LDSDKPlatformWeChat)] = self.wxService;
    self.payServiceDict[@(LDSDKPlatformAliPay)] = self.aliPayService;

    self.authServiceDict[@(LDSDKPlatformWeChat)] = self.wxService;
    self.authServiceDict[@(LDSDKPlatformAliPay)] = self.wxService;
}

- (void)register:(NSArray<NSDictionary *> *)configs {

}

#pragma mark - getter

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

- (LDSDKQQServiceImpl *)qqService {
    if (!_qqService) {
        _qqService = [LDSDKQQServiceImpl new];
    }
    return _qqService;
}

- (LDSDKWeiboServiceImpl *)weiboService {
    if (!_weiboService) {
        _weiboService = [LDSDKWeiboServiceImpl new];
    }
    return _weiboService;
}

- (LDSDKWXServiceImpl *)wxService {
    if (!_wxService) {
        _wxService = [LDSDKWXServiceImpl new];
    }
    return _wxService;
}

- (LDSDKYXServiceImpl *)yxService {
    if (!_yxService) {
        _yxService = [LDSDKYXServiceImpl new];
    }
    return _yxService;
}


@end