//
//  UIImage+LDSDKShare.m
//  Pods
//
//  Created by xuguoxing on 14-9-28.
//
//

#import "UIImage+LDExtend.h"

@implementation UIImage (LDExtend)


// Returns a rescaled copy of the image, taking into account its orientation
// The image will be scaled disproportionately if necessary to fit the bounds specified by the
// parameter
- (UIImage *)ld_resizedImage:(CGSize)newSize quality:(CGInterpolationQuality)quality {
    BOOL drawTransposed;

    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            drawTransposed = YES;
            break;

        default:
            drawTransposed = NO;
    }

    return [self ld_resizedImage:newSize
                       transform:[self LDSDKShare_transformForOrientation:newSize]
                  drawTransposed:drawTransposed
                         quality:quality];
}

- (NSData *)ld_compressImageLimitSize:(long long)limitSize {
    CGSize thumbSize = self.size;
    UIImage *thumbImage = self;
    NSData *imageData = UIImageJPEGRepresentation(self, 1.0);
    NSData *thumbData = [NSData dataWithData:imageData];
    while (thumbData.length > limitSize) {
        thumbSize = CGSizeMake(thumbSize.width / 1.5f, thumbSize.height / 1.5f);
        thumbImage = [thumbImage ld_resizedImage:thumbSize quality:kCGInterpolationDefault];
        thumbData = UIImageJPEGRepresentation(thumbImage, 0.5);
    }
    return thumbData;
}


// Returns a copy of the image that has been transformed using the given affine transform and scaled
// to the new size
// The new image's orientation will be UIImageOrientationUp, regardless of the current image's
// orientation
// If the new size is not integral, it will be rounded up
- (UIImage *)ld_resizedImage:(CGSize)newSize
                   transform:(CGAffineTransform)transform
              drawTransposed:(BOOL)transpose
                     quality:(CGInterpolationQuality)quality {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = self.CGImage;

    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(
            NULL, newRect.size.width, newRect.size.height, CGImageGetBitsPerComponent(imageRef), 0,
            CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef));

    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);

    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);

    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);

    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];

    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);

    return newImage;
}

// Returns an affine transform that takes into account the image orientation when drawing a scaled
// image
- (CGAffineTransform)LDSDKShare_transformForOrientation:(CGSize)newSize {
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (self.imageOrientation) {
        case UIImageOrientationDown:          // EXIF = 3
        case UIImageOrientationDownMirrored:  // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;

        case UIImageOrientationLeft:          // EXIF = 6
        case UIImageOrientationLeftMirrored:  // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;

        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:    // EXIF = 2
        case UIImageOrientationDownMirrored:  // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;

        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }

    return transform;
}

@end
