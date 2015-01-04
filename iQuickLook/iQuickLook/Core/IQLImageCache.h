//
//  QLImageCache.h
//  iQuickLook
//
//  Created by zhang fan on 15/1/4.
//
//

#import <Foundation/Foundation.h>

#define kThumbnailWidth					(154 * 2)
#define kFlatViewImageFormatName		@"FlatViewThumbnail"
#define kMaxCacheCount					2048
#define kMainImageFamily				@"MainImageFamily"

@interface IQLImageCache : NSObject

+ (instancetype)sharedInstance;

- (void)configFastImageCache;

@end
