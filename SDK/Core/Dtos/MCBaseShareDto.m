//
// Created by majiancheng on 2018/12/4.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "MCBaseShareDto.h"

#import "MCShareTextDto.h"
#import "MCShareImageDto.h"
#import "MCShareNewsDto.h"
#import "MCShareAudioDto.h"
#import "MCShareVideoDto.h"
#import "MCShareConfigDto.h"
#import "MCShareFileDto.h"
#import "MCShareMiniProgramDto.h"


@implementation MCBaseShareDto
@synthesize supportDict = _supportDict;

+ (instancetype)factoryCreateShareDto:(NSDictionary *)exDict {
    MCBaseShareDto *dto = nil;
    LDSDKShareType shareType = (LDSDKShareType) [exDict[LDSDKShareTypeKey] integerValue];
    switch (shareType) {
        case LDSDKShareTypeText: {
            dto = [MCShareTextDto createDto:exDict];
        }
            break;
        case LDSDKShareTypeImage: {
            dto = [MCShareImageDto createDto:exDict];
        }
            break;
        case LDSDKShareTypeNews: {
            dto = [MCShareNewsDto createDto:exDict];
        }
            break;
        case LDSDKShareTypeAudio: {
            dto = [MCShareAudioDto createDto:exDict];
        }
            break;
        case LDSDKShareTypeVideo: {
            dto = [MCShareVideoDto createDto:exDict];
        }
            break;
        case LDSDKShareTypeFile: {
            dto = [MCShareFileDto createDto:exDict];
        }
            break;
        case LDSDKShareTypeMiniProgram: {
            dto = [MCShareMiniProgramDto createDto:exDict];
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

- (MCBaseShareDto *)canReplaceShareDto {
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
