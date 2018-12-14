//
// Created by majiancheng on 2018/12/14.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "APBaseReq+Extend.h"
#import "MMBaseShareDto.h"
#import "MMShareImageDto.h"
#import "UIImage+LDExtend.h"
#import "MMShareNewsDto.h"


@implementation APBaseReq (Extend)

+ (APBaseReq *)shareObject:(MMBaseShareDto *)shareDto {
    APSendMessageToAPReq *apSendMessageToAPReq = nil;
    switch (shareDto.shareType) {
        case LDSDKShareTypeText : {
            apSendMessageToAPReq = [self textObject:shareDto];
        }
            break;
        case LDSDKShareTypeImage : {
            apSendMessageToAPReq = [self imagesObject:shareDto];
        }
            break;
        case LDSDKShareTypeNews : {
            apSendMessageToAPReq = [self newsObject:shareDto];
        }
            break;
        case LDSDKShareTypeAudio : {
            apSendMessageToAPReq = [self audioObject:shareDto];
        }
            break;
        case LDSDKShareTypeVideo : {
            apSendMessageToAPReq = [self videoObject:shareDto];
        }
            break;
        case LDSDKShareTypeFile: {
            apSendMessageToAPReq = [self fileObject:shareDto];
        }
            break;
        default: {
        }
            break;
    }
    return apSendMessageToAPReq;
}

+ (id)textObject:(MMBaseShareDto *)shareDto {
    APShareTextObject *apShareTextObject = [APShareTextObject new];
    apShareTextObject.text = shareDto.desc;
    return [APBaseReq factoryMessageReq:shareDto media:apShareTextObject];

    return nil;
}

+ (id)imageObject:(MMBaseShareDto *)shareDto {
    MMShareImageDto *shareImageDto = (MMShareImageDto *) shareDto;
    APShareImageObject *apShareImageObject = [APShareImageObject new];
    apShareImageObject.imageData = [shareImageDto.image ld_compressImageLimitSize:32 * 1024];
    apShareImageObject.imageUrl = shareImageDto.imageUrl;
    APBaseReq *apSendMessageToAPReq = [APBaseReq factoryMessageReq:shareImageDto media:apShareImageObject];
    return apSendMessageToAPReq;
}

+ (id)imageWebObject:(MMBaseShareDto *)shareDto {
    return nil;
}

+ (id)newsObject:(MMBaseShareDto *)shareDto {
    MMShareNewsDto *shareNewsDto = (MMShareNewsDto *) shareDto;
    APShareWebObject *apShareWebObject = [APShareWebObject new];
    apShareWebObject.wepageUrl = shareNewsDto.url;
    APBaseReq *apSendMessageToAPReq = [APBaseReq factoryMessageReq:shareNewsDto media:apShareWebObject];
    return apSendMessageToAPReq;
}

+ (id)audioObject:(MMBaseShareDto *)shareDto {
    return nil;
}

+ (id)videoObject:(MMBaseShareDto *)shareDto {
    return nil;
}

+ (id)fileObject:(MMBaseShareDto *)shareDto {
    return nil;
}


+ (NSInteger)moduleToPlatform:(LDSDKShareToModule)module {
    switch (module) {
        case LDSDKShareToTimeLine: {
            return APSceneTimeLine;
        }
            break;
        case LDSDKShareToContact: {
            return APSceneSession;
        }
            break;
    }
    return APSceneSession;
}


+ (APBaseReq *)factoryMessageReq:(MMBaseShareDto *)shareDto media:(id)media {
    APSendMessageToAPReq *apSendMessageToAPReq = [APSendMessageToAPReq new];
    apSendMessageToAPReq.scene = (APScene) [APBaseReq moduleToPlatform:shareDto.shareToModule];
    APMediaMessage *apMediaMessage = [APMediaMessage new];
    apMediaMessage.title = shareDto.title;
    apMediaMessage.desc = shareDto.desc;
    if ([shareDto isKindOfClass:[MMShareImageDto class]]) {
        MMShareImageDto *shareImageDto = (MMShareImageDto *) shareDto;
        apMediaMessage.thumbData = [shareImageDto.image ld_compressImageLimitSize:32 * 1024];
        apMediaMessage.thumbUrl = shareImageDto.imageUrl;
    }
    apMediaMessage.mediaObject = media;
    return apSendMessageToAPReq;
}

@end