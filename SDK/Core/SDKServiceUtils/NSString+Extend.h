//
// Created by majiancheng on 2018/12/7.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extend)

+ (NSString *)filterInvalid:(NSString *)originString;

- (NSString *)escapedURLString;

- (NSString *)urlEncode;

- (NSString *)urlDecode;

- (NSString *)addUrlFromDictionary:(NSDictionary *)params hasQuestionMark:(NSString *)hasQuestionMark;

- (NSDictionary *)params;

- (NSMutableString *)urlParamString:(NSMutableDictionary *)quaryDict;

- (NSString *)urlForAddQuryItems:(NSDictionary <NSString *, NSString *> *)queryItems;

@end