//
//  UIImage+GPUImage.h
//  iQuickLook
//
//  Created by zhang fan on 14-8-29.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (GPUImage)

- (UIImage*)GPUImageLanczosScaledImageForSquare: (CGFloat)sideLen;
- (UIImage*)GPUImageLanczosScaledImageWithSize: (CGSize)destSize;

- (UIImage*)GPUImageTrilinearScaledImageForSquare: (CGFloat)sideLen;
- (UIImage*)GPUImageTrilinearScaledImageWithSize: (CGSize)destSize;

@end
