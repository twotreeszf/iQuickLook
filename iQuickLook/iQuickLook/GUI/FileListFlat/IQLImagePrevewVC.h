//
//  ImagePrevewVC.h
//  iQuickLook
//
//  Created by zhang fan on 14-8-28.
//
//

#import <QuickLook/QuickLook.h>

@interface IQLImagePreviewVC : QLPreviewController <QLPreviewControllerDataSource>

@property (nonatomic, strong) NSArray* imageFiles;

@end
