//
//  FileItems.m
//  iQuickLook
//
//  Created by zhang fan on 14-8-27.
//
//

#define kThumbnailWidth					154
#define kThumbnailFolderName			@".thumbnail"

#import "FileItems.h"

@implementation FileItem

- (NSString*)name
{
	return [self.path lastPathComponent];
}

@end

@interface FileItemsInFolder()

- (NSString*)_thumbnailPathForFile: (FileItem*)file;
- (UIImage*)_fetchFileThumbnail: (FileItem*)file;

@end

@implementation FileItemsInFolder

- (instancetype)initWithFolderPath:(NSString *)folderPath
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
			item.isFolder	= [NSFileTypeDirectory isEqualToString:fileType];
			item.path		= filePath;
			item.iNode		= [NSString stringWithFormat:@"%lu", (unsigned long)[attrDic fileSystemFileNumber]];
			[_fileItems addObject:item];
		}
	}
	
	return _fileItems;
}

- (void)fetchThumbnailsAsync:(FetchThumbnailResultBlock)block
{
	[[NSOperationQueue globalQueue] addOperationWithBlock:^
	{
		for (FileItem* file in _fileItems)
		{
			if ((file.isFolder && !file.folderCover) ||
				(!file.isFolder && !file.fileThumbnail))
			{
				UIImage* thumbnail;
				if (!file.isFolder)
				{
					thumbnail = [self _fetchFileThumbnail:file];
				}
				else
				{
					FileItemsInFolder* fileItems = [[FileItemsInFolder alloc] initWithFolderPath:file.path];
					NSArray* files = [fileItems fileItems];
					if ([files count])
					{
						FileItem* firstFile = [files firstObject];
						thumbnail = [self _fetchFileThumbnail:firstFile];
					}
				}
				
				if (thumbnail)
				{
					if (!file.isFolder)
						file.fileThumbnail = thumbnail;
					else
						file.folderCover = thumbnail;
					
					[[NSOperationQueue mainQueue] addOperationWithBlock:^
					{
						block(file);
					}];
				}
			}
		}
	}];
}

- (NSString*)_thumbnailPathForFile: (FileItem*)file;
{
	NSAssert([file.iNode length], nil);
	
	NSString* fileInFolder = [file.path stringByDeletingLastPathComponent];
	NSString* thumbnailFolder = [fileInFolder stringByAppendingPathComponent:kThumbnailFolderName];
	if (![[NSFileManager defaultManager] fileExistsAtPath:thumbnailFolder])
	{
		[[NSFileManager defaultManager] createDirectoryAtPath:thumbnailFolder
								  withIntermediateDirectories:NO
												   attributes:nil
														error:nil];
	}
	
	NSString* thumbnailFileName = [NSString stringWithFormat:@"%@.png", file.iNode];
	NSString* thumbnailPath = [thumbnailFolder stringByAppendingPathComponent:thumbnailFileName];
	return thumbnailPath;
}

- (UIImage*)_fetchFileThumbnail: (FileItem*)file
{
	NSString* thumbnailPath = [self _thumbnailPathForFile:file];
	if (![[NSFileManager defaultManager] fileExistsAtPath:thumbnailPath])
	{
		UIImage* sourceImage = [UIImage imageWithContentsOfFile:file.path];
		if (!sourceImage)
			return nil;
		
		UIImage* destImage = [sourceImage vImageScaledImageForSquare:kThumbnailWidth];
		if (!destImage)
			return nil;
		
		NSData* destData = UIImagePNGRepresentation(destImage);
		BOOL ret = [destData writeToFile:thumbnailPath atomically:YES];
		if (!ret)
			return nil;
	}
	
	NSAssert([[NSFileManager defaultManager] fileExistsAtPath:thumbnailPath], nil);
	return [UIImage imageWithContentsOfFile:thumbnailPath];
}

@end
