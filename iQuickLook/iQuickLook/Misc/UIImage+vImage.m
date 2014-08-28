//
//  UIImage+vImage.m
//  iQuickLook
//
//  Created by zhang fan on 14-8-27.
//
//

#import "UIImage+vImage.h"
#import <Accelerate/Accelerate.h>

@implementation UIImage (vImage)

- (UIImage*)vImageScaledImageForSquare: (CGFloat)sideLen
{
	CGFloat width = self.size.width;
	CGFloat height = self.size.height;
	
	CGFloat destWidth;
	CGFloat destHeight;
	if (width > height)
	{
		destHeight = sideLen;
		destWidth = (width / height) * destHeight;
	}
	else
	{
		destWidth = sideLen;
		destHeight = (height / width) * destWidth;
	}
	
	return [self vImageScaledImageWithSize:CGSizeMake(destWidth, destHeight)];
}

- (UIImage*)vImageScaledImageWithSize: (CGSize)destSize;
{
    UIImage *destImage = nil;
	
	// First, convert the UIImage to an array of bytes, in the format expected by vImage.
	// Thanks: http://stackoverflow.com/a/1262893/1318452
	CGImageRef sourceRef = [self CGImage];
	NSUInteger sourceWidth = CGImageGetWidth(sourceRef);
	NSUInteger sourceHeight = CGImageGetHeight(sourceRef);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	unsigned char *sourceData = (unsigned char*) calloc(sourceHeight * sourceWidth * 4, sizeof(unsigned char));
	NSUInteger bytesPerPixel = 4;
	NSUInteger sourceBytesPerRow = bytesPerPixel * sourceWidth;
	NSUInteger bitsPerComponent = 8;
	CGContextRef context = CGBitmapContextCreate(sourceData, sourceWidth, sourceHeight,
												 bitsPerComponent, sourceBytesPerRow, colorSpace,
												 kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
	CGContextDrawImage(context, CGRectMake(0, 0, sourceWidth, sourceHeight), sourceRef);
	CGContextRelease(context);
	
	// We now have the source data.  Construct a pixel array
	NSUInteger destWidth = (NSUInteger) destSize.width;
	NSUInteger destHeight = (NSUInteger) destSize.height;
	NSUInteger destBytesPerRow = bytesPerPixel * destWidth;
	unsigned char *destData = (unsigned char*) calloc(destHeight * destWidth * 4, sizeof(unsigned char));
	
	// Now create vImage structures for the two pixel arrays.
	// Thanks: https://github.com/dhoerl/PhotoScrollerNetwork
	vImage_Buffer src = {
		.data = sourceData,
		.height = sourceHeight,
		.width = sourceWidth,
		.rowBytes = sourceBytesPerRow
	};
	
	vImage_Buffer dest = {
		.data = destData,
		.height = destHeight,
		.width = destWidth,
		.rowBytes = destBytesPerRow
	};
	
	// Carry out the scaling.
	vImage_Error err = vImageScale_ARGB8888 (
											 &src,
											 &dest,
											 NULL,
											 kvImageHighQualityResampling
											 );
	
	// The source bytes are no longer needed.
	free(sourceData);
	
	// Convert the destination bytes to a UIImage.
	CGContextRef destContext = CGBitmapContextCreate(destData, destWidth, destHeight,
													 bitsPerComponent, destBytesPerRow, colorSpace,
													 kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
	CGImageRef destRef = CGBitmapContextCreateImage(destContext);
	
	// Store the result.
	destImage = [UIImage imageWithCGImage:destRef];
	
	// Free up the remaining memory.
	CGImageRelease(destRef);
	
	CGColorSpaceRelease(colorSpace);
	CGContextRelease(destContext);
	
	// The destination bytes are no longer needed.
	free(destData);

	NSAssert(kvImageNoError == err, nil);
    return destImage;
}

@end
