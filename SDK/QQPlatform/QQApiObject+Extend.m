//
// Created by majiancheng on 2018/12/4.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "QQApiObject+Extend.h"

#import "MCBaseShareDto.h"
#import "MCShareImageDto.h"
#import "UIImage+LDExtend.h"
#import "MCShareNewsDto.h"
#import "MCShareAudioDto.h"
#import "MCShareVideoDto.h"
#import "MCShareFileDto.h"

@implementation QQApiObject (Extend)

+ (QQApiObject *)shareObject:(MCBaseShareDto *)shareDto {
    QQApiObject *apiObject = nil;
    if (shareDto.shareToModule == LDSDKShareToContact) {
        apiObject = [QQApiObject shareCommenObject:shareDto];

    } else if (shareDto.shareToModule == LDSDKShareToTimeLine) {
        switch (shareDto.shareType) {
            case LDSDKShareTypeText : {
                apiObject = [self textZoneObject:shareDto];
            }
                break;
            case LDSDKShareTypeImage : {
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
            case LDSDKShareTypeFile: {
                apiObject = [self fileObject:shareDto];
            }
                break;
            default: {
            }
                break;
        }
    } else if (shareDto.shareToModule == LDSDKShareToFavorites) {
        apiObject = [QQApiObject shareCommenObject:shareDto];
        apiObject.cflag = kQQAPICtrlFlagQQShareFavorites;

    } else if (shareDto.shareToModule == LDSDKShareToDataLine) {
        apiObject = [QQApiObject shareCommenObject:shareDto];
        apiObject.cflag = kQQAPICtrlFlagQQShareDataline;

    }
    return apiObject;
}

+ (QQApiObject *)shareCommenObject:(MCBaseShareDto *)shareDto {
    QQApiObject *apiObject = nil;
    switch (shareDto.shareType) {
        case LDSDKShareTypeText : {
            apiObject = [self textObject:shareDto];
        }
            break;
        case LDSDKShareTypeImage : {
            MCShareImageDto *imageDto = (MCShareImageDto *) shareDto;
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
        case LDSDKShareTypeFile: {
            apiObject = [self fileObject:shareDto];
        }
            break;
        case LDSDKShareTypeMiniProgram: {
            return nil;
        }
    }
    return apiObject;
}

+ (QQApiTextObject *)textObject:(MCBaseShareDto *)shareDto {
    QQApiTextObject *apiTextObject = [QQApiTextObject objectWithText:shareDto.desc];
    return apiTextObject;
}

+ (QQApiImageArrayForQZoneObject *)textZoneObject:(MCBaseShareDto *)shareDto {
    QQApiImageArrayForQZoneObject *apiImageArrayForQZoneObject = [QQApiImageArrayForQZoneObject objectWithimageDataArray:nil title:shareDto.desc extMap:nil];
    return apiImageArrayForQZoneObject;
}

+ (QQApiImageObject *)imageObject:(MCBaseShareDto *)shareDto {
    MCShareImageDto *shareImageDto = (MCShareImageDto *) shareDto;
    NSData *imageData1M = [shareImageDto.image ld_compressImageLimitSize:1000 * 1024];
    NSData *imageData5M = [shareImageDto.image ld_compressImageLimitSize:5000 * 1024];

    QQApiImageObject *apiImageObject = [QQApiImageObject objectWithData:imageData5M
                                                       previewImageData:imageData1M
                                                                  title:shareDto.title
                                                            description:shareDto.desc];
    return apiImageObject;
}

+ (QQApiWebImageObject *)imageWebObject:(MCBaseShareDto *)shareDto {
    MCShareImageDto *shareImageDto = (MCShareImageDto *) shareDto;
    QQApiWebImageObject *apiWebImageObject = [QQApiWebImageObject objectWithPreviewImageURL:[NSURL URLWithString:shareImageDto.imageUrl]
                                                                                      title:shareImageDto.title
                                                                                description:shareImageDto.desc];
    return apiWebImageObject;
}

+ (QQApiImageArrayForQZoneObject *)imagesObject:(MCBaseShareDto *)shareDto {
    MCShareImageDto *shareImageDto = (MCShareImageDto *) shareDto;

    NSData *imageData5M = [shareImageDto.image ld_compressImageLimitSize:5000 * 1024];
    NSAssert(imageData5M, @"image != NULL");
    QQApiImageArrayForQZoneObject *apiImageArrayForQZoneObject = [QQApiImageArrayForQZoneObject objectWithimageDataArray:@[imageData5M]
                                                                                                                   title:shareDto.title
                                                                                                                  extMap:nil];
    return apiImageArrayForQZoneObject;
}

+ (QQApiNewsObject *)newsObject:(MCBaseShareDto *)shareDto {
    MCShareNewsDto *shareNewsDto = (MCShareNewsDto *) shareDto;
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

+ (QQApiAudioObject *)audioObject:(MCBaseShareDto *)shareDto {
    MCShareAudioDto *shareAudioDto = (MCShareAudioDto *) shareDto;
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

+ (QQApiVideoObject *)videoObject:(MCBaseShareDto *)shareDto {
    MCShareVideoDto *shareVideoDto = (MCShareVideoDto *) shareDto;
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

+ (id)fileObject:(MCBaseShareDto *)shareDto {
    MCShareFileDto *shareFileDto = (MCShareFileDto *) shareDto;
    QQApiFileObject *qqApiFileObject = nil;
    NSData *imageData = [shareFileDto.image ld_compressImageLimitSize:1000 * 1024];

    NSURL *URL = [NSURL URLWithString:shareFileDto.mediaUrl];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    qqApiFileObject = [QQApiFileObject objectWithData:data previewImageData:imageData title:shareFileDto.title description:shareFileDto.desc];
    qqApiFileObject.fileName = URL.lastPathComponent;
    return qqApiFileObject;
}


+ (QQApiVideoForQZoneObject *)videoZoneObject:(MCBaseShareDto *)shareDto {
    MCShareVideoDto *shareVideoDto = (MCShareVideoDto *) shareDto;
    QQApiVideoForQZoneObject *apiVideoForQZoneObject = [QQApiVideoForQZoneObject objectWithAssetURL:shareVideoDto.mediaUrl
                                                                                              title:shareVideoDto.title
                                                                                             extMap:nil];
    return apiVideoForQZoneObject;
}


@end