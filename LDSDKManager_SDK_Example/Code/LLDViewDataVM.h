//
// Created by majiancheng on 2018/11/28.
// Copyright (c) 2018 张海洋. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LDSDKConfig.h"
#import "LDSDKShareService.h"

@class LLDPlatformDto;
@class LLDCategoriryDto;
@class LLDShareInfoDto;


@interface LLDViewDataVM : NSObject

@property(nonatomic, strong) NSMutableArray<LLDPlatformDto *> *dataList;
@property(nonatomic, assign) NSUInteger platformIndx;

- (void)prepareData;

- (NSDictionary *)shareContentWithShareType:(LDSDKShareType)shareType
                                shareMoudle:(LDSDKShareToModule)shareToModule
                                   callBack:(LDSDKShareCallback)callBack;

- (LLDPlatformDto *)curPlatformDto;

- (LLDCategoriryDto *)categroryAtIndex:(NSUInteger)index;

- (LLDShareInfoDto *)shareInfoDtoAtCateIndex:(NSUInteger)cateIndex index:(NSUInteger)infoIndex;
@end
