//
// Created by majiancheng on 2018/12/4.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LDSDKConfig.h"

@class MCBaseShareDto;


@protocol LDSDKExtendProtocol <NSObject>

@required
+ (id)shareObject:(MCBaseShareDto *)shareDto;

+ (id)textObject:(MCBaseShareDto *)shareDto;

+ (id)imageObject:(MCBaseShareDto *)shareDto;

+ (id)imageWebObject:(MCBaseShareDto *)shareDto;

+ (id)newsObject:(MCBaseShareDto *)shareDto;

+ (id)audioObject:(MCBaseShareDto *)shareDto;

+ (id)videoObject:(MCBaseShareDto *)shareDto;

+ (id)fileObject:(MCBaseShareDto *)shareDto;

@optional

+ (id)miniProgram:(MCBaseShareDto *)shareDto;

+ (id)takeUpminiProgram:(MCBaseShareDto *)shareDto;

+ (NSInteger)moduleToPlatform:(LDSDKShareToModule)module;

+ (id)textZoneObject:(MCBaseShareDto *)shareDto;

+ (id)imagesObject:(MCBaseShareDto *)shareDto;

+ (id)videoZoneObject:(MCBaseShareDto *)shareDto;


@end
