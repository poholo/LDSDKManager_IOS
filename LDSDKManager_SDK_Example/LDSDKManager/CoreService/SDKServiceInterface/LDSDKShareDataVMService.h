//
// Created by majiancheng on 2018/12/3.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LDSDKConfig.h"

@class MMBaseShareDto;
@class MMShareConfigDto;

@protocol LDSDKShareDataVMService <NSObject>

@property(nonatomic, strong) MMShareConfigDto *configDto;
@property(nonatomic, strong) NSDictionary *authDict;
@property(nonatomic, strong) NSDictionary *userInfo;

- (NSError *)registerValidate;

- (NSError *)supportContinue:(NSString *)module;

- (BOOL)isPlatformAppInstalled;

- (NSError *)respError:(id)resp;

- (LDSDKErrorCode)errorCodePlatform:(NSInteger)errorcode;

- (NSString *)errorMsg:(NSInteger)errorcode;

- (NSArray<NSString *> *)permissions;

- (BOOL)canResponseShareResult:(id)resp;

- (BOOL)canResponseAuthResult:(id)resp;

- (NSDictionary *)wrapAuth:(id)auth;

- (NSDictionary *)wrapAuthUserInfo:(id)userinfo;

@optional
- (NSError *)respErrorCode:(NSInteger)code;


@end