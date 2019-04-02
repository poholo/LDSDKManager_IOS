//
// Created by majiancheng on 2018/12/7.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "NSString+LDExtend.h"


@implementation NSString (LDExtend)

+ (NSString *)filterInvalid:(NSString *)originString {
    if (originString == nil || ![originString isKindOfClass:[NSString class]]) {
        return @"";
    }
    return originString;
}

- (NSString *)escapedURLString {
    NSString *ret = self;
    char *src = (char *) [self UTF8String];

    if (NULL != src) {
        NSMutableString *tmp = [NSMutableString string];
        NSInteger ind = 0;

        while (ind < strlen(src))   // NOTE: if src is NULL, strlen() will crash.
        {
            if (isalpha(src[ind]) || isnumber(src[ind])) {
                [tmp appendFormat:@"%c", src[ind++]];
            } else {
                [tmp appendFormat:@"%%%X", (unsigned char) src[ind++]];
            }
        }

        ret = tmp;
    }

    return ret;
}

- (NSString *)urlDecode {
    if ([self respondsToSelector:@selector(stringByRemovingPercentEncoding)]) {
        return [self stringByRemovingPercentEncoding];
    }

    return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)urlEncode {
    NSString *encUrl;
    if ([self respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        encUrl = [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    } else {
        encUrl = [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }

    NSInteger len = [encUrl length];
    const char *c;
    c = [encUrl UTF8String];
    NSString *ret = @"";
    for (NSInteger i = 0; i < len; i++) {
        switch (*c) {
            case '/':
                ret = [ret stringByAppendingString:@"%2F"];
                break;
            case '\'':
                ret = [ret stringByAppendingString:@"%27"];
                break;
            case ';':
                ret = [ret stringByAppendingString:@"%3B"];
                break;
            case '?':
                ret = [ret stringByAppendingString:@"%3F"];
                break;
            case ':':
                ret = [ret stringByAppendingString:@"%3A"];
                break;
            case '@':
                ret = [ret stringByAppendingString:@"%40"];
                break;
            case '&':
                ret = [ret stringByAppendingString:@"%26"];
                break;
            case '=':
                ret = [ret stringByAppendingString:@"%3D"];
                break;
            case '+':
                ret = [ret stringByAppendingString:@"%2B"];
                break;
            case '$':
                ret = [ret stringByAppendingString:@"%24"];
                break;
            case ',':
                ret = [ret stringByAppendingString:@"%2C"];
                break;
            case '[':
                ret = [ret stringByAppendingString:@"%5B"];
                break;
            case ']':
                ret = [ret stringByAppendingString:@"%5D"];
                break;
            case '#':
                ret = [ret stringByAppendingString:@"%23"];
                break;
            case '!':
                ret = [ret stringByAppendingString:@"%21"];
                break;
            case '(':
                ret = [ret stringByAppendingString:@"%28"];
                break;
            case ')':
                ret = [ret stringByAppendingString:@"%29"];
                break;
            case '*':
                ret = [ret stringByAppendingString:@"%2A"];
                break;
            default:
                ret = [ret stringByAppendingFormat:@"%c", *c];
        }
        c++;
    }

    return ret;
}

- (NSString *)addUrlFromDictionary:(NSDictionary *)params hasQuestionMark:(NSString *)hasQuestionMark {
    NSMutableString *_add = nil;
    if (hasQuestionMark) {
        _add = [NSMutableString stringWithString:@"&"];
    } else {
        _add = [NSMutableString stringWithString:@"?"];
    }
    for (NSString *key in [params allKeys]) {
        if (params[key] && 0 < [params[key] length]) {
            [_add appendFormat:@"%@=%@&", key, [params[key] urlEncode]];
        }
    }

    return [NSString stringWithFormat:@"%@%@", self, [_add substringToIndex:[_add length] - 1]];
}

- (NSDictionary *)params {
    NSString *query = self;
    NSMutableDictionary *pairs = [NSMutableDictionary dictionary];
    if (query) {
        NSCharacterSet *delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&"];
        NSScanner *scanner = [[NSScanner alloc] initWithString:query];
        while (![scanner isAtEnd]) {
            NSString *pairString = nil;
            [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
            [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
            NSArray *kvPair = [pairString componentsSeparatedByString:@"="];
            if (kvPair.count == 2) {
                NSString *key = [kvPair[0] urlDecode];
                NSString *value = [kvPair[1] urlDecode];
                pairs[key] = value;
            }
        }
    }

    return pairs;
}

- (NSMutableDictionary *)queryParams:(NSMutableDictionary *)queryParams {
    NSString *query = self;
    if (query) {
        NSCharacterSet *delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&"];
        NSScanner *scanner = [[NSScanner alloc] initWithString:query];
        while (![scanner isAtEnd]) {
            NSString *pairString = nil;
            [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
            [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
            NSArray *kvPair = [pairString componentsSeparatedByString:@"="];
            if (kvPair.count == 2) {
                NSString *key = [kvPair[0] urlDecode];
                if (![[queryParams allKeys] containsObject:key]) {
                    NSString *value = [kvPair[1] urlDecode];
                    queryParams[key] = value;
                }
            }
        }
    }

    return queryParams;
}

- (NSMutableString *)urlParamString:(NSMutableDictionary *)quaryDict {

    NSMutableDictionary *params = [self queryParams:quaryDict];
    NSMutableString *paramString = [NSMutableString string];
    BOOL hasQuestionMark = NO;
    for (NSString *key in [quaryDict allKeys]) {
        if (hasQuestionMark) {
            [paramString appendFormat:@"&%@=%@", key, params[key]];
        } else {
            [paramString appendFormat:@"?%@=%@", key, params[key]];
            hasQuestionMark = YES;
        }
    }

    return paramString;
}

- (NSString *)urlForAddQuryItems:(NSDictionary <NSString *, NSString *> *)queryItems {
    NSURLComponents *components = [NSURLComponents componentsWithString:self];
    NSMutableArray<NSURLQueryItem *> *queryArr = [NSMutableArray new];
    [queryArr addObjectsFromArray:components.queryItems];

    for (NSString *key in queryItems) {
        NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:key value:queryItems[key]];
        [queryArr addObject:item];
    }
    components.queryItems = queryArr;
    return components.URL.absoluteString;
}
@end