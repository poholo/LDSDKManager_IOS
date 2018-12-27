//
// Created by majiancheng on 2018/12/5.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import <WechatOpenSDK/WXApiObject.h>
#import "WechatApiExtend.h"

#import "MCBaseShareDto.h"
#import "MCShareImageDto.h"
#import "UIImage+LDExtend.h"
#import "MCShareAudioDto.h"
#import "MCShareVideoDto.h"
#import "MCShareFileDto.h"
#import "MCShareMiniProgramDto.h"


@implementation WechatApiExtend

+ (BaseReq *)shareObject:(MCBaseShareDto *)shareDto {
    BaseReq *sendMessageToWXReq = nil;
    switch (shareDto.shareType) {
        case LDSDKShareTypeText : {
            sendMessageToWXReq = [self textObject:shareDto];
        }
            break;
        case LDSDKShareTypeImage : {
            MCShareImageDto *imageDto = (MCShareImageDto *) shareDto;
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
        case LDSDKShareTypeFile: {
            sendMessageToWXReq = [self fileObject:shareDto];
        }
            break;
        case LDSDKShareTypeMiniProgram: {
            sendMessageToWXReq = [self miniProgram:shareDto];
        }
            break;
    }
    return sendMessageToWXReq;
}

+ (SendMessageToWXReq *)textObject:(MCBaseShareDto *)shareDto {
    SendMessageToWXReq *sendMessageToWXReq = [SendMessageToWXReq new];
    sendMessageToWXReq.text = shareDto.desc;
    sendMessageToWXReq.bText = YES;
    sendMessageToWXReq.scene = (int) [WechatApiExtend moduleToPlatform:shareDto.shareToModule];
    return sendMessageToWXReq;
}

+ (SendMessageToWXReq *)imageObject:(MCBaseShareDto *)shareDto {
    MCShareImageDto *shareImageDto = (MCShareImageDto *) shareDto;
    NSData *imageData10M = [shareImageDto.image ld_compressImageLimitSize:10 * 1000 * 1024];
    WXImageObject *wxImageObject = [WXImageObject object];
    wxImageObject.imageData = imageData10M;
    SendMessageToWXReq *sendMessageToWXReq = [self factoryMessageWXReq:shareDto media:wxImageObject];
    return sendMessageToWXReq;
}

+ (SendMessageToWXReq *)imageWebObject:(MCBaseShareDto *)shareDto {
    MCShareImageDto *shareImageDto = (MCShareImageDto *) shareDto;
    //TODO:: 图片下载机制
    NSData *imageData10M = [shareImageDto.image ld_compressImageLimitSize:10 * 1000 * 1024];
    WXImageObject *wxImageObject = [WXImageObject object];
    wxImageObject.imageData = imageData10M;
    SendMessageToWXReq *sendMessageToWXReq = [self factoryMessageWXReq:shareDto media:wxImageObject];
    return sendMessageToWXReq;
}

+ (SendMessageToWXReq *)newsObject:(MCBaseShareDto *)shareDto {
    MCShareNewsDto *shareNewsDto = (MCShareNewsDto *) shareDto;
    WXWebpageObject *wxWebpageObject = [WXWebpageObject object];
    wxWebpageObject.webpageUrl = shareNewsDto.url;
    SendMessageToWXReq *sendMessageToWXReq = [self factoryMessageWXReq:shareDto media:wxWebpageObject];
    return sendMessageToWXReq;
}

+ (SendMessageToWXReq *)audioObject:(MCBaseShareDto *)shareDto {
    MCShareAudioDto *shareAudioDto = (MCShareAudioDto *) shareDto;
    WXMusicObject *wxMusicObject = [WXMusicObject object];
    wxMusicObject.musicUrl = shareAudioDto.url;
    wxMusicObject.musicDataUrl = shareAudioDto.mediaUrl;
    SendMessageToWXReq *sendMessageToWXReq = [self factoryMessageWXReq:shareDto media:wxMusicObject];
    return sendMessageToWXReq;
}

+ (SendMessageToWXReq *)videoObject:(MCBaseShareDto *)shareDto {
    MCShareVideoDto *shareVideoDto = (MCShareVideoDto *) shareDto;
    WXVideoObject *wxVideoObject = [WXVideoObject object];
    wxVideoObject.videoUrl = shareVideoDto.url;
    wxVideoObject.videoLowBandUrl = shareVideoDto.mediaUrl;
    SendMessageToWXReq *sendMessageToWXReq = [self factoryMessageWXReq:shareDto media:wxVideoObject];
    return sendMessageToWXReq;
}

+ (SendMessageToWXReq *)fileObject:(MCBaseShareDto *)shareDto {
    MCShareFileDto *shareFileDto = (MCShareFileDto *) shareDto;
    WXFileObject *wxFileObject = [WXFileObject object];
    NSURL *URL = [NSURL URLWithString:shareFileDto.mediaUrl];
    wxFileObject.fileExtension = URL.pathExtension;
    NSData *data = [NSData dataWithContentsOfURL:URL];
    wxFileObject.fileData = data;
    SendMessageToWXReq *sendMessageToWXReq = [self factoryMessageWXReq:shareDto media:wxFileObject];
    return sendMessageToWXReq;
}

+ (WXLaunchMiniProgramReq *)miniProgram:(MCBaseShareDto *)shareDto {
    MCShareMiniProgramDto *shareMiniProgramDto = (MCShareMiniProgramDto *) shareDto;
    WXLaunchMiniProgramReq *wxLaunchMiniProgramReq = [WXLaunchMiniProgramReq object];
    wxLaunchMiniProgramReq.userName = shareMiniProgramDto.miniProgramId;
    wxLaunchMiniProgramReq.miniProgramType = (WXMiniProgramType) shareMiniProgramDto.miniProgramType;
    wxLaunchMiniProgramReq.path = shareMiniProgramDto.url;
    return wxLaunchMiniProgramReq;
}


+ (SendMessageToWXReq *)factoryMessageWXReq:(MCBaseShareDto *)shareDto media:(id)media {
    MCShareImageDto *shareImageDto = (MCShareImageDto *) shareDto;
    SendMessageToWXReq *sendMessageToWXReq = [SendMessageToWXReq new];
    sendMessageToWXReq.bText = NO;
    sendMessageToWXReq.scene = (int) [WechatApiExtend moduleToPlatform:shareImageDto.shareToModule];

    WXMediaMessage *wxMediaMessage = [WXMediaMessage message];
    wxMediaMessage.title = shareImageDto.title;
    wxMediaMessage.description = shareImageDto.desc;
    wxMediaMessage.thumbData = [shareImageDto.image ld_compressImageLimitSize:32 * 1024];
    wxMediaMessage.mediaObject = media;

    sendMessageToWXReq.message = wxMediaMessage;

    return sendMessageToWXReq;
}

+ (NSInteger)moduleToPlatform:(LDSDKShareToModule)module {
    switch (module) {
        case LDSDKShareToTimeLine: {
            return WXSceneTimeline;
        }
            break;
        case LDSDKShareToContact: {
            return WXSceneSession;
        }
            break;
        case LDSDKShareToFavorites: {
            return WXSceneFavorite;
        }
            break;
    }
    return WXSceneSession;
}

@end
