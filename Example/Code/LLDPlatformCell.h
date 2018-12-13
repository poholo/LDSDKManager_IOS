//
// Created by majiancheng on 2018/12/6.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LLDPlatformDto;

@interface LLDPlatformCell : UITableViewCell

@property(nonatomic, copy) void (^callBack)(NSUInteger index);

- (void)loadData:(NSArray<LLDPlatformDto *> *)datas;

+ (CGFloat)height;

@end