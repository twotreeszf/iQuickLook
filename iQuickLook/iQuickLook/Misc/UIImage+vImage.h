//
//  UIImage+vImage.h
//  iQuickLook
//
//  Created by zhang fan on 14-8-27.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (vImage)

- (UIImage*)vImageScaledImageForSquare: (CGFloat)sideLen;
- (UIImage*)vImageScaledImageWithSize: (CGSize)destSize;

@end
