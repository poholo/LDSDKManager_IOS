//
//  UIImage+LDSDKShare.h
//  Pods
//
//  Created by xuguoxing on 14-9-28.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (LDExtend)

- (UIImage *)ld_resizedImage:(CGSize)newSize quality:(CGInterpolationQuality)quality;

- (NSData *)ld_compressImageLimitSize:(long long)limitSize;

@end
