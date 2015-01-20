//
//  FileListFlatVC.m
//  iQuickLook
//
//  Created by zhang fan on 14-8-27.
//
//

#import "IQLFileListFlatVC.h"
#import "FileItems.h"
#import "IQLImageCell.h"
#import "IQLFolderCell.h"
#import "IQLImagePrevewVC.h"
#import "FICImageCache.h"
#import "IQLImageCache.h"
#import "WYPopoverController.h"
#import "IQLFileItemPopupMenu.h"

//--------------------------------------------------------------------------------------------------------------------------------------------------------------

@interface IQLFileListFlatVC () <IQLPopupMenuDelegate, WYPopoverControllerDelegate>
{
	FileItemsInFolder*		_filesInFolder;
	NSArray*				_fileList;
	BOOL					_isScrolling;
	NSIndexPath*			_selectCellIndex;
	WYPopoverController*	_fileItemPopover;
}

- (void)_reloadData;
- (void)_updateThumbnailFromVisibelCell;
- (void)_updateCellWithFileItem: (UICollectionViewCell*)cell : (FileItem*)file;
- (BOOL)_isScrolling;

@end

@implementation IQLFileListFlatVC

- (void)viewDidLoad
{
	if (!self.folderPath)
		self.folderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

	_filesInFolder = [[FileItemsInFolder alloc] initWithFolderPath:self.folderPath];
	
	// attach long press gesture to collectionView
	UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressOnItem:)];
	longPress.delaysTouchesBegan = YES;
	[self.collectionView addGestureRecognizer:longPress];
}

- (void)viewDidAppear:(BOOL)animated
{
	[self _reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[_filesInFolder cancelFetchThumbnails];
}

- (void)setFolderPath:(NSString *)folderPath
{
	_folderPath = folderPath;
	
	self.navigationItem.title = [_folderPath lastPathComponent];
}

- (void)onLongPressOnItem:(UILongPressGestureRecognizer *)sender
{
	if (_fileItemPopover)
		return;
	
	CGPoint p = [sender locationInView:self.collectionView];
	_selectCellIndex = [self.collectionView indexPathForItemAtPoint:p];
	if (!_selectCellIndex)
		return;
	
	IQLFileItemPopupMenu* menu = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FileItemPoopupMenu"];
	_fileItemPopover = [[WYPopoverController alloc] initWithContentViewController:menu];
	_fileItemPopover.delegate = self;
	
	menu.popController = _fileItemPopover;
	menu.delegate = self;
	
	CGRect cellRect = [self.collectionView cellForItemAtIndexPath:_selectCellIndex].frame;
	CGRect centerRect = CGRectMake(cellRect.origin.x + cellRect.size.width / 2.0, cellRect.origin.y + cellRect.size.height / 2.0, 1.0, 1.0);
	
	[_fileItemPopover presentPopoverFromRect:centerRect
									  inView:self.collectionView
					permittedArrowDirections:WYPopoverArrowDirectionLeft | WYPopoverArrowDirectionRight
									animated:YES];
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)popoverController
{
	_fileItemPopover = nil;
}

- (void)didSelectMenu: (UIView*)menuItem
{
	_fileItemPopover = nil;
	
	if ([[menuItem.userData valueForKey:@"ID"] isEqualToString:@"Delete"])
	{
		FileItem* file = _fileList[_selectCellIndex.row];
		
		[[NSFileManager defaultManager] removeItemAtPath:file.path error:nil];
		
		_filesInFolder.fileItems = nil;
		[self _reloadData];
	}
	
	_selectCellIndex = nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [_fileList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell* cell;
	
	FileItem* file = [_fileList objectAtIndex:indexPath.row];
	if (!file.isFolder)
	{
		IQLImageCell* imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
		cell = imageCell;
	}
	else
	{
		IQLFolderCell* folderCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FolderCell" forIndexPath:indexPath];
		cell = folderCell;
	}
	
	[self _updateCellWithFileItem:cell :file];
	
	return cell;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
	_isScrolling = YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	_isScrolling = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	_isScrolling = NO;

	[self _updateThumbnailFromVisibelCell];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (!decelerate)
	{
		_isScrolling = NO;
		
		[self _updateThumbnailFromVisibelCell];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"BrowseFolder"])
	{
		IQLFileListFlatVC* vc = (IQLFileListFlatVC*)segue.destinationViewController;
		
		NSUInteger row = [self.collectionView indexPathForCell:sender].row;
		FileItem* folder = [_fileList objectAtIndex:row];
		NSAssert(folder.isFolder, nil);
		vc.folderPath = folder.path;
	}
	else if ([segue.identifier isEqualToString:@"PreviewImages"])
	{
		IQLImagePreviewVC* vc = (IQLImagePreviewVC*)segue.destinationViewController;
		
		NSMutableArray* images = [NSMutableArray new];
		for (FileItem* file in _fileList)
		{
			if (!file.isFolder)
				[images addObject:file];
		}
		vc.imageFiles = images;
		
		NSUInteger row = [self.collectionView indexPathForCell:sender].row;
		vc.currentPreviewItemIndex = row;
	}
}

- (void)_reloadData
{
	_fileList = [_filesInFolder fileItems];
	[self.collectionView reloadData];

	[self _updateThumbnailFromVisibelCell];
}

- (void)_updateThumbnailFromVisibelCell
{
	NSArray* visibleCells = [self.collectionView visibleCells];
	NSInteger firstCell =  visibleCells.count ? _fileList.count : 0;
	
	for (UICollectionViewCell* cell in visibleCells)
	{
		NSUInteger currentIndex = [self.collectionView indexPathForCell:cell].row;
		if (currentIndex < firstCell)
			firstCell = currentIndex;
	}
	
	NSMutableArray* files2Update = [NSMutableArray new];
	for (NSInteger i = firstCell; i < [_fileList count]; ++i)
		[files2Update addObject:[_fileList objectAtIndex:i]];
	
	for (NSInteger i = firstCell - 1; i >= 0; --i)
		[files2Update addObject:[_fileList objectAtIndex:i]];
	
	__weak IQLFileListFlatVC* weakSelf = self;
	[_filesInFolder fetchThumbnailsAsyncForFiles:files2Update resultBlock:^(FileItem *file)
	{
		if ([weakSelf _isScrolling])
			return;
		
		 NSUInteger index = [_fileList indexOfObject:file];
		 UICollectionViewCell* cell = [weakSelf.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
		 if (cell)
			 [weakSelf _updateCellWithFileItem:cell :file];
	}];
}

- (void)_updateCellWithFileItem: (UICollectionViewCell*)cell : (FileItem*)file
{
	UIImageView* imageView;
	if (!file.isFolder)
		imageView = ((IQLImageCell*)cell).imageThumbnail;
	else
		imageView = ((IQLFolderCell*)cell).folderCover;

	if (![[FICImageCache sharedImageCache] imageExistsForEntity:file withFormatName:kFlatViewImageFormatName])
	{
		if (!file.isFolder)
			imageView.image = [UIImage imageNamed:@"PhotoCover"];
		else
			imageView.image = nil;
	}
	else
	{
		[[FICImageCache sharedImageCache] retrieveImageForEntity:file
												  withFormatName:kFlatViewImageFormatName
												 completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image)
		 {
			 
			 if (imageView.image != image)
				 imageView.image = image;
		 }];
	}
}

- (BOOL)_isScrolling
{
	return _isScrolling;
}

@end