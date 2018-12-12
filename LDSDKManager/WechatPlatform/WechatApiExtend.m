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
#import "MMShareFileDto.h"
#import "MMShareMiniProgramDto.h"


@implementation WechatApiExtend

+ (BaseReq *)shareObject:(MMBaseShareDto *)shareDto {
    BaseReq *sendMessageToWXReq = nil;
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

+ (SendMessageToWXReq *)textObject:(MMBaseShareDto *)shareDto {
    SendMessageToWXReq *sendMessageToWXReq = [SendMessageToWXReq new];
    sendMessageToWXReq.text = shareDto.desc;
    sendMessageToWXReq.bText = YES;
    sendMessageToWXReq.scene = (int) [WechatApiExtend moduleToPlatform:shareDto.shareToModule];
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
    MMShareNewsDto *shareNewsDto = (MMShareNewsDto *) shareDto;
    WXWebpageObject *wxWebpageObject = [WXWebpageObject object];
    wxWebpageObject.webpageUrl = shareNewsDto.url;
    SendMessageToWXReq *sendMessageToWXReq = [self factoryMessageWXReq:shareDto media:wxWebpageObject];
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

+ (SendMessageToWXReq *)fileObject:(MMBaseShareDto *)shareDto {
    MMShareFileDto *shareFileDto = (MMShareFileDto *) shareDto;
    WXFileObject *wxFileObject = [WXFileObject object];
    NSURL *URL = [NSURL URLWithString:shareFileDto.mediaUrl];
    wxFileObject.fileExtension = URL.pathExtension;
    NSData *data = [NSData dataWithContentsOfURL:URL];
    wxFileObject.fileData = data;
    SendMessageToWXReq *sendMessageToWXReq = [self factoryMessageWXReq:shareDto media:wxFileObject];
    return sendMessageToWXReq;
}

+ (WXLaunchMiniProgramReq *)miniProgram:(MMBaseShareDto *)shareDto {
    MMShareMiniProgramDto *shareMiniProgramDto = (MMShareMiniProgramDto *) shareDto;
    WXLaunchMiniProgramReq *wxLaunchMiniProgramReq = [WXLaunchMiniProgramReq object];
    wxLaunchMiniProgramReq.userName = shareMiniProgramDto.miniProgramId;
    wxLaunchMiniProgramReq.miniProgramType = (WXMiniProgramType) shareMiniProgramDto.miniProgramType;
    wxLaunchMiniProgramReq.path = shareMiniProgramDto.url;
    return wxLaunchMiniProgramReq;
}


+ (SendMessageToWXReq *)factoryMessageWXReq:(MMBaseShareDto *)shareDto media:(id)media {
    MMShareImageDto *shareImageDto = (MMShareImageDto *) shareDto;
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
