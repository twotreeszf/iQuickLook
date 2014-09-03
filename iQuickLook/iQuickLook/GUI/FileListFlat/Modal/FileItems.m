//
//  FileItems.m
//  iQuickLook
//
//  Created by zhang fan on 14-8-27.
//
//

#define kThumbnailWidth					(154 * 2)
#define kThumbnailFolderName			@".thumbnail"

#import "FileItems.h"

typedef NS_ENUM(NSUInteger, GenerateThumbnailType)
{
    GTT_CPU,
    GTT_GPU,
};

@implementation FileItem

- (NSString*)name
{
	return [self.path lastPathComponent];
}

@end

@interface FileItemsInFolder()
{
	NSMutableDictionary* _images4GenerateThumbnail;
	
	NSOperationQueue* _fetchThumbnailQueue;
}


- (NSString*)_thumbnailPathForFile: (FileItem*)file;

- (FileItem*)_firstFileInFolder: (FileItem*)folder;
- (NSString*)_thumbnailPathForFolder: (FileItem*)folder;

- (UIImage*)_fetchFileThumbnail: (FileItem*)file;
- (UIImage*)_generateFileThumbnail: (FileItem*)file : (GenerateThumbnailType)type;

@end

@implementation FileItemsInFolder

- (instancetype)initWithFolderPath:(NSString *)folderPath
{
	self = [super init];
	
	_folderPath = folderPath;
	
	_images4GenerateThumbnail = [NSMutableDictionary new];
	
	_fetchThumbnailQueue = [NSOperationQueue new];
	[_fetchThumbnailQueue setMaxConcurrentOperationCount:1];
	
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

- (void)fetchThumbnailsAsyncForFiles: (NSArray*)files : (FetchThumbnailResultBlock)block;
{
	[_fetchThumbnailQueue cancelAllOperations];
	
	NSBlockOperation* blockOpt = [NSBlockOperation new];
	NSOperation* weakOpt = blockOpt;
	
	[blockOpt addExecutionBlock:^
	 {
		 for (FileItem* file in files)
		 {
			 if ([weakOpt isCancelled])
				 break;
			 
			 if (!file.thumbnail)
			 {
				 file.thumbnail = [self _fetchFileThumbnail:file];
				 if (!file.thumbnail)
					 file.thumbnail = [self _generateFileThumbnail:file :GTT_CPU];
				 
				 X_ASSERT(file.thumbnail);
				 if (file.thumbnail)
					 [[NSOperationQueue mainQueue] addOperationWithBlock:^
					  {
						  block(file);
					  }];
			 }
		 }
	 }];
	
	[_fetchThumbnailQueue addOperation:blockOpt];
}

- (void)cancelFetchThumbnails
{
	[_fetchThumbnailQueue cancelAllOperations];
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

- (NSString*)_thumbnailPathForFolder: (FileItem*)folder
{
	FileItem* firstFile = [self _firstFileInFolder:folder];
	
	return [self _thumbnailPathForFile:firstFile];
}

- (FileItem*)_firstFileInFolder: (FileItem*)folder
{
	FileItem* firstFile;
	
	FileItemsInFolder* fileItems = [[FileItemsInFolder alloc] initWithFolderPath:folder.path];
	NSArray* files = [fileItems fileItems];
	for (FileItem* file in files)
	{
		if (!file.isFolder)
		{
			NSAssert([file.path isImageExtension], nil);
			
			firstFile = [files firstObject];
		}
	}
	
	return firstFile;
}

- (UIImage*)_fetchFileThumbnail: (FileItem*)file
{
	UIImage* thumbnail;
	{
		NSString* thumbnailPath = file.isFolder ? [self _thumbnailPathForFolder:file] : [self _thumbnailPathForFile:file];
		if ([[NSFileManager defaultManager] fileExistsAtPath:thumbnailPath])
		{
			thumbnail = [UIImage imageWithContentsOfFile:thumbnailPath];
			ERROR_CHECK_BOOL(thumbnail);
		}
	}
	
Exit0:
	return thumbnail;
}

- (UIImage*)_generateFileThumbnail: (FileItem*)file : (GenerateThumbnailType)type;
{
	UIImage* thumbnail;
	{
		NSString* sourcePath;
		FileItem* firstFileInFolder;
		if (file.isFolder)
		{
			firstFileInFolder = [self _firstFileInFolder:file];
			sourcePath = firstFileInFolder.path;
		}
		else
			sourcePath = file.path;
		
		UIImage* sourceImage = [UIImage imageWithContentsOfFile:sourcePath];
		ERROR_CHECK_BOOL(sourceImage);
		
		UIImage* destImage;
		if (GTT_CPU == type)
			destImage = [sourceImage vImageScaledImageForSquare:kThumbnailWidth :YES];
		else
			destImage = [sourceImage GPUImageLanczosScaledImageForSquare:kThumbnailWidth];
		ERROR_CHECK_BOOL(destImage);
		
		NSData* destData = UIImagePNGRepresentation(destImage);
		
		NSString* thumbnailPath = file.isFolder ? [self _thumbnailPathForFile:firstFileInFolder] : [self _thumbnailPathForFile:file];
		BOOL ret = [destData writeToFile:thumbnailPath atomically:YES];
		ERROR_CHECK_BOOL(ret);
		
		thumbnail = destImage;
	}
	
Exit0:
	return thumbnail;
}

@end
