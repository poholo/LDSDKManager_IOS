//
// Created by majiancheng on 2018/12/4.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "QQApiObject+Extend.h"

#import "MMBaseShareDto.h"
#import "MMShareImageDto.h"
#import "UIImage+LDExtend.h"
#import "MMShareNewsDto.h"
#import "MMShareAudioDto.h"
#import "MMShareVideoDto.h"


@implementation QQApiObject (Extend)

+ (QQApiObject *)shareObject:(MMBaseShareDto *)shareDto {
    QQApiObject *apiObject = nil;
    if (shareDto.shareToModule == LDSDKShareToContact) {
        switch (shareDto.shareType) {
            case LDSDKShareTypeText : {
                apiObject = [self textObject:shareDto];
            }
                break;
            case LDSDKShareTypeImage : {
                MMShareImageDto *imageDto = (MMShareImageDto *) shareDto;
                if (imageDto.image) {
                    apiObject = [self imageObject:shareDto];
                } else {
                    apiObject = [self imageWebObject:shareDto];
                }
            }
                break;
            case LDSDKShareTypeNews : {
                apiObject = [self newsObject:shareDto];
            }
                break;
            case LDSDKShareTypeAudio : {
                apiObject = [self audioObject:shareDto];
            }
                break;
            case LDSDKShareTypeVideo : {
                apiObject = [self videoObject:shareDto];
            }
                break;
        }

    } else if (shareDto.shareToModule == LDSDKShareToTimeLine) {
        switch (shareDto.shareType) {
            case LDSDKShareTypeText : {
                apiObject = [self textZoneObject:shareDto];
            }
                break;
            case LDSDKShareTypeImage : {
                MMShareImageDto *imageDto = (MMShareImageDto *) shareDto;
                apiObject = [self imagesObject:shareDto];
            }
                break;
            case LDSDKShareTypeNews : {
                apiObject = [self newsObject:shareDto];
            }
                break;
            case LDSDKShareTypeAudio : {
                apiObject = [self audioObject:shareDto];
            }
                break;
            case LDSDKShareTypeVideo : {
                apiObject = [self videoZoneObject:shareDto];
            }
                break;
        }
    }
    return apiObject;
}

+ (QQApiTextObject *)textObject:(MMBaseShareDto *)shareDto {
    QQApiTextObject *apiTextObject = [QQApiTextObject objectWithText:shareDto.desc];
    return apiTextObject;
}

+ (QQApiImageArrayForQZoneObject *)textZoneObject:(MMBaseShareDto *)shareDto {
    QQApiImageArrayForQZoneObject *apiImageArrayForQZoneObject = [QQApiImageArrayForQZoneObject objectWithimageDataArray:nil title:shareDto.desc extMap:nil];
    return apiImageArrayForQZoneObject;
}

+ (QQApiImageObject *)imageObject:(MMBaseShareDto *)shareDto {
    MMShareImageDto *shareImageDto = (MMShareImageDto *) shareDto;
    NSData *imageData1M = [shareImageDto.image ld_compressImageLimitSize:1000 * 1024];
    NSData *imageData5M = [shareImageDto.image ld_compressImageLimitSize:5000 * 1024];

    QQApiImageObject *apiImageObject = [QQApiImageObject objectWithData:imageData5M
                                                       previewImageData:imageData1M
                                                                  title:shareDto.title
                                                            description:shareDto.desc];
    return apiImageObject;
}

+ (QQApiWebImageObject *)imageWebObject:(MMBaseShareDto *)shareDto {
    MMShareImageDto *shareImageDto = (MMShareImageDto *) shareDto;
    QQApiWebImageObject *apiWebImageObject = [QQApiWebImageObject objectWithPreviewImageURL:[NSURL URLWithString:shareImageDto.imageUrl]
                                                                                      title:shareImageDto.title
                                                                                description:shareImageDto.desc];
    return apiWebImageObject;
}

