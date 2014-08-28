//
//  FileListFlatVC.m
//  iQuickLook
//
//  Created by zhang fan on 14-8-27.
//
//



//--------------------------------------------------------------------------------------------------------------------------------------------------------------

#import "FileListFlatVC.h"
#import "Modal/FileItems.h"
#import "ImageCell.h"
#import "FolderCell.h"
#import "ImagePrevewVC.h"

@interface FileListFlatVC ()
{
	FileItemsInFolder*	_filesInFolder;
	NSArray*			_fileList;
}

- (void)_reloadData;
- (void)_updateCellWithFileItem: (UICollectionViewCell*)cell : (FileItem*)file;

@end

@implementation FileListFlatVC

- (void)viewDidLoad
{
	if (!self.folderPath)
		self.folderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

	_filesInFolder = [[FileItemsInFolder alloc] initWithFolderPath:self.folderPath];

	[self _reloadData];
}

- (void)setFolderPath:(NSString *)folderPath
{
	_folderPath = folderPath;
	
	self.navigationItem.title = [_folderPath lastPathComponent];
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
		ImageCell* imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
		cell = imageCell;
	}
	else
	{
		FolderCell* folderCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FolderCell" forIndexPath:indexPath];
		cell = folderCell;
	}
	
	[self _updateCellWithFileItem:cell :file];
	
	return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"BrowseFolder"])
	{
		FileListFlatVC* vc = (FileListFlatVC*)segue.destinationViewController;
		
		NSUInteger row = [self.collectionView indexPathForCell:sender].row;
		FileItem* folder = [_fileList objectAtIndex:row];
		NSAssert(folder.isFolder, nil);
		vc.folderPath = folder.path;
	}
	else if ([segue.identifier isEqualToString:@"PreviewImages"])
	{
		ImagePreviewVC* vc = (ImagePreviewVC*)segue.destinationViewController;
		
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
	
	__weak FileListFlatVC* weakSelf = self;
	[_filesInFolder fetchThumbnailsAsync:^(FileItem *file)
	 {
		 NSUInteger index = [_fileList indexOfObject:file];
		 UICollectionViewCell* cell = [weakSelf.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
		 if (cell)
			 [self _updateCellWithFileItem:cell :file];
	 }];
}

- (void)_updateCellWithFileItem: (UICollectionViewCell*)cell : (FileItem*)file
{
	if (!file.isFolder)
	{
		ImageCell* imageCell = (ImageCell*)cell;
		if (file.fileThumbnail)
			imageCell.imageThumbnail.image = file.fileThumbnail;
		else
			imageCell.imageThumbnail.image = [UIImage imageNamed:@"Image.png"];
	}
	else
	{
		FolderCell* folderCell = (FolderCell*)cell;
		
		folderCell.folderName.text = file.name;
		if (file.folderCover)
			folderCell.folderCover.image = file.folderCover;
	}
}

@end