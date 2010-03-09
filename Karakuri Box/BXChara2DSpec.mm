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
        
        [self addDefaultState];
    }
    return self;
}

- (void)dealloc
{
    [mStates release];
    
    [super dealloc];
}

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

@end

