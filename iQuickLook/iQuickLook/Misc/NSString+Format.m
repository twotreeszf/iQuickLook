//
//  NSString+Format.m
//  KuaiPan
//
//  Created by yjchen on 8/25/14.
//
//

#import "NSString+Format.h"

@implementation NSString (Format)

- (BOOL) isImageExtension
{
    NSString *ext = [[self pathExtension] lowercaseString];
    if ([ext isEqualToString:@"png"] ||
        [ext isEqualToString:@"jpg"] ||
        [ext isEqualToString:@"bmp"] ||
        [ext isEqualToString:@"jpeg"] ||
        [ext isEqualToString:@"jpe"]
        )
        return YES;
	else
		return NO;
}

@end
