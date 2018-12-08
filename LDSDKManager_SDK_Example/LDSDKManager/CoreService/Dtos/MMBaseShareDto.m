//
// Created by majiancheng on 2018/12/4.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "MMBaseShareDto.h"

#import "MMShareTextDto.h"
#import "MMShareImageDto.h"
#import "MMShareNewsDto.h"
#import "MMShareAudioDto.h"
#import "MMShareVideoDto.h"
#import "MMShareConfigDto.h"


@implementation MMBaseShareDto
@synthesize supportDict = _supportDict;

+ (instancetype)factoryCreateShareDto:(NSDictionary *)exDict {
    MMBaseShareDto *dto = nil;
    LDSDKShareType shareType = (LDSDKShareType) [exDict[LDSDKShareTypeKey] integerValue];
    switch (shareType) {
        case LDSDKShareTypeText: {
            dto = [MMShareTextDto createDto:exDict];
        }
            break;
        case LDSDKShareTypeImage: {
            dto = [MMShareImageDto createDto:exDict];
        }
            break;
        case LDSDKShareTypeNews: {
            dto = [MMShareNewsDto createDto:exDict];
        }
            break;
        case LDSDKShareTypeAudio: {
            dto = [MMShareAudioDto createDto:exDict];
        }
            break;
        case LDSDKShareTypeVideo: {
            dto = [MMShareVideoDto createDto:exDict];
        }
            break;
    }
    dto.exDict = exDict;
    return dto;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}

- (void)prepare {

}

- (BOOL)support {
    return NO;
}

- (MMBaseShareDto *)canReplaceShareDto {
    return nil;
}

- (NSString *)keyForPlatform:(LDSDKPlatformType)platformType shareToModule:(LDSDKShareToModule)shareToModule {
    return [NSString stringWithFormat:@"%zd_%zd", platformType, shareToModule];
}

- (NSString *)currentKey {
    NSString *key = [self keyForPlatform:self.platformType shareToModule:self.shareToModule];
    return key;
}

#pragma mark override

- (void)setValue:(nullable id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:LDSDKIdentifierKey]) {
        self.dtoId = value;
    } else if ([key isEqualToString:LDSDKPlatformTypeKey]) {
        self.platformType = (LDSDKPlatformType) [value integerValue];
    } else if ([key isEqualToString:LDSDKShareToMoudleKey]) {
        self.shareToModule = (LDSDKShareToModule) [value integerValue];
    } else if ([key isEqualToString:LDSDKShareTypeKey]) {
        self.shareType = (LDSDKShareType) [value integerValue];
    } else if ([key isEqualToString:LDSDKShareTitleKey]) {
        self.title = value;
    } else if ([key isEqualToString:LDSDKShareDescKey]) {
        self.desc = value;
    } else if ([key isEqualToString:LDSDKShareCallBackKey]) {

    }
}

#pragma mark -getter

- (NSMutableDictionary

<NSString *, NSNumber *> *)supportDict {
    if (!_supportDict) {
        _supportDict = [NSMutableDictionary new];
    }
    return _supportDict;
}

@end
