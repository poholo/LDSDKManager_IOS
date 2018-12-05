//
// Created by majiancheng on 2018/12/4.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "MMDto.h"
#import "LDSDKConfig.h"


@interface MMBaseShareDto : MMDto {
    NSMutableDictionary<NSString *, NSNumber *> *_supportDict;
}

@property(nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *supportDict;

@property(nonatomic, strong) NSString *title; ///< 标题，最长128个字符
@property(nonatomic, strong) NSString *desc; ///<简要描述，最长512个字符

@property(nonatomic, assign) LDSDKShareType shareType;
@property(nonatomic, assign) LDSDKPlatformType platformType;
@property(nonatomic, assign) LDSDKShareToModule shareToModule;
@property(nonatomic, strong) NSDictionary *exDict;

+ (instancetype)factoryCreateShareDto:(NSDictionary *)exDict;

- (void)prepare;

- (BOOL)support;

- (MMBaseShareDto *)canReplaceShareDto;

- (NSString *)keyForPlatform:(LDSDKPlatformType)platformType shareToModule:(LDSDKShareToModule)shareToModule;

- (NSString *)currentKey;

@end