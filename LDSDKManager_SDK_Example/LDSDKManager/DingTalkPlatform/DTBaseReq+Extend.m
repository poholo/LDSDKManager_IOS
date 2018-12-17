//
// Created by majiancheng on 2018/12/17.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "DTBaseReq+Extend.h"

#import "MMBaseShareDto.h"
#import "MMShareImageDto.h"
#import "UIImage+LDExtend.h"
#import "MMShareNewsDto.h"


@implementation DTBaseReq (Extend)

+ (id)shareObject:(MMBaseShareDto *)shareDto {
    DTSendMessageToDingTalkReq *req = nil;
    switch (shareDto.shareType) {
        case LDSDKShareTypeText : {
            req = [self textObject:shareDto];
        }
            break;
        case LDSDKShareTypeImage : {
            MMShareImageDto *imageDto = (MMShareImageDto *) shareDto;
            if (imageDto.image) {
                req = [self imageObject:shareDto];
            } else {
                req = [self imageWebObject:shareDto];
            }
        }
            break;
        case LDSDKShareTypeNews : {
            req = [self newsObject:shareDto];
        }
            break;
        case LDSDKShareTypeAudio : {
            req = [self audioObject:shareDto];
        }
            break;
        case LDSDKShareTypeVideo : {
            req = [self videoObject:shareDto];
        }
            break;
        case LDSDKShareTypeFile: {
            req = [self fileObject:shareDto];
        }
            break;
        case LDSDKShareTypeMiniProgram: {
            req = [self miniProgram:shareDto];
        }
            break;
    }
    return req;
}

+ (id)textObject:(MMBaseShareDto *)shareDto {
    DTMediaTextObject *textObject = [DTMediaTextObject new];
    textObject.text = shareDto.desc;
    return [DTBaseReq factoryMessageReq:shareDto media:textObject];
}

+ (id)imageObject:(MMBaseShareDto *)shareDto {
    MMShareImageDto *shareImageDto = (MMShareImageDto *) shareDto;
    DTMediaImageObject *imageObject = [DTMediaImageObject new];
    imageObject.imageData = [shareImageDto.image ld_compressImageLimitSize:10 * 1024 * 1024];
    return [DTBaseReq factoryMessageReq:shareImageDto media:imageObject];
}

+ (id)imageWebObject:(MMBaseShareDto *)shareDto {
    MMShareImageDto *shareImageDto = (MMShareImageDto *) shareDto;
    DTMediaImageObject *imageObject = [DTMediaImageObject new];
    imageObject.imageURL = shareImageDto.imageUrl;
    return [DTBaseReq factoryMessageReq:shareImageDto media:imageObject];
}

+ (id)newsObject:(MMBaseShareDto *)shareDto {
    MMShareNewsDto *newsDto = (MMShareNewsDto *) shareDto;

    DTMediaWebObject *mediaWebObject = [DTMediaWebObject new];
    mediaWebObject.pageURL = newsDto.url;

    return [DTBaseReq factoryMessageReq:newsDto media:mediaWebObject];
}

+ (id)audioObject:(MMBaseShareDto *)shareDto {
    return [DTBaseReq newsObject:shareDto];
}

+ (id)videoObject:(MMBaseShareDto *)shareDto {
    return [DTBaseReq newsObject:shareDto];
}

+ (id)fileObject:(MMBaseShareDto *)shareDto {
    return nil;
}

+ (DTSendMessageToDingTalkReq *)factoryMessageReq:(MMBaseShareDto *)shareDto media:(id)media {
    DTSendMessageToDingTalkReq *req = [[DTSendMessageToDingTalkReq alloc] init];
    DTMediaMessage *message = [[DTMediaMessage alloc] init];
    message.mediaObject = media;
    message.title = shareDto.title;
    message.messageDescription = shareDto.desc;
    if ([shareDto isMemberOfClass:[MMShareImageDto class]]) {
        MMShareImageDto *imageDto = (MMShareImageDto *) shareDto;
        message.thumbURL = imageDto.imageUrl;
        message.thumbData = [imageDto.image ld_compressImageLimitSize:32 * 1024];
    }
    req.message = message;
    return req;
}


@end