//
//  NSString+LDSDKAdditions.h
//  Pods
//
//  Created by xuguoxing on 14-9-19.
//
//

#import <Foundation/Foundation.h>


@interface NSString (LDSDKAdditions)


- (BOOL)isEmptyOrWhitespace;

- (NSString *)LDURLEncodedString;

- (NSString *)LDURLDecodedString;

- (NSData *)base16Data;

- (NSString *)md5String;

- (NSDictionary *)urlParamsDecodeDictionary;

@end
