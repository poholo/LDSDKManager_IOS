//
// Created by majiancheng on 2018/12/7.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LDSDKHandleURLProtocol <NSObject>

- (BOOL)handleURL:(NSURL *)url;

@optional
- (BOOL)handleActivity:(NSUserActivity *)activity;

@end
