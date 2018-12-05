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

- (BOOL)handleOpenURL:(NSURL *)url {
//    for (NSDictionary *oneSDKServiceConfig in sdkServiceConfigList) {
//        Class serviceProvider = NSClassFromString(oneSDKServiceConfig[@"serviceProvider"]);
//        if (serviceProvider) {
//            if ([[serviceProvider sharedService] conformsToProtocol:@protocol(LDSDKRegisterService)]) {
//                if ([[serviceProvider sharedService] handleResultUrl:url]) {
//                    return YES;
//                }
//            }
//        }
//    }

    return NO;
}

- (id)getRegisterService:(LDSDKPlatformType)type {
    Class shareServiceImplCls = [self getServiceProviderWithPlatformType:type];
    if (shareServiceImplCls) {
        if ([[shareServiceImplCls sharedService] conformsToProtocol:@protocol(LDSDKRegisterService)]) {
            return [shareServiceImplCls sharedService];
        }
    }
    return nil;
}

- (id)getAuthService:(LDSDKPlatformType)type {
    Class shareServiceImplCls = [self getServiceProviderWithPlatformType:type];
    if (shareServiceImplCls) {
        if ([[shareServiceImplCls sharedService] conformsToProtocol:@protocol(LDSDKAuthService)]) {
            return [shareServiceImplCls sharedService];
        }
    }
    return nil;
}

- (id)getShareService:(LDSDKPlatformType)type {
    Class shareServiceImplCls = [self getServiceProviderWithPlatformType:type];
    if (shareServiceImplCls) {
        if ([[shareServiceImplCls sharedService] conformsToProtocol:@protocol(LDSDKShareService)]) {
            return [shareServiceImplCls sharedService];
        }
    }
    return nil;
}

- (id)getPayService:(LDSDKPlatformType)type {
    Class shareServiceImplCls = [self getServiceProviderWithPlatformType:type];
    if (shareServiceImplCls) {
        if ([[shareServiceImplCls sharedService] conformsToProtocol:@protocol(LDSDKPayService)]) {
            return [shareServiceImplCls sharedService];
        }
    }
    return nil;
}

/**
 * 根据平台类型和服务类型获取服务提供者
 */
- (Class)getServiceProviderWithPlatformType:(LDSDKPlatformType)platformType {
    if (sdkServiceConfigList == nil) {
        NSString *plistPath =
                [[NSBundle mainBundle] pathForResource:@"SDKServiceConfig" ofType:@"plist"];
        sdkServiceConfigList = [[NSArray alloc] initWithContentsOfFile:plistPath];
    }

    Class serviceProvider = nil;
    for (NSDictionary *oneSDKServiceConfig in sdkServiceConfigList) {
        // find the specified platform
        if ([oneSDKServiceConfig[@"platformType"] intValue] == platformType) {
            serviceProvider = NSClassFromString(oneSDKServiceConfig[@"serviceProvider"]);
            break;
        }  // if
    }

    return serviceProvider;
}


#pragma mark -getter

- (LDSDKManagerDataVM *)dataVM {
    if (!_dataVM) {
        _dataVM = [LDSDKManagerDataVM new];
    }
    return _dataVM;
}
@end
