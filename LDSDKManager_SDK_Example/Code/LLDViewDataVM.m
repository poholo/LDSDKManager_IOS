//
// Created by majiancheng on 2018/11/28.
// Copyright (c) 2018 张海洋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLDViewDataVM.h"

#import "LDSDKConfig.h"

@implementation LLDViewDataVM

- (NSDictionary *)shareContentWithShareType:(LDSDKShareType)shareType {
    NSDictionary *dict = nil;
    switch (shareType) {
        case LDSDKShareTypeContent: {
            dict = @{LDSDKShareContentTitleKey: @"测试分享",
                    LDSDKShareContentDescriptionKey: @"测试分享详情",
                    LDSDKShareContentWapUrlKey: @"www.baidu.com",
                    LDSDKShareContentImageKey: [UIImage imageNamed:@"Icon-Netease"],
                    LDSDKShareContentTextKey: @"text",
                    LDSDKShareTypeKey: @(LDSDKShareTypeContent)};
        }
            break;
        case LDSDKShareTypeImage: {
            dict = @{LDSDKShareContentTitleKey: @"测试分享",
                    LDSDKShareContentDescriptionKey: @"测试分享详情",
                    LDSDKShareContentWapUrlKey: @"www.baidu.com",
                    LDSDKShareContentImageKey: [UIImage imageNamed:@"Icon-Netease"],
                    LDSDKShareContentTextKey: @"text",
                    LDSDKShareTypeKey: @(LDSDKShareTypeImage)};
        }
            break;
        case LDSDKShareTypeOther : {
            dict = @{LDSDKShareContentTitleKey: @"测试分享",
                    LDSDKShareContentDescriptionKey: @"测试分享详情",
                    LDSDKShareContentWapUrlKey: @"www.baidu.com",
                    LDSDKShareContentImageKey: [UIImage imageNamed:@"Icon-Netease"],
                    LDSDKShareContentTextKey: @"text",
                    LDSDKShareTypeKey: @(LDSDKShareTypeImage)};
        }
            break;
    }
    return dict;
}

@end
