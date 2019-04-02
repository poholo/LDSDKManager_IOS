//
// Created by majiancheng on 2018/12/17.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "LDSDKTelegramDataVM.h"
#import "NSString+LDExtend.h"


@implementation LDSDKTelegramDataVM

- (NSError *)registerValidate {
    return nil;
}

- (NSError *)supportContinue:(NSString *)module {
    return nil;
}

- (BOOL)isPlatformAppInstalled {
    return NO;
}

- (NSError *)respError:(id)resp {
    return nil;
}

- (LDSDKErrorCode)errorCodePlatform:(NSInteger)errorcode {
    return LDSDKErrorCodePayFail;
}

- (NSString *)errorMsg:(NSInteger)errorcode {
    return nil;
}


- (BOOL)share2Telegram:(NSDictionary *)exDict {
    NSURL *schema = [NSURL URLWithString:@"tg://"];
    NSString *text = exDict[LDSDKShareTitleKey];
    if (text.length == 0) {
        text = exDict[LDSDKShareDescKey];
    }
    if (text.length == 0) {
        text = @"emptyContent";
    }

    NSString *link = exDict[LDSDKShareUrlKey];
    NSString *url = [NSString stringWithFormat:@"tg://msg_url?text=%@&url=%@", [text urlEncode], [link urlEncode]];

    BOOL success = [self action2Telegram:[NSURL URLWithString:url] schema:schema];
    return success;
}

- (BOOL)action2Telegram:(NSURL *)URL schema:(NSURL *)schema {
    __block BOOL isOpen = NO;
    __block BOOL isFinish = NO;
    if ([UIDevice currentDevice].systemName.floatValue > 10) {
        [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:^(BOOL success) {
            isOpen = success;
            isFinish = YES;
            if (!isOpen) {
                [self openGroup];
            }
        }];

    } else {
        isOpen = [[UIApplication sharedApplication] openURL:URL];
        isFinish = YES;
        if (!isOpen) {
            [self openGroup];
        }
    }
    while (!isFinish) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
    return isOpen;
}


- (void)openGroup {
//    kTelegramGroup
    NSURL *URL = [NSURL URLWithString:nil];
    if ([UIDevice currentDevice].systemName.floatValue > 10) {
        [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:NULL];

    } else {
        [[UIApplication sharedApplication] openURL:URL];
    }
}

- (NSDictionary *)authDict {
    return nil;
}

- (void)setAuthDict:(NSDictionary *)authDict {

}

- (NSDictionary *)userInfo {
    return nil;
}

- (void)setUserInfo:(NSDictionary *)userInfo {

}

- (NSArray<NSString *> *)permissions {
    return nil;
}

- (BOOL)canResponseShareResult:(id)resp {
    return NO;
}

- (BOOL)canResponseAuthResult:(id)resp {
    return NO;
}

- (NSDictionary *)wrapAuth:(id)auth {
    return nil;
}

- (NSDictionary *)wrapAuthUserInfo:(id)userinfo {
    return nil;
}


@end