//
//  BXChara2DSpec.m
//  Karakuri Box
//
//  Created by numata on 10/02/28.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXChara2DSpec.h"
#import "NSDictionary+LoadSave.h"


@interface BXChara2DSpec ()

- (void)addDefaultState;

@end


@implementation BXChara2DSpec

#pragma mark -
#pragma mark 初期化・クリーンアップ

- (id)initWithName:(NSString*)name defaultState:(BOOL)hasDefaultState
{
    self = [super initWithName:name];
    if (self) {
        mStates = [[NSMutableArray alloc] init];
        mImages = [[NSMutableArray alloc] init];

        if (hasDefaultState) {
            [self addDefaultState];
        }
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
    [theState setStateName:@"Default"];
}

- (BXChara2DState*)addNewState
{
    BXChara2DState* newState = [[[BXChara2DState alloc] initWithName:@"State" chara2DSpec:self] autorelease];
    
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

- (void)sortStateList
{
    NSSortDescriptor* sortDesc = [[[NSSortDescriptor alloc] initWithKey:@"stateID"
                                                              ascending:YES] autorelease];
    
    [mStates sortUsingDescriptors:[NSArray arrayWithObject:sortDesc]];    
}

- (void)changeStateIDInAllKomaFrom:(int)oldStateID to:(int)newStateID
{
    for (int i = 0; i < [mStates count]; i++) {
        BXChara2DState* aState = (BXChara2DState*)[mStates objectAtIndex:i];
        [aState changeStateIDInAllKomaFrom:oldStateID to:newStateID];
    }    
}

- (int)nextImageID
{
    int ret = 0;
    
    while (ret < 10000) {
        BOOL found = NO;
        for (int i = 0; i < [mImages count]; i++) {
            BXChara2DImage* anImage = [mImages objectAtIndex:i];
            if ([anImage imageID] == ret) {
                found = YES;
                break;
            }
        }
        if (!found) {
            break;
        }
        ret++;
    }
    
    if (ret == 10000) {
        return -1;
    }
    
    return ret;
}

- (BXChara2DImage*)addImageAtPath:(NSString*)path document:(BXDocument*)document
{
    BXChara2DImage* anImage = [[[BXChara2DImage alloc] initWithFilepath:path imageID:[self nextImageID] document:document] autorelease];
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

- (BXChara2DImage*)imageWithID:(int)imageID
{
    for (int i = 0; i < [mImages count]; i++) {
        BXChara2DImage* anImage = [mImages objectAtIndex:i];
        if ([anImage imageID] == imageID) {
            return anImage;
        }
    }
    return nil;
}


#pragma mark -
#pragma mark シリアライゼーションのサポート

- (NSDictionary*)elementInfo
{
    NSMutableDictionary* theInfo = [NSMutableDictionary dictionary];
    
    // 基本のIDと名前
    [theInfo setIntValue:mResourceID forName:@"Resource ID"];
    [theInfo setStringValue:mResourceName forName:@"Resource Name"];
    
    // 画像
    NSMutableArray* imageInfos = [NSMutableArray array];
    for (int i = 0; i < [mImages count]; i++) {
        BXChara2DImage* anImage = (BXChara2DImage*)[mImages objectAtIndex:i];
        [imageInfos addObject:[anImage imageInfo]];
    }
    [theInfo setObject:imageInfos forKey:@"Image Infos"];
    
    // 状態
    NSMutableArray* stateInfos = [NSMutableArray array];
    for (int i = 0; i < [mStates count]; i++) {
        BXChara2DState* aState = (BXChara2DState*)[mStates objectAtIndex:i];
        [stateInfos addObject:[aState stateInfo]];
    }
    [theInfo setObject:stateInfos forKey:@"State Infos"];
    
    return theInfo;
}

- (void)restoreElementInfo:(NSDictionary*)theInfo document:(BXDocument*)document
{
    // 基本のIDと名前
    mResourceID = [theInfo intValueForName:@"Resource ID" currentValue:mResourceID];
    [self setResourceName:[theInfo stringValueForName:@"Resource Name" currentValue:mResourceName]];
    
    // 画像
    NSArray* imageInfos = [theInfo objectForKey:@"Image Infos"];
    for (int i = 0; i < [imageInfos count]; i++) {
        NSDictionary* anImageInfo = [imageInfos objectAtIndex:i];
        BXChara2DImage* theImage = [[[BXChara2DImage alloc] initWithInfo:anImageInfo document:document] autorelease];
        [mImages addObject:theImage];
    }
    
    // 状態
    NSArray* stateInfos = [theInfo objectForKey:@"State Infos"];
    for (int i = 0; i < [stateInfos count]; i++) {
        NSDictionary* aStateInfo = [stateInfos objectAtIndex:i];
        BXChara2DState* theState = [[[BXChara2DState alloc] initWithName:@"New State" chara2DSpec:self] autorelease];
        [theState restoreStateInfo:aStateInfo];
        [mStates addObject:theState];
    }
}

@end

