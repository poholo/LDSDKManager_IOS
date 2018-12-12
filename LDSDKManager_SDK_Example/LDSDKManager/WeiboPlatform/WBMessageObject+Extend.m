//
// Created by majiancheng on 2018/12/6.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "WBMessageObject+Extend.h"

#import "MMBaseShareDto.h"
#import "MMShareImageDto.h"
#import "UIImage+LDExtend.h"
#import "MMShareNewsDto.h"
#import "MMShareVideoDto.h"


@implementation WBMessageObject (Extend)

+ (WBMessageObject *)shareObject:(MMBaseShareDto *)shareDto {
    WBMessageObject *messageObject = nil;
    switch (shareDto.shareType) {
        case LDSDKShareTypeText : {
            messageObject = [self textObject:shareDto];
        }
            break;
        case LDSDKShareTypeImage : {
            MMShareImageDto *imageDto = (MMShareImageDto *) shareDto;
            if (imageDto.image) {
                messageObject = [self imageObject:shareDto];
            } else {
                messageObject = [self imageWebObject:shareDto];
            }
        }
            break;
        case LDSDKShareTypeNews : {
            messageObject = [self newsObject:shareDto];
        }
            break;
        case LDSDKShareTypeAudio : {
            messageObject = [self audioObject:shareDto];
        }
            break;
        case LDSDKShareTypeVideo : {
            messageObject = [self videoObject:shareDto];
        }
            break;
    }

    return messageObject;
}

+ (WBMessageObject *)textObject:(MMBaseShareDto *)shareDto {
    WBMessageObject *messageObject = [WBMessageObject message];
    messageObject.text = shareDto.desc;
    return messageObject;
}

+ (WBMessageObject *)imageObject:(MMBaseShareDto *)shareDto {
    MMShareImageDto *shareImageDto = (MMShareImageDto *) shareDto;
    WBMessageObject *messageObject = [WBMessageObject message];
    messageObject.text = shareDto.desc;

    WBImageObject *imageObject = [WBImageObject object];
    imageObject.isShareToStory = shareImageDto.shareToModule == LDSDKShareToWeiboStory;;
    NSData *imageData10M = [shareImageDto.image ld_compressImageLimitSize:10 * 1000 * 1024];
    imageObject.imageData = imageData10M;
    messageObject.imageObject = imageObject;
    return messageObject;
}

+ (WBMessageObject *)imageWebObject:(MMBaseShareDto *)shareDto {
    //TODO url image
    return nil;
}

+ (WBMessageObject *)newsObject:(MMBaseShareDto *)shareDto {
    MMShareNewsDto *shareNewsDto = (MMShareNewsDto *) shareDto;
    WBMessageObject *messageObject = [WBMessageObject message];
    messageObject.text = shareDto.desc;

    WBWebpageObject *webpageObject = [WBWebpageObject object];
    webpageObject.webpageUrl = shareNewsDto.url;
    webpageObject.objectID = shareNewsDto.dtoId;
    webpageObject.title = shareNewsDto.title;
    webpageObject.description = shareNewsDto.desc;

    NSData *imageData32K = [shareNewsDto.image ld_compressImageLimitSize:32 * 1024];
    webpageObject.thumbnailData = imageData32K;
    webpageObject.scheme = @""; //TODO

    messageObject.mediaObject = webpageObject;
    return messageObject;
}

+ (WBMessageObject *)audioObject:(MMBaseShareDto *)shareDto {
    return [[self class] newsObject:shareDto];
}

+ (WBMessageObject *)videoObject:(MMBaseShareDto *)shareDto {
    MMShareVideoDto *shareVideoDto = (MMShareVideoDto *) shareDto;
    WBMessageObject *messageObject = [WBMessageObject message];
    messageObject.text = shareDto.desc;

    WBNewVideoObject *newVideoObject = [WBNewVideoObject object];
    [newVideoObject addVideo:[NSURL URLWithString:shareVideoDto.mediaUrl]];
    newVideoObject.isShareToStory = shareVideoDto.shareToModule == LDSDKShareToWeiboStory;
    messageObject.videoObject = newVideoObject;
    return messageObject;
}

+ (NSInteger)moduleToPlatform:(LDSDKShareToModule)module {
    return 0;
}


@end