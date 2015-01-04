//
//  TTAppDelegate.m
//  iQuickLook
//
//  Created by zhang fan on 14-8-27.
//
//

#import "AppDelegate.h"
#import "IQLImageCache.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[[IQLImageCache sharedInstance] configFastImageCache];
	
    return YES;
}

@end
