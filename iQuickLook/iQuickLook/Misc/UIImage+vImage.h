//
//  UIImage+vImage.h
//  iQuickLook
//
//  Created by zhang fan on 14-8-27.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (vImage)

- (UIImage*)vImageScaledImageForSquare: (CGFloat)sideLen : (BOOL)highQuality;
- (UIImage*)vImageScaledImageWithSize: (CGSize)destSize : (BOOL)highQuality;

@end
