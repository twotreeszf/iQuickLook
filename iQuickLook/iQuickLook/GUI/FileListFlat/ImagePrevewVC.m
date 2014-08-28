//
//  ImagePrevewVC.m
//  iQuickLook
//
//  Created by zhang fan on 14-8-28.
//
//

#import "ImagePrevewVC.h"
#import "Modal/FileItems.h"

@interface ImagePreviewVC ()

@end

@implementation ImagePreviewVC

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	
	[self performSelector:NSSelectorFromString(@"_commonInit")];
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.dataSource = self;
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
	return [_imageFiles count];
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
	FileItem* file = [_imageFiles objectAtIndex:index];

	NSURL* url = [NSURL fileURLWithPath:file.path];
	return url;
}

@end