+ (QQApiImageArrayForQZoneObject *)imagesObject:(MMBaseShareDto *)shareDto {
    MMShareImageDto *shareImageDto = (MMShareImageDto *) shareDto;

    NSData *imageData5M = [shareImageDto.image ld_compressImageLimitSize:5000 * 1024];
    NSAssert(imageData5M, @"image != NULL");
    QQApiImageArrayForQZoneObject *apiImageArrayForQZoneObject = [QQApiImageArrayForQZoneObject objectWithimageDataArray:@[imageData5M]
                                                                                                                   title:shareDto.title
                                                                                                                  extMap:nil];
    return apiImageArrayForQZoneObject;
}

+ (QQApiNewsObject *)newsObject:(MMBaseShareDto *)shareDto {
    MMShareNewsDto *shareNewsDto = (MMShareNewsDto *) shareDto;
    QQApiNewsObject *apiNewsObject = nil;
    if (shareNewsDto.image) {
        NSData *imageData = [shareNewsDto.image ld_compressImageLimitSize:1000 * 1024];
        apiNewsObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:shareNewsDto.url]
                                                 title:shareNewsDto.title
                                           description:shareNewsDto.desc
                                      previewImageData:imageData];

    } else {
        apiNewsObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:shareNewsDto.url]
                                                 title:shareNewsDto.title
                                           description:shareNewsDto.desc
                                       previewImageURL:[NSURL URLWithString:shareNewsDto.imageUrl]];
    }
    return apiNewsObject;
}

+ (QQApiAudioObject *)audioObject:(MMBaseShareDto *)shareDto {
    MMShareAudioDto *shareAudioDto = (MMShareAudioDto *) shareDto;
    QQApiAudioObject *apiAudioObject = nil;
    if (shareAudioDto.image) {
        NSData *imageData = [shareAudioDto.image ld_compressImageLimitSize:1000 * 1024];
        apiAudioObject = [QQApiAudioObject objectWithURL:[NSURL URLWithString:shareAudioDto.url]
                                                   title:shareAudioDto.title
                                             description:shareAudioDto.desc
                                        previewImageData:imageData];

    } else {
        apiAudioObject = [QQApiAudioObject objectWithURL:[NSURL URLWithString:shareAudioDto.url]
                                                   title:shareAudioDto.title
                                             description:shareAudioDto.desc
                                         previewImageURL:[NSURL URLWithString:shareAudioDto.imageUrl]];
    }
    apiAudioObject.flashURL = [NSURL URLWithString:shareAudioDto.mediaUrl];
    return apiAudioObject;
}

+ (QQApiVideoObject *)videoObject:(MMBaseShareDto *)shareDto {
    MMShareVideoDto *shareVideoDto = (MMShareVideoDto *) shareDto;
    QQApiVideoObject *apiVideoObject = nil;
    if (shareVideoDto.image) {
        NSData *imageData = [shareVideoDto.image ld_compressImageLimitSize:1000 * 1024];
        apiVideoObject = [QQApiVideoObject objectWithURL:[NSURL URLWithString:shareVideoDto.url]
                                                   title:shareVideoDto.title
                                             description:shareVideoDto.desc
                                        previewImageData:imageData];

    } else {
        apiVideoObject = [QQApiVideoObject objectWithURL:[NSURL URLWithString:shareVideoDto.url]
                                                   title:shareVideoDto.title
                                             description:shareVideoDto.desc
                                         previewImageURL:[NSURL URLWithString:shareVideoDto.imageUrl]];
    }
    apiVideoObject.flashURL = [NSURL URLWithString:shareVideoDto.mediaUrl];

    return apiVideoObject;
}

+ (QQApiVideoForQZoneObject *)videoZoneObject:(MMBaseShareDto *)shareDto {
    MMShareVideoDto *shareVideoDto = (MMShareVideoDto *) shareDto;
    QQApiVideoForQZoneObject *apiVideoForQZoneObject = [QQApiVideoForQZoneObject objectWithAssetURL:shareVideoDto.mediaUrl
                                                                                              title:shareVideoDto.title
                                                                                             extMap:nil];
    return apiVideoForQZoneObject;
}


@end