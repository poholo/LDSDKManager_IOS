//
//  LDSDKManager.m
//  LDSDKManager
//
//  Created by ss on 15/8/25.
//  Copyright (c) 2015年 张海洋. All rights reserved.
//

#import "LDSDKManager.h"

#import "LDSDKRegisterService.h"
#import "LDSDKPayService.h"
#import "LDSDKAuthService.h"
#import "LDSDKShareService.h"
#import "LDSDKManagerDataVM.h"

@interface LDSDKManager ()

@property(nonatomic, strong) LDSDKManagerDataVM *dataVM;

@end


@implementation LDSDKManager

+ (instancetype)share {
    static dispatch_once_t predicate;
    static LDSDKManager *manager;
    dispatch_once(&predicate, ^{
        manager = [LDSDKManager new];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        [self.dataVM prepare];
    }
    return self;
}

- (void)registerWithPlatformConfigList:(NSArray *)configList; {
    [self.dataVM register:configList];
}


- (id <LDSDKShareService>)registerService:(LDSDKPlatformType)type {
    return self.dataVM.shareServiceDict[@(type)];
}

- (id <LDSDKAuthService>)authService:(LDSDKPlatformType)type {
    return self.dataVM.authServiceDict[@(type)];
}

- (id <LDSDKShareService>)shareService:(LDSDKPlatformType)type {
    return self.dataVM.shareServiceDict[@(type)];
}

- (id <LDSDKPayService>)payService:(LDSDKPlatformType)type {
    return self.dataVM.payServiceDict[@(type)];
}

#pragma mark -getter

- (LDSDKManagerDataVM *)dataVM {
    if (!_dataVM) {
        _dataVM = [LDSDKManagerDataVM new];
    }
    return _dataVM;
}

- (BOOL)handleURL:(NSURL *)url {
    for (id <LDSDKHandleURLProtocol> handle in self.dataVM.registerServiceDict.allValues) {
        if ([handle conformsToProtocol:@protocol(LDSDKHandleURLProtocol)]) {
            BOOL success = [handle handleURL:url];
            if (success) return YES;
        }
    }
    return NO;
}

- (BOOL)handleActivity:(NSUserActivity *)activity {
    for (id <LDSDKHandleURLProtocol> handle in self.dataVM.registerServiceDict.allValues) {
        if ([handle conformsToProtocol:@protocol(LDSDKHandleURLProtocol)] && [handle respondsToSelector:@selector(handleActivity:)]) {
            BOOL success = [handle handleActivity:activity];
            if (success) return YES;
        }
    }
    return NO;
}

@end
