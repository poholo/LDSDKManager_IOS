//
// Created by majiancheng on 2018/12/11.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LDNetworkManager : NSObject

- (void)dataTaskWithRequest:(NSURLRequest *)request callBack:(nonnull void (^)(BOOL success, id data))callback;

@end