//
// Created by majiancheng on 2018/12/7.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "NSString+Extend.h"


@implementation NSString (Extend)

+ (NSString *)filterInvalid:(NSString *)originString {
    if (originString == nil || ![originString isKindOfClass:[NSString class]]) {
        return @"";
    }
    return originString;
}

@end