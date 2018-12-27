//
// Created by majiancheng on 2018/12/4.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "MCShareNewsDto.h"


@implementation MCShareNewsDto

- (void)setValue:(nullable id)value forUndefinedKey:(NSString *)key {
    [super setValue:value forUndefinedKey:key];
    if ([key isEqualToString:LDSDKShareUrlKey]) {
        self.url = value;
    }
}
@end