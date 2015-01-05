//
//  QLImageCache.m
//  iQuickLook
//
//  Created by zhang fan on 15/1/4.
//
//

#import "IQLImageCache.h"
#import "FICImageCache.h"

@interface IQLImageCache() <FICImageCacheDelegate>

@end

@implementation IQLImageCache

+ (instancetype)sharedInstance
{
	static IQLImageCache* obj;
	
	static dispatch_once_t token;
	dispatch_once(&token, ^
	{
	  obj = [IQLImageCache new];
	});
	
	return obj;

}

- (void)configFastImageCache
{
	FICImageFormat* flatViewThumbmailFormat = [FICImageFormat formatWithName:kFlatViewImageFormatName
																		 family:kMainImageFamily
																	  imageSize:CGSizeMake(kThumbnailWidth, kThumbnailWidth)
																		  style:FICImageFormatStyle32BitBGR
																maximumCount:kMaxCacheCount
																		devices:FICImageFormatDevicePhone | FICImageFormatDevicePad
																 protectionMode:FICImageFormatProtectionModeNone];
	
	FICImageCache *sharedImageCache = [FICImageCache sharedImageCache];
	[sharedImageCache setDelegate:self];
	[sharedImageCache setFormats:@[ flatViewThumbmailFormat ]];
	[sharedImageCache reset];
}

- (void)imageCache:(FICImageCache *)imageCache wantsSourceImageForEntity:(id <FICEntity>)entity withFormatName:(NSString *)formatName completionBlock:(FICImageRequestCompletionBlock)completionBlock
{
	[[NSOperationQueue globalQueue] addOperationWithBlock:^
	{
		UIImage *sourceImage = [UIImage imageWithContentsOfFile:[[entity sourceImageURLWithFormatName:formatName] path]];
		
		[[NSOperationQueue mainQueue] addOperationWithBlock:^
		{
			completionBlock(sourceImage);
		}];
	}];
}

@end
