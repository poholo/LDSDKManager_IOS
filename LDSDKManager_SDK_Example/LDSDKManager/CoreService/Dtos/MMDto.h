//
// Created by majiancheng on 2018/12/4.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MMDto : NSObject

@property(nonatomic, strong) NSString *dtoId;

+ (instancetype)createDto:(NSDictionary *)dict;

@end