//
//  FileItems.h
//  iQuickLook
//
//  Created by zhang fan on 14-8-27.
//
//

#import <Foundation/Foundation.h>

@interface FileItem : NSObject

@property (nonatomic, copy)		NSString*	path;
@property (nonatomic, readonly) NSString*	name;
@property (nonatomic, copy)		NSString*	iNode;

@property (nonatomic, assign)	BOOL		isFolder;
@property (nonatomic, strong)	UIImage*	thumbnail;

@end

typedef void (^FetchThumbnailResultBlock)(FileItem* file);

@interface FileItemsInFolder : NSObject
{
	NSString*			_folderPath;
	NSMutableArray*		_fileItems;
}

- (instancetype)initWithFolderPath: (NSString*)folderPath;
- (NSArray*)fileItems;
- (void)fetchThumbnailsAsyncForFiles: (NSArray*)files : (FetchThumbnailResultBlock)block;
- (void)cancelFetchThumbnails;

@end
