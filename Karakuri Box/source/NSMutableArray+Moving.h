//
//  NSMutableArray+Moving.h
//  Karakuri Box
//
//  Created by numata on 10/03/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSMutableArray (Moving)

- (int)moveObjectAtIndex:(int)index beforeIndex:(int)targetIndex;

@end

