//
// Created by majiancheng on 2018/12/5.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <WechatOpenSDK/WXApiObject.h>
#import "WechatApiExtend.h"

#import "MMBaseShareDto.h"
#import "MMShareImageDto.h"
#import "UIImage+LDExtend.h"
#import "MMShareAudioDto.h"
#import "MMShareVideoDto.h"


@implementation WechatApiExtend

+ (SendMessageToWXReq *)shareObject:(MMBaseShareDto *)shareDto {
    SendMessageToWXReq *sendMessageToWXReq = nil;
    switch (shareDto.shareType) {
        case LDSDKShareTypeText : {
            sendMessageToWXReq = [self textObject:shareDto];
        }
            break;
        case LDSDKShareTypeImage : {
            MMShareImageDto *imageDto = (MMShareImageDto *) shareDto;
            if (imageDto.image) {
                sendMessageToWXReq = [self imageObject:shareDto];
            } else {
                sendMessageToWXReq = [self imageWebObject:shareDto];
            }
        }
            break;
        case LDSDKShareTypeNews : {
            sendMessageToWXReq = [self newsObject:shareDto];
        }
            break;
        case LDSDKShareTypeAudio : {
            sendMessageToWXReq = [self audioObject:shareDto];
        }
            break;
        case LDSDKShareTypeVideo : {
            sendMessageToWXReq = [self videoObject:shareDto];
        }
            break;
    }
    return sendMessageToWXReq;
}

+ (SendMessageToWXReq *)textObject:(MMBaseShareDto *)shareDto {
    SendMessageToWXReq *sendMessageToWXReq = [SendMessageToWXReq new];
    sendMessageToWXReq.text = shareDto.desc;
    sendMessageToWXReq.bText = YES;
    sendMessageToWXReq.scene = (int) shareDto.shareType;
    return sendMessageToWXReq;
}

+ (SendMessageToWXReq *)imageObject:(MMBaseShareDto *)shareDto {
    MMShareImageDto *shareImageDto = (MMShareImageDto *) shareDto;
    NSData *imageData10M = [shareImageDto.image ld_compressImageLimitSize:10 * 1000 * 1024];
    WXImageObject *wxImageObject = [WXImageObject object];
    wxImageObject.imageData = imageData10M;
    SendMessageToWXReq *sendMessageToWXReq = [self factoryMessageWXReq:shareDto media:wxImageObject];
    return sendMessageToWXReq;
}

+ (SendMessageToWXReq *)imageWebObject:(MMBaseShareDto *)shareDto {
    MMShareImageDto *shareImageDto = (MMShareImageDto *) shareDto;
    //TODO:: 图片下载机制
    NSData *imageData10M = [shareImageDto.image ld_compressImageLimitSize:10 * 1000 * 1024];
    WXImageObject *wxImageObject = [WXImageObject object];
    wxImageObject.imageData = imageData10M;
    SendMessageToWXReq *sendMessageToWXReq = [self factoryMessageWXReq:shareDto media:wxImageObject];
    return sendMessageToWXReq;
}

+ (SendMessageToWXReq *)newsObject:(MMBaseShareDto *)shareDto {
    WXTextObject *wxTextObject = [WXTextObject object];
    wxTextObject.contentText = shareDto.desc;
    SendMessageToWXReq *sendMessageToWXReq = [self factoryMessageWXReq:shareDto media:wxTextObject];
    return sendMessageToWXReq;
}

+ (SendMessageToWXReq *)audioObject:(MMBaseShareDto *)shareDto {
    MMShareAudioDto *shareAudioDto = (MMShareAudioDto *) shareDto;
    WXMusicObject *wxMusicObject = [WXMusicObject object];
    wxMusicObject.musicUrl = shareAudioDto.url;
    wxMusicObject.musicDataUrl = shareAudioDto.mediaUrl;
    SendMessageToWXReq *sendMessageToWXReq = [self factoryMessageWXReq:shareDto media:wxMusicObject];
    return sendMessageToWXReq;
}

+ (SendMessageToWXReq *)videoObject:(MMBaseShareDto *)shareDto {
    MMShareVideoDto *shareVideoDto = (MMShareVideoDto *) shareDto;
    WXVideoObject *wxVideoObject = [WXVideoObject object];
    wxVideoObject.videoUrl = shareVideoDto.url;
    wxVideoObject.videoLowBandUrl = shareVideoDto.mediaUrl;
    SendMessageToWXReq *sendMessageToWXReq = [self factoryMessageWXReq:shareDto media:wxVideoObject];
    return sendMessageToWXReq;
}

+ (SendMessageToWXReq *)factoryMessageWXReq:(MMBaseShareDto *)shareDto media:(id)media {
    MMShareImageDto *shareImageDto = (MMShareImageDto *) shareDto;
    SendMessageToWXReq *sendMessageToWXReq = [SendMessageToWXReq new];
    sendMessageToWXReq.bText = NO;
    sendMessageToWXReq.scene = (int) shareDto.shareType;

    WXMediaMessage *wxMediaMessage = [WXMediaMessage message];
    wxMediaMessage.title = shareImageDto.title;
    wxMediaMessage.description = shareImageDto.desc;
    wxMediaMessage.thumbData = [shareImageDto.image ld_compressImageLimitSize:32 * 1024];
    wxMediaMessage.mediaObject = media;

    sendMessageToWXReq.message = wxMediaMessage;

    return sendMessageToWXReq;
}


@end