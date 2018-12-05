//
//  LDSDKShareService.h
//  LDThirdLib
//
//  Created by ss on 15/8/12.
//  Copyright (c) 2015年 ss. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

typedef void (^LDSDKShareCallback)(BOOL success, NSError *error);


@protocol LDSDKShareService <NSObject>

- (void)shareContent:(NSDictionary *)exDict;

@end
