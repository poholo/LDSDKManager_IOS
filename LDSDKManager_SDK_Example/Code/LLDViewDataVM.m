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
            dict = @{
                    LDSDKIdentifierKey: @"identifier",
                    LDSDKShareTitleKey: [self title],
                    LDSDKShareDescKey: @"集成的第三方SDK（目前包括QQ,微信,易信,支付宝）进行集中管理，按照功能（目前包括第三方登录,分享,支付）开放给各个产品使用。通过接口的方式进行产品集成，方便对第三方SDK进行升级维护。",
                    LDSDKShareUrlKey: [self link],
                    LDSDKShareImageKey: [UIImage imageNamed:@"Icon-Netease"],
                    LDSDKShareTextKey: @"text",
                    LDSDKShareCallBackKey: callBack,
                    LDSDKShareToMoudleKey: @(shareToModule),
                    LDSDKShareTypeKey: @(shareType),

                    LDSDKShareTypeKey: @(LDSDKShareTypeText)};
        }
            break;
        case LDSDKShareTypeImage: {
            dict = @{
                    LDSDKIdentifierKey: @"identifier",
                    LDSDKShareTitleKey: [self title],
                    LDSDKShareDescKey: @"集成的第三方SDK（目前包括QQ,微信,易信,支付宝）进行集中管理，按照功能（目前包括第三方登录,分享,支付）开放给各个产品使用。通过接口的方式进行产品集成，方便对第三方SDK进行升级维护。",
                    LDSDKShareUrlKey: [self link],
                    LDSDKShareImageKey: [UIImage imageNamed:@"Icon-Netease"],
                    LDSDKShareTextKey: @"text",
                    LDSDKShareCallBackKey: callBack,
                    LDSDKShareToMoudleKey: @(shareToModule),
                    LDSDKShareTypeKey: @(shareType),
                    LDSDKShareTypeKey: @(LDSDKShareTypeImage)};
        }
            break;
        case LDSDKShareTypeNews: {
            dict = @{
                    LDSDKIdentifierKey: @"identifier",
                    LDSDKShareTitleKey: [self title],
                    LDSDKShareDescKey: @"集成的第三方SDK（目前包括QQ,微信,易信,支付宝）进行集中管理，按照功能（目前包括第三方登录,分享,支付）开放给各个产品使用。通过接口的方式进行产品集成，方便对第三方SDK进行升级维护。",
                    LDSDKShareUrlKey: [self link],
                    LDSDKShareImageKey: [UIImage imageNamed:@"Icon-Netease"],
                    LDSDKShareTextKey: @"text",
                    LDSDKShareCallBackKey: callBack,
                    LDSDKShareToMoudleKey: @(shareToModule),
                    LDSDKShareTypeKey: @(shareType),
                    LDSDKShareTypeKey: @(LDSDKShareTypeNews)};
        }
            break;
        case LDSDKShareTypeAudio: {
            dict = @{
                    LDSDKIdentifierKey: @"identifier",
                    LDSDKShareTitleKey: [self title],
                    LDSDKShareDescKey: @"集成的第三方SDK（目前包括QQ,微信,易信,支付宝）进行集中管理，按照功能（目前包括第三方登录,分享,支付）开放给各个产品使用。通过接口的方式进行产品集成，方便对第三方SDK进行升级维护。",
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
            dict = @{
                    LDSDKIdentifierKey: @"identifier",
                    LDSDKShareTitleKey: [self title],
                    LDSDKShareDescKey: [self desc],
                    LDSDKShareUrlKey: [self link],
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

- (NSString *)title {
    return @"标题LDSDKManager_SDK";
}

- (NSString *)desc {
    return @"集成的第三方SDK（目前包括QQ,微信,易信,支付宝）进行集中管理，按照功能（目前包括第三方登录,分享,支付）开放给各个产品使用。通过接口的方式进行产品集成，方便对第三方SDK进行升级维护。";
}


- (NSString *)link {
    return @"https://github.com/poholo/LDSDKManager_IOS";
}

- (NSMutableArray<LLDPlatformDto *> *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray new];
    }
    return _dataList;
}

@end
