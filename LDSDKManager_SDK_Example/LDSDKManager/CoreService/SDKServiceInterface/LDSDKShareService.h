//
//  LDSDKShareService.h
//  LDThirdLib
//
//  Created by ss on 15/8/12.
//  Copyright (c) 2015年 ss. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LDSDKConfig.h"

typedef void (^LDSDKShareCallback)(LDSDKErrorCode code, NSError *error);

@protocol LDSDKShareService <NSObject>

- (void)shareContent:(NSDictionary *)exDict;

@end
