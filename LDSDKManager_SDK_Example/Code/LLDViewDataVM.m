//
// Created by majiancheng on 2018/11/28.
// Copyright (c) 2018 张海洋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLDViewDataVM.h"

#import "LDSDKConfig.h"

@implementation LLDViewDataVM

- (NSDictionary *)shareContentWithShareType:(LDShareType)shareType {
    NSDictionary *dict = nil;
    switch (shareType) {
        case LDShareTypeContent: {
            dict = @{LDSDKShareTitleKey: @"测试分享",
                    LDSDKShareDescKey: @"测试分享详情",
                    LDSDKShareUrlKey: @"www.baidu.com",
                    LDSDKShareImageKey: [UIImage imageNamed:@"Icon-Netease"],
                    LDSDKShareTextKey: @"text",
                    LDShareTypeKey: @(LDShareTypeContent)};
        }
            break;
        case LDShareTypeImage: {
            dict = @{LDSDKShareTitleKey: @"测试分享",
                    LDSDKShareDescKey: @"测试分享详情",
                    LDSDKShareUrlKey: @"www.baidu.com",
                    LDSDKShareImageKey: [UIImage imageNamed:@"Icon-Netease"],
                    LDSDKShareTextKey: @"text",
                    LDShareTypeKey: @(LDShareTypeImage)};
        }
            break;
        case LDShareTypeOther : {
            dict = @{LDSDKShareTitleKey: @"测试分享",
                    LDSDKShareDescKey: @"测试分享详情",
                    LDSDKShareUrlKey: @"www.baidu.com",
                    LDSDKShareImageKey: [UIImage imageNamed:@"Icon-Netease"],
                    LDSDKShareTextKey: @"text",
                    LDShareTypeKey: @(LDShareTypeImage)};
        }
            break;
    }
    return dict;
}

@end
