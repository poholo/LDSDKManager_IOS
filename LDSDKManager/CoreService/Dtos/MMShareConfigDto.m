//
// Created by majiancheng on 2018/12/4.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "MMShareConfigDto.h"


extern NSString *const LDSDKConfigAppIdKey;
extern NSString *const LDSDKConfigAppSecretKey;
extern NSString *const LDSDKConfigAppSchemeKey;
extern NSString *const LDSDKConfigAppPlatformTypeKey;
extern NSString *const LDSDKConfigAppDescriptionKey;
extern NSString *const LDSDKShareRedirectURIKey;


@implementation MMShareConfigDto


- (void)setValue:(nullable id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:LDSDKConfigAppIdKey]) {
        self.appId = value;
    } else if ([key isEqualToString:LDSDKConfigAppSecretKey]) {
        self.appSecret = value;
    } else if ([key isEqualToString:LDSDKConfigAppSchemeKey]) {
        self.appSchema = value;
    } else if ([key isEqualToString:LDSDKConfigAppPlatformTypeKey]) {
        self.appPlatformType = (LDSDKPlatformType) [value integerValue];
    } else if ([key isEqualToString:LDSDKConfigAppDescriptionKey]) {
        self.appDesc = value;
    } else if ([key isEqualToString:LDSDKShareRedirectURIKey]) {
        self.redirectURI = value;
    }
}

- (NSDictionary *)dict {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    dictionary[LDSDKConfigAppIdKey] = self.appId;
    dictionary[LDSDKConfigAppSecretKey] = self.appSecret;
    dictionary[LDSDKShareRedirectURIKey] = self.redirectURI;
    dictionary[LDSDKConfigAppPlatformTypeKey] = @(self.appPlatformType);
    return dictionary;
}

@end
