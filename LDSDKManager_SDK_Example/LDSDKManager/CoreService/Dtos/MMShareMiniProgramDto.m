//
// Created by majiancheng on 2018/12/12.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "MMShareMiniProgramDto.h"


@implementation MMShareMiniProgramDto

- (void)setValue:(nullable id)value forUndefinedKey:(NSString *)key {
    [super setValue:value forUndefinedKey:key];
    if ([key isEqualToString:LDSDKShareMiniProgramIdKey]) {
        self.miniProgramId = value;
    } else if ([key isEqualToString:LDSDKShareNiniProgramTypeKey]) {
        self.miniProgramType = (LDSDKMiniProgramType) [value integerValue];
    }
}
@end