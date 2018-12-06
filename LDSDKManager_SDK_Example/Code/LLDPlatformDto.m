//
// Created by majiancheng on 2018/12/6.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "LLDPlatformDto.h"

@implementation LLDDto

+ (id)createDto:(NSDictionary *)dict {
    LLDDto *dto = [self new];
    [dto setValuesForKeysWithDictionary:dict];
    return dto;
}

@end


@implementation LLDPlatformDto

- (void)setValue:(nullable id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"data"]) {
        for (NSDictionary *dictionary in value) {
            LLDCategoriryDto *dto = [LLDCategoriryDto createDto:dictionary];
            [self.cates addObject:dto];
        }
    }
}

- (NSMutableArray<LLDCategoriryDto *> *)cates {
    if(!_cates) {
        _cates = [NSMutableArray new];
    }
    return _cates;
}

@end


@implementation LLDCategoriryDto

- (void)setValue:(nullable id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"data"]) {
        for(NSDictionary * dictionary in value) {
            LLDShareInfoDto * dto = [LLDShareInfoDto createDto:dictionary];
            [self.shareInfos addObject:dto];
        }
    }
}

- (NSMutableArray<LLDShareInfoDto *> *)shareInfos {
    if (!_shareInfos) {
        _shareInfos = [NSMutableArray new];
    }
    return _shareInfos;
}

@end

@implementation LLDShareInfoDto


@end