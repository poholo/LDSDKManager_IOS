//
// Created by majiancheng on 2018/12/6.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDSDKConfig.h"

@class LLDCategoriryDto;
@class LLDShareInfoDto;

@interface LLDDto : NSObject

+ (id)createDto:(NSDictionary *)dict;

@end

@interface LLDPlatformDto : LLDDto

@property(nonatomic, strong) NSString *name;
@property(nonatomic, assign) LDSDKPlatformType type;
@property(nonatomic, strong) NSMutableArray<LLDCategoriryDto *> *cates;
@end

@interface LLDCategoriryDto : LLDDto

@property(nonatomic, strong) NSString *name;
@property(nonatomic, assign) LDSDKShareToModule type;
@property(nonatomic, strong) NSMutableArray<LLDShareInfoDto *> *shareInfos;

@end

@interface LLDShareInfoDto : LLDDto

@property(nonatomic, strong) NSString *name;
@property(nonatomic, assign) LDSDKShareType type;

@end