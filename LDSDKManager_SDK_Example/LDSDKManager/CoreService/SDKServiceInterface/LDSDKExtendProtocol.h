//
// Created by majiancheng on 2018/12/4.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMBaseShareDto;


@protocol LDSDKExtendProtocol <NSObject>

+ (id)shareObject:(MMBaseShareDto *)shareDto;

+ (id)textObject:(MMBaseShareDto *)shareDto;

+ (id)imageObject:(MMBaseShareDto *)shareDto;

+ (id)imageWebObject:(MMBaseShareDto *)shareDto;

+ (id)imagesObject:(MMBaseShareDto *)shareDto;

+ (id)newsObject:(MMBaseShareDto *)shareDto;

+ (id)audioObject:(MMBaseShareDto *)shareDto;

+ (id)videoObject:(MMBaseShareDto *)shareDto;

+ (id)videoZoneObject:(MMBaseShareDto *)shareDto;

@end