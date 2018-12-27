//
// Created by majiancheng on 2018/12/5.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <WechatOpenSDK/WXApiObject.h>
#import "MCResultDto.h"


@implementation MCResultDto

+ (MCResultDto *)createResult:(id)object {
    MCResultDto *dto = [MCResultDto new];
    dto.object = object;
    if ([object isKindOfClass:[BaseResp class]]) {
        BaseResp *resp = (BaseResp *) object;
        dto.code = (LDSDKErrorCode) resp.errCode;
        dto.error = [NSError errorWithDomain:kErrorDomain
                                        code:resp.errCode
                                    userInfo:@{kErrorCode: @(resp.errCode),
                                            kErrorMessage: resp.errStr,
                                            kErrorObject: resp}];
    }
    return dto;
}

@end