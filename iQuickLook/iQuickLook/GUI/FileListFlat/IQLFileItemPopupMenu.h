//
//  IQLFileItemPopupMenu.h
//  iQuickLook
//
//  Created by zhang fan on 15/1/6.
//
//

#import <UIKit/UIKit.h>
#import "WYPopoverController.h"

@protocol IQLPopupMenuDelegate <NSObject>

- (void)didSelectMenu: (UIView*)menuItem;

@end


@interface IQLFileItemPopupMenu : UITableViewController

@property (nonatomic, weak)		WYPopoverController*			popController;
@property (nonatomic, weak)		id<IQLPopupMenuDelegate>		delegate;

@end
