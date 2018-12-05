//
// Created by majiancheng on 2018/12/3.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LDSDKShareService;
@protocol LDSDKPayService;
@protocol LDSDKAuthService;


@interface LDSDKManagerDataVM : NSObject

@property(nonatomic, strong) NSMutableDictionary<NSNumber *, id <LDSDKShareService>> *shareServiceDict;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, id <LDSDKPayService>> *payServiceDict;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, id <LDSDKAuthService>> *authServiceDict;

- (void)prepare;

- (void)register:(NSArray<NSDictionary *> *)configs;

@end