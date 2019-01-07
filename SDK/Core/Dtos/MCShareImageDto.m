//
// Created by majiancheng on 2018/12/4.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "MCShareImageDto.h"


@implementation MCShareImageDto

- (void)setValue:(nullable id)value forUndefinedKey:(NSString *)key {
    [super setValue:value forUndefinedKey:key];
    if ([key isEqualToString:LDSDKShareImageKey]) {
        self.image = value;
    } else if ([key isEqualToString:LDSDKShareImageUrlKey]) {
        self.imageUrl = value;
    }
}

@end