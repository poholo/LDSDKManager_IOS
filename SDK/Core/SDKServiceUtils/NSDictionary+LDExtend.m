//
// Created by majiancheng on 2018/12/11.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "NSDictionary+LDExtend.h"


@implementation NSDictionary (LDExtend)

- (NSString *)query {
    NSMutableArray *array = [NSMutableArray new];
    for (NSString *key in self.allKeys) {
        NSString *pair = [NSString stringWithFormat:@"%@=%@", key, self[key]];
        [array addObject:pair];
    }
    return [array componentsJoinedByString:@"&"];
}

@end