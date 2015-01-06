//
//  FileItems.h
//  iQuickLook
//
//  Created by zhang fan on 14-8-27.
//
//

#import <Foundation/Foundation.h>
#import "FICEntity.h"

@interface FileItem : NSObject <FICEntity>

@property (nonatomic, copy)		NSString*		path;
@property (nonatomic, readonly) NSString*		name;
@property (nonatomic, copy)		NSString*		iNode;
@property (nonatomic, assign)	BOOL			isFolder;

@end

typedef void (^FetchThumbnailResultBlock)(FileItem* file);

@interface FileItemsInFolder : NSObject
{
	NSString*			_folderPath;
}

@property (nonatomic, strong)	NSMutableArray* fileItems;

- (instancetype)initWithFolderPath: (NSString*)folderPath;
- (void)fetchThumbnailsAsyncForFiles:(NSArray*)files resultBlock:(FetchThumbnailResultBlock)block;
- (void)cancelFetchThumbnails;

@end
