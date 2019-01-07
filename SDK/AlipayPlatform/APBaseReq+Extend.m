//
// Created by majiancheng on 2018/12/14.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "APBaseReq+Extend.h"
#import "MCBaseShareDto.h"
#import "MCShareImageDto.h"
#import "UIImage+LDExtend.h"
#import "MCShareNewsDto.h"


@implementation APBaseReq (Extend)

+ (APBaseReq *)shareObject:(MCBaseShareDto *)shareDto {
    APSendMessageToAPReq *apSendMessageToAPReq = nil;
    switch (shareDto.shareType) {
        case LDSDKShareTypeText : {
            apSendMessageToAPReq = [self textObject:shareDto];
        }
            break;
        case LDSDKShareTypeImage : {
            apSendMessageToAPReq = [self imageObject:shareDto];
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

+ (id)textObject:(MCBaseShareDto *)shareDto {
    APShareTextObject *apShareTextObject = [APShareTextObject new];
    apShareTextObject.text = shareDto.desc;
    return [APBaseReq factoryMessageReq:shareDto media:apShareTextObject];

}

+ (id)imageObject:(MCBaseShareDto *)shareDto {
    MCShareImageDto *shareImageDto = (MCShareImageDto *) shareDto;
    APShareImageObject *apShareImageObject = [APShareImageObject new];
    apShareImageObject.imageData = [shareImageDto.image ld_compressImageLimitSize:32 * 1024];
    apShareImageObject.imageUrl = shareImageDto.imageUrl;
    APBaseReq *apSendMessageToAPReq = [APBaseReq factoryMessageReq:shareImageDto media:apShareImageObject];
    return apSendMessageToAPReq;
}

+ (id)imageWebObject:(MCBaseShareDto *)shareDto {
    return nil;
}

+ (id)newsObject:(MCBaseShareDto *)shareDto {
    MCShareNewsDto *shareNewsDto = (MCShareNewsDto *) shareDto;
    APShareWebObject *apShareWebObject = [APShareWebObject new];
    apShareWebObject.wepageUrl = shareNewsDto.url;
    APBaseReq *apSendMessageToAPReq = [APBaseReq factoryMessageReq:shareNewsDto media:apShareWebObject];
    return apSendMessageToAPReq;
}

+ (id)audioObject:(MCBaseShareDto *)shareDto {
    return nil;
}

+ (id)videoObject:(MCBaseShareDto *)shareDto {
    return nil;
}

+ (id)fileObject:(MCBaseShareDto *)shareDto {
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


+ (APBaseReq *)factoryMessageReq:(MCBaseShareDto *)shareDto media:(id)media {
    APSendMessageToAPReq *apSendMessageToAPReq = [APSendMessageToAPReq new];
    apSendMessageToAPReq.scene = (APScene) [APBaseReq moduleToPlatform:shareDto.shareToModule];
    APMediaMessage *apMediaMessage = [APMediaMessage new];
    apMediaMessage.title = shareDto.title;
    apMediaMessage.desc = shareDto.desc;
    if ([shareDto isKindOfClass:[MCShareImageDto class]]) {
        MCShareImageDto *shareImageDto = (MCShareImageDto *) shareDto;
        apMediaMessage.thumbData = [shareImageDto.image ld_compressImageLimitSize:32 * 1024];
        apMediaMessage.thumbUrl = shareImageDto.imageUrl;
    }
    apMediaMessage.mediaObject = media;
    apSendMessageToAPReq.message = apMediaMessage;
    return apSendMessageToAPReq;
}

@end
