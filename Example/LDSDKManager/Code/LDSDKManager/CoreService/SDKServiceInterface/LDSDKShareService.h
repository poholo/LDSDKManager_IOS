//
//  LDSDKShareService.h
//  LDThirdLib
//
//  Created by ss on 15/8/12.
//  Copyright (c) 2015年 ss. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LDSDKShareCallback)(BOOL success, NSError *error);


typedef NS_ENUM(NSUInteger, LDSDKShareToModule) {
    LDSDKShareToContact = 1,  //分享至第三方应用的联系人或组
    LDSDKShareToTimeLine,     //分享至第三方应用的timeLine
    LDSDKShareToOther         //分享至第三方应用的其他模块
};

typedef NS_ENUM(NSInteger, LDSDKShareType) {
    LDSDKShareTypeContent,
    LDSDKShareTypeImage,
    LDSDKShareTypeOther,
};

@protocol LDSDKShareService <NSObject>

/*!
 *  @brief  分享到指定平台
 *
 *  @param content  分享内容
 *  @param shareModule 分享子平台，目前主要包括好友和朋友圈（空间）两部分
 *  @param complete  分享之后的回调
 */
- (void)shareWithContent:(NSDictionary *)content shareModule:(LDSDKShareToModule)shareModule onComplete:(LDSDKShareCallback)complete;

@end
