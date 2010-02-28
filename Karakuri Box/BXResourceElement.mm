//
//  BXResourceElement.m
//  Karakuri Box
//
//  Created by numata on 10/02/27.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXResourceElement.h"


@interface BXResourceElement ()

- (void)setParent:(BXResourceElement*)anElem;

@end


@implementation BXResourceElement

#pragma mark -
#pragma mark 初期化・クリーンアップ

- (id)initWithName:(NSString*)name
{
    self = [super init];
    if (self) {
        mName = [name copy];
        mChildElements = [[NSMutableArray array] retain];
    }
    return self;
}

- (void)dealloc
{
    [mName release];
    [mChildElements release];
    [super dealloc];
}


#pragma mark -
#pragma mark 項目の管理

- (NSString*)localizedName
{
    if ([mName hasPrefix:@"*"]) {
        return NSLocalizedString(mName, nil);
    }
    return mName;
}

- (BOOL)isExpandable
{
    return NO;
}

- (BOOL)isGroupItem
{
    return NO;
}


#pragma mark -
#pragma mark 子供の管理

- (void)addChild:(BXResourceElement*)anElem
{
    [anElem setParent:self];
    [mChildElements addObject:anElem];
}

- (int)childCount
{
    return [mChildElements count];
}

- (BXResourceElement*)childAtIndex:(int)index
{
    return [mChildElements objectAtIndex:index];
}

- (void)removeChild:(BXResourceElement*)anElem
{
    [anElem setParent:nil];
    [mChildElements removeObject:anElem];
}

- (void)setParent:(BXResourceElement*)anElem
{
    mParentElement = anElem;
}

@end

