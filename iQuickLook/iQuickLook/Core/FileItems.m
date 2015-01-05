//
//  FileItems.m
//  iQuickLook
//
//  Created by zhang fan on 14-8-27.
//
//

#import "FileItems.h"
#import "FICImageCache.h"
#import "IQLImageCache.h"
#import "FICUtilities.h"

@implementation FileItem
{
    NSString*	_UUID;
	NSURL*		_imagePath;
}

- (NSString*)name
{
    return [self.path lastPathComponent];
}

#pragma mark - FICImageCacheEntity

- (NSString*)UUID
{
	CFUUIDBytes UUIDBytes = FICUUIDBytesFromMD5HashOfString(_iNode);
	_UUID = FICStringWithUUIDBytes(UUIDBytes);

    return _UUID;
}

- (NSString*)sourceImageUUID
{
    return [self UUID];
}

- (NSURL*)sourceImageURLWithFormatName:(NSString*)formatName
{
	if (!_imagePath)
	{
		if (_isFolder)
			_imagePath = [NSURL fileURLWithPath:[self _firstFileInFolder].path];
		else
			_imagePath = [NSURL fileURLWithPath:_path];
	}
	
	return _imagePath;
}

- (FICEntityImageDrawingBlock)drawingBlockForImage:(UIImage*)image withFormatName:(NSString*)formatName
{
    FICEntityImageDrawingBlock drawingBlock = ^(CGContextRef contextRef, CGSize contextSize)
	{
		// clear
		CGRect contextBounds = CGRectZero;
		contextBounds.size = contextSize;
		CGContextClearRect(contextRef, contextBounds);
		
		// draw image
		CGFloat sideLen = contextSize.width;
		CGFloat width = image.size.width;
		CGFloat height = image.size.height;

		CGFloat destWidth;
		CGFloat destHeight;
		if (!_isFolder)
		{
			if (width < height)
			{
				destHeight = sideLen;
				destWidth = (width / height) * destHeight;
			}
			else
			{
				destWidth = sideLen;
				destHeight = (height / width) * destWidth;
			}
			
		}
		else
		{
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
		}
		
		UIGraphicsPushContext(contextRef);
		[image drawInRect:CGRectMake((sideLen - destWidth) / 2.0, (sideLen - destHeight) / 2.0, destWidth, destHeight)];
		UIGraphicsPopContext();

    };

    return drawingBlock;
}

- (FileItem*)_firstFileInFolder
{
	FileItem* firstFile;
	
	FileItemsInFolder* fileItems = [[FileItemsInFolder alloc] initWithFolderPath:self.path];
	NSArray* files = [fileItems fileItems];
	for (FileItem* file in files)
	{
		if (!file.isFolder)
		{
			NSAssert([file.path isImageExtension], nil);
			
			firstFile = [files firstObject];
			break;
		}
	}
	
	return firstFile;
}

@end

@implementation FileItemsInFolder

#pragma mark - Public

- (instancetype)initWithFolderPath:(NSString*)folderPath
{
    self = [super init];

    _folderPath = folderPath;

    return self;
}

- (NSArray*)fileItems
{
    if (!_fileItems)
    {
        _fileItems = [NSMutableArray new];

        NSArray* fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_folderPath error:nil];
        for (NSString* fileName in fileNames)
        {
            if ([fileName characterAtIndex:0] == '.')
                continue;

            NSString* filePath = [_folderPath stringByAppendingPathComponent:fileName];
            NSDictionary* attrDic = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];

            NSString* fileType = [attrDic fileType];
            if (![NSFileTypeDirectory isEqualToString:fileType] && ![NSFileTypeRegular isEqualToString:fileType])
                continue;

            if ([NSFileTypeRegular isEqualToString:fileType] && ![filePath isImageExtension])
                continue;

            FileItem* item = [FileItem new];
            item.isFolder = [NSFileTypeDirectory isEqualToString:fileType];
            item.path = filePath;
            item.iNode = [NSString stringWithFormat:@"%lu", (unsigned long)[attrDic fileSystemFileNumber]];
            [_fileItems addObject:item];
        }
    }

    return _fileItems;
}

- (void)fetchThumbnailsAsyncForFiles:(NSArray*)files resultBlock:(FetchThumbnailResultBlock)block;
{
	[self cancelFetchThumbnails];

	for (FileItem* file in files)
	{
		if ([[FICImageCache sharedImageCache] imageExistsForEntity:file withFormatName:kFlatViewImageFormatName])
			continue;
		
		[[FICImageCache sharedImageCache] retrieveImageForEntity:file
												  withFormatName:kFlatViewImageFormatName
												 completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image)
		{
			block(file);
		}];
	}
}

- (void)cancelFetchThumbnails
{
	[[FICImageCache sharedImageCache] cancelAllImageRetrievals];
}

@end
