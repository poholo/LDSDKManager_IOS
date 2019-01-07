//
// Created by majiancheng on 2018/12/4.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "MCShareTextDto.h"


@implementation MCShareTextDto

- (void)prepare {
    NSString *qq = [self keyForPlatform:LDSDKPlatformQQ shareToModule:LDSDKShareToContact];
    NSString *qqzone = [self keyForPlatform:LDSDKPlatformQQ shareToModule:LDSDKShareToTimeLine];

//    NSString *wechat = [self keyForPlatform:LDSDKPlatformWeChat shareToModule:LDSDKShareToContact];
//    NSString *wechatZone = [self keyForPlatform:LDSDKPlatformWeChat shareToModule:LDSDKShareToTimeLine];
//
//    NSString *weibo = [self keyForPlatform:LDSDKPlatformWeibo shareToModule:LDSDKShareToContact];
//    NSString *weiboZone = [self keyForPlatform:LDSDKPlatformWeibo shareToModule:LDSDKShareToTimeLine];

    self.supportDict[qq] = @(YES);
    self.supportDict[qqzone] = @(YES);
}

- (BOOL)support {
    NSNumber *support = self.supportDict[self.currentKey];
    return [support boolValue];
}

- (MCBaseShareDto *)canReplaceShareDto {
    return self;
}

@end
