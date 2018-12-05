//
// Created by majiancheng on 2018/12/4.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMBaseShareDto;


@protocol LDSDKExtendProtocol <NSObject>

@required
+ (id)shareObject:(MMBaseShareDto *)shareDto;

+ (id)textObject:(MMBaseShareDto *)shareDto;

+ (id)imageObject:(MMBaseShareDto *)shareDto;

+ (id)imageWebObject:(MMBaseShareDto *)shareDto;

+ (id)newsObject:(MMBaseShareDto *)shareDto;

+ (id)audioObject:(MMBaseShareDto *)shareDto;

+ (id)videoObject:(MMBaseShareDto *)shareDto;

@optional
+ (id)imagesObject:(MMBaseShareDto *)shareDto;

+ (id)videoZoneObject:(MMBaseShareDto *)shareDto;


@end