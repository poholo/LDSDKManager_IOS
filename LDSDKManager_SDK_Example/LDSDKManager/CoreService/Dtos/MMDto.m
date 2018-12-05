//
// Created by majiancheng on 2018/12/4.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "MMDto.h"


@implementation MMDto

+ (instancetype)createDto:(NSDictionary *)dict {
    MMDto *dto = [self new];
    [dto setValuesForKeysWithDictionary:dict];
    return dto;
}

@end