//
//  UIImage+GPUImage.m
//  iQuickLook
//
//  Created by zhang fan on 14-8-29.
//
//

#import "UIImage+GPUImage.h"
#import "GPUImage.h"

@implementation UIImage (GPUImage)

- (CGSize)bestSizeForSquare: (CGFloat)sideLen
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
	
	return CGSizeMake(destWidth, destHeight);
}

- (UIImage*)GPUImageLanczosScaledImageForSquare: (CGFloat)sideLen
{
	CGSize size = [self bestSizeForSquare:sideLen];
	return [self GPUImageLanczosScaledImageWithSize:size];
}

- (UIImage*)GPUImageLanczosScaledImageWithSize: (CGSize)destSize
{
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:self];
	
    GPUImageLanczosResamplingFilter *lanczosResamplingFilter = [[GPUImageLanczosResamplingFilter alloc] init];
    [lanczosResamplingFilter forceProcessingAtSize:destSize];
    [stillImageSource addTarget:lanczosResamplingFilter];
    [lanczosResamplingFilter useNextFrameForImageCapture];
    [stillImageSource processImage];
	
    UIImage *lanczosImage = [lanczosResamplingFilter imageFromCurrentFramebuffer];
	return lanczosImage;
}

- (UIImage*)GPUImageTrilinearScaledImageForSquare: (CGFloat)sideLen
{
	CGSize size = [self bestSizeForSquare:sideLen];
	return [self GPUImageTrilinearScaledImageWithSize:size];
}

- (UIImage*)GPUImageTrilinearScaledImageWithSize: (CGSize)destSize
{
	GPUImagePicture *stillImageSource2 = [[GPUImagePicture alloc] initWithImage:self smoothlyScaleOutput:YES];
	GPUImageBrightnessFilter *passthroughFilter2 = [[GPUImageBrightnessFilter alloc] init];
	
	[passthroughFilter2 forceProcessingAtSize:destSize];
	[stillImageSource2 addTarget:passthroughFilter2];
	[passthroughFilter2 useNextFrameForImageCapture];
	[stillImageSource2 processImage];
	UIImage *trilinearImage = [passthroughFilter2 imageFromCurrentFramebuffer];
	
	return trilinearImage;
}

/*
 // Trilinear downsampling
 GPUImagePicture *stillImageSource2 = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
 GPUImageBrightnessFilter *passthroughFilter2 = [[GPUImageBrightnessFilter alloc] init];
 
 [passthroughFilter2 forceProcessingAtSize:CGSizeMake(640.0, 480.0)];
 [stillImageSource2 addTarget:passthroughFilter2];
 [passthroughFilter2 useNextFrameForImageCapture];
 [stillImageSource2 processImage];
 UIImage *trilinearImage = [passthroughFilter2 imageFromCurrentFramebuffer];
 */

@end
