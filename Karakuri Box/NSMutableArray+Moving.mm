//
//  NSMutableArray+Moving.mm
//  Karakuri Box
//
//  Created by numata on 10/03/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "NSMutableArray+Moving.h"


@implementation NSMutableArray (Moving)

- (int)moveObjectAtIndex:(int)index beforeIndex:(int)targetIndex
{
    if (index == targetIndex || index == targetIndex-1) {
        return index;
    }

    int newIndex = targetIndex;
    if (index <= targetIndex) {
        newIndex -= 1;
    }
    
    id obj = [self objectAtIndex:index];
    [obj retain];
    [self removeObjectAtIndex:index];
    [self insertObject:obj atIndex:newIndex];
    [obj release];
    
    return newIndex;
}

@end

