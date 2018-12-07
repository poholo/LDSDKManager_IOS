//
// Created by majiancheng on 2018/11/28.
// Copyright (c) 2018 张海洋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLDViewDataVM.h"

#import "LDSDKConfig.h"
#import "LLDPlatformDto.h"

@implementation LLDViewDataVM

- (void)prepareData {
    NSString *file = [[NSBundle mainBundle] pathForResource:@"LLDPlatform" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:file];
    NSError *error;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSArray *infos = dictionary[@"data"];

    for (NSDictionary *dict in infos) {
        LLDPlatformDto *platformDto = [LLDPlatformDto createDto:dict];
        [self.dataList addObject:platformDto];
    }

}

- (LLDPlatformDto *)curPlatformDto {
    return self.dataList[self.platformIndx];
}

- (LLDCategoriryDto *)categroryAtIndex:(NSUInteger)index {
    LLDPlatformDto *platformDto = [self curPlatformDto];
    return platformDto.cates[index];
}

- (LLDShareInfoDto *)shareInfoDtoAtCateIndex:(NSUInteger)cateIndex index:(NSUInteger)infoIndex {
    LLDCategoriryDto *categoriryDto = [self categroryAtIndex:cateIndex];
    LLDShareInfoDto *infoDto = categoriryDto.shareInfos[infoIndex];
    return infoDto;
}


- (NSDictionary *)shareContentWithShareType:(LDSDKShareType)shareType
                                shareMoudle:(LDSDKShareToModule)shareToModule
                                   callBack:(LDSDKShareCallback)callBack {
    NSDictionary *dict = nil;
    switch (shareType) {
        case LDSDKShareTypeText: {
            dict = @{LDSDKShareTitleKey: @"测试分享",
                    LDSDKShareDescKey: @"测试分享详情",
                    LDSDKShareUrlKey: @"www.baidu.com",
                    LDSDKShareImageKey: [UIImage imageNamed:@"Icon-Netease"],
                    LDSDKShareTextKey: @"text",
                    LDSDKShareCallBackKey: callBack,
                    LDSDKShareToMoudleKey: @(shareToModule),
                    LDSDKShareTypeKey: @(shareType),

                    LDSDKShareTypeKey: @(LDSDKShareTypeText)};
        }
            break;
        case LDSDKShareTypeImage: {
            dict = @{LDSDKShareTitleKey: @"测试分享",
                    LDSDKShareDescKey: @"测试分享详情",
                    LDSDKShareUrlKey: @"www.baidu.com",
                    LDSDKShareImageKey: [UIImage imageNamed:@"Icon-Netease"],
                    LDSDKShareTextKey: @"text",
                    LDSDKShareCallBackKey: callBack,
                    LDSDKShareToMoudleKey: @(shareToModule),
                    LDSDKShareTypeKey: @(shareType),
                    LDSDKShareTypeKey: @(LDSDKShareTypeImage)};
        }
            break;
        case LDSDKShareTypeNews: {
            dict = @{LDSDKShareTitleKey: @"测试分享",
                    LDSDKShareDescKey: @"测试分享详情",
                    LDSDKShareUrlKey: @"www.baidu.com",
                    LDSDKShareImageKey: [UIImage imageNamed:@"Icon-Netease"],
                    LDSDKShareTextKey: @"text",
                    LDSDKShareCallBackKey: callBack,
                    LDSDKShareToMoudleKey: @(shareToModule),
                    LDSDKShareTypeKey: @(shareType),
                    LDSDKShareTypeKey: @(LDSDKShareTypeNews)};
        }
            break;
        case LDSDKShareTypeAudio: {
            dict = @{LDSDKShareTitleKey: @"测试分享",
                    LDSDKShareDescKey: @"测试分享详情",
                    LDSDKShareUrlKey: @"https://music.163.com/#/song?id=26145721&userid=9598943",
                    LDSDKShareImageKey: [UIImage imageNamed:@"Icon-Netease"],
                    LDSDKShareTextKey: @"text",
                    LDSDKShareMeidaUrlKey: @"http://ksy.fffffive.com/mda-himek207gvvqg3wq/mda-himek207gvvqg3wq.mp4",
                    LDSDKShareCallBackKey: callBack,
                    LDSDKShareToMoudleKey: @(shareToModule),
                    LDSDKShareTypeKey: @(shareType),
                    LDSDKShareTypeKey: @(LDSDKShareTypeAudio)};
        }
            break;
        case LDSDKShareTypeVideo: {
            dict = @{LDSDKShareTitleKey: @"测试分享",
                    LDSDKShareDescKey: @"测试分享详情",
                    LDSDKShareUrlKey: @"www.baidu.com",
                    LDSDKShareImageKey: [UIImage imageNamed:@"Icon-Netease"],
                    LDSDKShareTextKey: @"text",
                    LDSDKShareMeidaUrlKey: @"http://ksy.fffffive.com/mda-hfshah045smezhtf/mda-hfshah045smezhtf.mp4",
                    LDSDKShareCallBackKey: callBack,
                    LDSDKShareToMoudleKey: @(shareToModule),
                    LDSDKShareTypeKey: @(shareType),
                    LDSDKShareTypeKey: @(LDSDKShareTypeVideo)};
        }
            break;
    }
    return dict;
}

- (NSMutableArray<LLDPlatformDto *> *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray new];
    }
    return _dataList;
}

@end
