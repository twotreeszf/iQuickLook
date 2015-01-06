//
//  IQLFileItemPopupMenu.m
//  iQuickLook
//
//  Created by zhang fan on 15/1/6.
//
//

#import "IQLFileItemPopupMenu.h"

@interface IQLFileItemPopupMenu ()

@end

@implementation IQLFileItemPopupMenu

- (void)viewDidLoad
{
	[super viewDidLoad];
 
	self.preferredContentSize = CGSizeMake(120, 1 * 44);
	self.tableView.tableHeaderView = nil;
	self.tableView.tableFooterView = [[UIView alloc]init];
}

-(void) viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	
	if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
		[self.tableView setSeparatorInset:UIEdgeInsetsZero];
	}
	
	if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
		[self.tableView setLayoutMargins:UIEdgeInsetsZero];
	}
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
		[cell setSeparatorInset:UIEdgeInsetsZero];
	}
	
	if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
		[cell setLayoutMargins: UIEdgeInsetsZero];
	}
}

- (void)setPopController:(WYPopoverController *)popController
{
	_popController = popController;
	
	_popController.popoverLayoutMargins = UIEdgeInsetsMake(4, 4, 4, 4);
	_popController.theme.fillTopColor = [UIColor blueColor];
	_popController.theme.overlayColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	[_popController dismissPopoverAnimated:YES completion:^
	 {
		 [_delegate didSelectMenu:[tableView cellForRowAtIndexPath:indexPath]];
	 }];
}

@end
