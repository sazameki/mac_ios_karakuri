//
//  BXChara2DSpec.m
//  Karakuri Box
//
//  Created by numata on 10/02/28.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXChara2DSpec.h"


@interface BXChara2DSpec ()

- (void)addDefaultState;

@end


@implementation BXChara2DSpec

#pragma mark -
#pragma mark 初期化・クリーンアップ

- (id)initWithName:(NSString*)name
{
    self = [super initWithName:name];
    if (self) {
        mStates = [[NSMutableArray alloc] init];
        mImages = [[NSMutableArray alloc] init];

        [self addDefaultState];
    }
    return self;
}

- (void)dealloc
{
    [mStates release];
    [mImages release];

    [super dealloc];
}


#pragma mark -
#pragma mark メインの操作

- (void)addDefaultState
{
    BXChara2DState* theState = [self addNewState];
    [theState setName:@"Default"];
}

- (BXChara2DState*)addNewState
{
    BXChara2DState* newState = [[[BXChara2DState alloc] initWithName:@"State"] autorelease];
    
    [mStates addObject:newState];
    
    return newState;
}

- (int)stateCount
{
    return [mStates count];
}

- (BXChara2DState*)stateAtIndex:(int)index
{
    return [mStates objectAtIndex:index];
}

- (void)removeState:(BXChara2DState*)theState
{
    [mStates removeObject:theState];
}


- (BXChara2DImage*)addImageAtPath:(NSString*)path document:(BXDocument*)document
{
    BXChara2DImage* anImage = [[[BXChara2DImage alloc] initWithFilepath:path document:document] autorelease];
    [mImages addObject:anImage];
    return anImage;
}

- (int)imageCount
{
    return [mImages count];
}

- (BXChara2DImage*)imageAtIndex:(int)index
{
    return [mImages objectAtIndex:index];
}

@end

