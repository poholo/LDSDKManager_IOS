//
// Created by majiancheng on 2018/12/17.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "LDSDKTelegramServiceImp.h"

#import "LDSDKTelegramDataVM.h"
#import "MMShareConfigDto.h"

@interface LDSDKTelegramServiceImp ()

@property(nonatomic, copy) LDSDKShareCallback shareCallback;

@property(nonatomic, strong) LDSDKTelegramDataVM *dataVM;

@end

@implementation LDSDKTelegramServiceImp

- (BOOL)isPlatformAppInstalled {
    return NO;
}

- (NSError *)registerWithPlatformConfig:(NSDictionary *)config {
    self.dataVM.configDto = [MMShareConfigDto createDto:config];
    NSError *error = [self.dataVM registerValidate];
    self.dataVM.registerSuccess = YES;
    return error;
}

- (BOOL)isRegistered {
    return self.dataVM.registerSuccess;
}

- (BOOL)handleResultUrl:(NSURL *)url {
    return NO;
}

- (void)shareContent:(NSDictionary *)exDict {
    self.shareCallback = exDict[LDSDKShareCallBackKey];
    BOOL success = [self.dataVM share2Telegram:exDict];
    LDSDKErrorCode code = success ? LDSDKSuccess : LDSDKErrorCodeCommon;
    if (self.shareCallback) {
        NSError *error = [NSError errorWithDomain:kErrorDomain code:code userInfo:@{kErrorMessage: success ? @"" : @"分享失败"}];
        self.shareCallback(code, error);
    }
}

- (BOOL)responseResult:(id)resp {
    return NO;
}

#pragma mark - getter

- (LDSDKTelegramDataVM *)dataVM {
    if (!_dataVM) {
        _dataVM = [LDSDKTelegramDataVM new];
    }
    return _dataVM;
}

@end