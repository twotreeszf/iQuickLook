//
//  NSMutableArray+Queue.h
//  KuaiPan
//
//  Created by zhang fan on 14-8-7.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Queue)

- (id) dequeue;
- (void) enqueue:(id)obj;

@end
