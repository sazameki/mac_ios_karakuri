//
//  BXChara2DSpec.m
//  Karakuri Box
//
//  Created by numata on 10/02/28.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXChara2DSpec.h"
#import "NSDictionary+LoadSave.h"
#import "NSFileHandle+BXExport.h"
#import "BXResourceFileManager.h"
#import "NSImage+BXEx.h"
#import "BXDocument.h"


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
        
        mKomaPreviewScale = 1.0;
        
        mFirstStateID = -1;
        mFirstStateKomaNumber = 1;
        mRevertToFirstState = YES;
        mIgnoresCancelFlag = NO;
        mSkipEndAnimation = NO;

        mActionStateIDUp = -1;
        mActionKomaNumberUp = 1;
        mIgnoresCancelFlagUp = NO;
        mSkipEndAnimationUp = NO;
        mActionSpeedUp = 2;
        
        mActionStateIDDown = -1;
        mActionKomaNumberDown = 1;
        mIgnoresCancelFlagDown = NO;
        mSkipEndAnimationDown = NO;
        mActionSpeedDown = 2;
        
        mActionStateIDLeft = -1;
        mActionKomaNumberLeft = 1;
        mIgnoresCancelFlagLeft = NO;
        mSkipEndAnimationLeft = NO;
        mActionSpeedLeft = 2;
        
        mActionStateIDRight = -1;
        mActionKomaNumberRight = 1;
        mIgnoresCancelFlagRight = NO;
        mSkipEndAnimationRight = NO;
        mActionSpeedRight = 2;
        
        mActionStateIDZ = -1;
        mActionKomaNumberZ = 1;
        mIgnoresCancelFlagZ = NO;
        mSkipEndAnimationZ = NO;
        
        mActionStateIDX = -1;
        mActionKomaNumberX = 1;
        mIgnoresCancelFlagX = NO;
        mSkipEndAnimationX = NO;
        
        mActionStateIDC = -1;
        mActionKomaNumberC = 1;
        mIgnoresCancelFlagC = NO;
        mSkipEndAnimationC = NO;
        
        mActionStateIDMouse = -1;
        mActionKomaNumberMouse = 1;
        mIgnoresCancelFlagMouse = NO;
        mSkipEndAnimationMouse = NO;
        mDoChangeMouseLocation = YES;
        
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
#pragma mark アクセッサ

- (int)firstStateID
{
    return mFirstStateID;
}

- (void)setFirstStateID:(int)stateID
{
    mFirstStateID = stateID;
}

- (int)firstStateKomaNumber
{
    return mFirstStateKomaNumber;
}

- (void)setFirstStateKomaNumber:(int)komaNumber
{
    mFirstStateKomaNumber = komaNumber;
}

- (BOOL)revertToFirstState
{
    return mRevertToFirstState;
}

- (void)setRevertToFirstState:(BOOL)flag
{
    mRevertToFirstState = flag;
}

- (BOOL)ignoresCancelFlag
{
    return mIgnoresCancelFlag;
}

- (void)setIgnoresCancelFlag:(BOOL)flag
{
    mIgnoresCancelFlag = flag;
}

- (BOOL)skipEndAnimation
{
    return mSkipEndAnimation;
}

- (void)setSkipEndAnimation:(BOOL)flag
{
    mSkipEndAnimation = flag;
}


#pragma mark (KeyUp)

- (int)actionStateIDUp
{
    return mActionStateIDUp;
}

- (void)setActionStateIDUp:(int)stateID
{
    mActionStateIDUp = stateID;
}

- (int)actionKomaNumberUp
{
    return mActionKomaNumberUp;
}

- (void)setActionKomaNumberUp:(int)komaNumber
{
    mActionKomaNumberUp = komaNumber;
}

- (BOOL)ignoresCancelFlagUp
{
    return mIgnoresCancelFlagUp;
}

- (void)setIgnoresCancelFlagUp:(BOOL)flag
{
    mIgnoresCancelFlagUp = flag;
}

- (BOOL)skipEndAnimationUp
{
    return mSkipEndAnimationUp;
}

- (void)setSkipEndAnimationUp:(BOOL)flag
{
    mSkipEndAnimationUp = flag;
}

- (int)actionSpeedUp
{
    return mActionSpeedUp;
}

- (void)setActionSpeedUp:(int)value
{
    mActionSpeedUp = value;
}


#pragma mark (KeyDown)

- (int)actionStateIDDown
{
    return mActionStateIDDown;
}

- (void)setActionStateIDDown:(int)stateID
{
    mActionStateIDDown = stateID;
}

- (int)actionKomaNumberDown
{
    return mActionKomaNumberDown;
}

- (void)setActionKomaNumberDown:(int)komaNumber
{
    mActionKomaNumberDown = komaNumber;
}

- (BOOL)ignoresCancelFlagDown
{
    return mIgnoresCancelFlagDown;
}

- (void)setIgnoresCancelFlagDown:(BOOL)flag
{
    mIgnoresCancelFlagDown = flag;
}

- (BOOL)skipEndAnimationDown
{
    return mSkipEndAnimationDown;
}

- (void)setSkipEndAnimationDown:(BOOL)flag
{
    mSkipEndAnimationDown = flag;
}

- (int)actionSpeedDown
{
    return mActionSpeedDown;
}

- (void)setActionSpeedDown:(int)value
{
    mActionSpeedDown = value;
}


#pragma mark (KeyLeft)

- (int)actionStateIDLeft
{
    return mActionStateIDLeft;
}

- (void)setActionStateIDLeft:(int)stateID
{
    mActionStateIDLeft = stateID;
}

- (int)actionKomaNumberLeft
{
    return mActionKomaNumberLeft;
}

- (void)setActionKomaNumberLeft:(int)komaNumber
{
    mActionKomaNumberLeft = komaNumber;
}

- (BOOL)ignoresCancelFlagLeft
{
    return mIgnoresCancelFlagLeft;
}

- (void)setIgnoresCancelFlagLeft:(BOOL)flag
{
    mIgnoresCancelFlagLeft = flag;
}

- (BOOL)skipEndAnimationLeft
{
    return mSkipEndAnimationLeft;
}

- (void)setSkipEndAnimationLeft:(BOOL)flag
{
    mSkipEndAnimationLeft = flag;
}

- (int)actionSpeedLeft
{
    return mActionSpeedLeft;
}

- (void)setActionSpeedLeft:(int)value
{
    mActionSpeedLeft = value;
}


#pragma mark (KeyRight)

- (int)actionStateIDRight
{
    return mActionStateIDRight;
}

- (void)setActionStateIDRight:(int)stateID
{
    mActionStateIDRight = stateID;
}

- (int)actionKomaNumberRight
{
    return mActionKomaNumberRight;
}

- (void)setActionKomaNumberRight:(int)komaNumber
{
    mActionKomaNumberRight = komaNumber;
}

- (BOOL)ignoresCancelFlagRight
{
    return mIgnoresCancelFlagRight;
}

- (void)setIgnoresCancelFlagRight:(BOOL)flag
{
    mIgnoresCancelFlagRight = flag;
}

- (BOOL)skipEndAnimationRight
{
    return mSkipEndAnimationRight;
}

- (void)setSkipEndAnimationRight:(BOOL)flag
{
    mSkipEndAnimationRight = flag;
}

- (int)actionSpeedRight
{
    return mActionSpeedRight;
}

- (void)setActionSpeedRight:(int)value
{
    mActionSpeedRight = value;
}


#pragma mark (KeyZ)

- (int)actionStateIDZ
{
    return mActionStateIDZ;
}

- (void)setActionStateIDZ:(int)stateID
{
    mActionStateIDZ = stateID;
}

- (int)actionKomaNumberZ
{
    return mActionKomaNumberZ;
}

- (void)setActionKomaNumberZ:(int)komaNumber
{
    mActionKomaNumberZ = komaNumber;
}

- (BOOL)ignoresCancelFlagZ
{
    return mIgnoresCancelFlagZ;
}

- (void)setIgnoresCancelFlagZ:(BOOL)flag
{
    mIgnoresCancelFlagZ = flag;
}

- (BOOL)skipEndAnimationZ
{
    return mSkipEndAnimationZ;
}

- (void)setSkipEndAnimationZ:(BOOL)flag
{
    mSkipEndAnimationZ = flag;
}


#pragma mark (KeyX)

- (int)actionStateIDX
{
    return mActionStateIDX;
}

- (void)setActionStateIDX:(int)stateID
{
}

- (int)actionKomaNumberX
{
    return mActionKomaNumberX;
}

- (void)setActionKomaNumberX:(int)komaNumber
{
    mActionKomaNumberX = komaNumber;
}

- (BOOL)ignoresCancelFlagX
{
    return mIgnoresCancelFlagX;
}

- (void)setIgnoresCancelFlagX:(BOOL)flag
{
    mIgnoresCancelFlagX = flag;
}

- (BOOL)skipEndAnimationX
{
    return mSkipEndAnimationX;
}

- (void)setSkipEndAnimationX:(BOOL)flag
{
    mSkipEndAnimationX = flag;
}


#pragma mark (KeyC)

- (int)actionStateIDC
{
    return mActionStateIDC;
}

- (void)setActionStateIDC:(int)stateID
{
    mActionStateIDC = stateID;
}

- (int)actionKomaNumberC
{
    return mActionKomaNumberC;
}

- (void)setActionKomaNumberC:(int)komaNumber
{
    mActionKomaNumberC = komaNumber;
}

- (BOOL)ignoresCancelFlagC
{
    return mIgnoresCancelFlagC;
}

- (void)setIgnoresCancelFlagC:(BOOL)flag
{
    mIgnoresCancelFlagC = flag;
}

- (BOOL)skipEndAnimationC
{
    return mSkipEndAnimationC;
}

- (void)setSkipEndAnimationC:(BOOL)flag
{
    mSkipEndAnimationC = flag;
}

#pragma mark (Mouse)

- (int)actionStateIDMouse
{
    return mActionStateIDMouse;
}

- (void)setActionStateIDMouse:(int)stateID
{
    mActionStateIDMouse = stateID;
}

- (int)actionKomaNumberMouse
{
    return mActionKomaNumberMouse;
}

- (void)setActionKomaNumberMouse:(int)komaNumber
{
    mActionKomaNumberMouse = komaNumber;
}

- (BOOL)ignoresCancelFlagMouse
{
    return mIgnoresCancelFlagMouse;
}

- (void)setIgnoresCancelFlagMouse:(BOOL)flag
{
    mIgnoresCancelFlagMouse = flag;
}

- (BOOL)skipEndAnimationMouse
{
    return mSkipEndAnimationMouse;
}

- (void)setSkipEndAnimationMouse:(BOOL)flag
{
    mSkipEndAnimationMouse = flag;
}

- (BOOL)doChangeMouseLocation
{
    return mDoChangeMouseLocation;
}

- (void)setDoChangeMouseLocation:(BOOL)flag
{
    mDoChangeMouseLocation = flag;
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

- (BXChara2DState*)stateWithID:(int)stateID
{
    for (int i = 0; i < [mStates count]; i++) {
        BXChara2DState* aState = [mStates objectAtIndex:i];
        if ([aState stateID] == stateID) {
            return aState;
        }
    }
    return nil;
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

- (double)komaPreviewScale
{
    return mKomaPreviewScale;
}

- (void)setKomaPreviewScale:(double)value
{
    mKomaPreviewScale = value;
}

- (void)preparePreviewTextures
{
    for (int i = 0; i < [mStates count]; i++) {
        BXChara2DState* aState = (BXChara2DState*)[mStates objectAtIndex:i];
        [aState preparePreviewTextures];
    }
}


#pragma mark -
#pragma mark シリアライゼーションのサポート

- (NSDictionary*)elementInfo
{
    NSMutableDictionary* theInfo = [NSMutableDictionary dictionary];
    
    // 基本のIDと名前
    [theInfo setIntValue:mGroupID forName:@"Group ID"];
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
    
    // コマプレビューのスケール
    [theInfo setDoubleValue:mKomaPreviewScale forName:@"Preview Scale"];
    
    // シミュレーション用の設定
    [theInfo setIntValue:mFirstStateID forName:@"SIM First State ID"];
    [theInfo setIntValue:mFirstStateKomaNumber forName:@"SIM First Koma Number"];
    [theInfo setBoolValue:mRevertToFirstState forName:@"SIM Revert To First State"];
    [theInfo setBoolValue:mIgnoresCancelFlag forName:@"SIM Ignores Cancel Flag"];
    [theInfo setBoolValue:mSkipEndAnimation forName:@"SIM Skip End Animation"];
    
    [theInfo setIntValue:mActionStateIDUp forName:@"SIM Action State ID Up"];
    [theInfo setIntValue:mActionKomaNumberUp forName:@"SIM Action Koma Number Up"];
    [theInfo setBoolValue:mIgnoresCancelFlagUp forName:@"SIM Action Ignores Cancel Flag Up"];
    [theInfo setBoolValue:mSkipEndAnimationUp forName:@"SIM Action Skip End Animation Up"];
    [theInfo setIntValue:mActionSpeedUp forName:@"SIM Action Speed Up"];
    
    [theInfo setIntValue:mActionStateIDDown forName:@"SIM Action State ID Down"];
    [theInfo setIntValue:mActionKomaNumberDown forName:@"SIM Action Koma Number Down"];
    [theInfo setBoolValue:mIgnoresCancelFlagDown forName:@"SIM Action Ignores Cancel Flag Down"];
    [theInfo setBoolValue:mSkipEndAnimationDown forName:@"SIM Action Skip End Animation Down"];
    [theInfo setIntValue:mActionSpeedDown forName:@"SIM Action Speed Down"];
    
    [theInfo setIntValue:mActionStateIDLeft forName:@"SIM Action State ID Left"];
    [theInfo setIntValue:mActionKomaNumberLeft forName:@"SIM Action Koma Number Left"];
    [theInfo setBoolValue:mIgnoresCancelFlagLeft forName:@"SIM Action Ignores Cancel Flag Left"];
    [theInfo setBoolValue:mSkipEndAnimationLeft forName:@"SIM Action Skip End Animation Left"];
    [theInfo setIntValue:mActionSpeedLeft forName:@"SIM Action Speed Left"];
    
    [theInfo setIntValue:mActionStateIDRight forName:@"SIM Action State ID Right"];
    [theInfo setIntValue:mActionKomaNumberRight forName:@"SIM Action Koma Number Right"];
    [theInfo setBoolValue:mIgnoresCancelFlagRight forName:@"SIM Action Ignores Cancel Flag Right"];
    [theInfo setBoolValue:mSkipEndAnimationRight forName:@"SIM Action Skip End Animation Right"];
    [theInfo setIntValue:mActionSpeedRight forName:@"SIM Action Speed Right"];
    
    [theInfo setIntValue:mActionStateIDZ forName:@"SIM Action State ID Z"];
    [theInfo setIntValue:mActionKomaNumberZ forName:@"SIM Action Koma Number Z"];
    [theInfo setBoolValue:mIgnoresCancelFlagZ forName:@"SIM Action Ignores Cancel Flag Z"];
    [theInfo setBoolValue:mSkipEndAnimationZ forName:@"SIM Action Skip End Animation Z"];
    
    [theInfo setIntValue:mActionStateIDX forName:@"SIM Action State ID X"];
    [theInfo setIntValue:mActionKomaNumberX forName:@"SIM Action Koma Number X"];
    [theInfo setBoolValue:mIgnoresCancelFlagX forName:@"SIM Action Ignores Cancel Flag X"];
    [theInfo setBoolValue:mSkipEndAnimationX forName:@"SIM Action Skip End Animation X"];
    
    [theInfo setIntValue:mActionStateIDC forName:@"SIM Action State ID C"];
    [theInfo setIntValue:mActionKomaNumberC forName:@"SIM Action Koma Number C"];
    [theInfo setBoolValue:mIgnoresCancelFlagC forName:@"SIM Action Ignores Cancel Flag C"];
    [theInfo setBoolValue:mSkipEndAnimationC forName:@"SIM Action Skip End Animation C"];
    
    [theInfo setIntValue:mActionStateIDMouse forName:@"SIM Action State ID Mouse"];
    [theInfo setIntValue:mActionKomaNumberMouse forName:@"SIM Action Koma Number Mouse"];
    [theInfo setBoolValue:mIgnoresCancelFlagMouse forName:@"SIM Action Ignores Cancel Flag Mouse"];
    [theInfo setBoolValue:mSkipEndAnimationMouse forName:@"SIM Action Skip End Animation Mouse"];
    [theInfo setBoolValue:mDoChangeMouseLocation forName:@"SIM Do Change Mouse Location"];
    
    return theInfo;
}

- (void)restoreElementInfo:(NSDictionary*)theInfo document:(BXDocument*)document
{
    // 基本のIDと名前
    mGroupID = [theInfo intValueForName:@"Group ID" currentValue:mResourceID];
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

    // コマプレビューのスケール
    mKomaPreviewScale = [theInfo doubleValueForName:@"Preview Scale" currentValue:mKomaPreviewScale];
    
    // シミュレーション用の設定
    mFirstStateID = [theInfo intValueForName:@"SIM First State ID" currentValue:mFirstStateID];
    mFirstStateKomaNumber = [theInfo intValueForName:@"SIM First Koma Number" currentValue:mFirstStateKomaNumber];
    mRevertToFirstState = [theInfo boolValueForName:@"SIM Revert To First State" currentValue:mRevertToFirstState];
    mIgnoresCancelFlag = [theInfo boolValueForName:@"SIM Ignores Cancel Flag" currentValue:mIgnoresCancelFlag];
    mSkipEndAnimation = [theInfo boolValueForName:@"SIM Skip End Animation" currentValue:mSkipEndAnimation];
    
    mActionStateIDUp = [theInfo intValueForName:@"SIM Action State ID Up" currentValue:mActionStateIDUp];
    mActionKomaNumberUp = [theInfo intValueForName:@"SIM Action Koma Number Up" currentValue:mActionKomaNumberUp];
    mIgnoresCancelFlagUp = [theInfo boolValueForName:@"SIM Action Ignores Cancel Flag Up" currentValue:mIgnoresCancelFlagUp];
    mSkipEndAnimationUp = [theInfo boolValueForName:@"SIM Action Skip End Animation Up" currentValue:mSkipEndAnimationUp];
    mActionSpeedUp = [theInfo intValueForName:@"SIM Action Speed Up" currentValue:mActionSpeedUp];
    
    mActionStateIDDown = [theInfo intValueForName:@"SIM Action State ID Down" currentValue:mActionStateIDDown];
    mActionKomaNumberDown = [theInfo intValueForName:@"SIM Action Koma Number Down" currentValue:mActionKomaNumberDown];
    mIgnoresCancelFlagDown = [theInfo boolValueForName:@"SIM Action Ignores Cancel Flag Down" currentValue:mIgnoresCancelFlagDown];
    mSkipEndAnimationDown = [theInfo boolValueForName:@"SIM Action Skip End Animation Down" currentValue:mSkipEndAnimationDown];
    mActionSpeedDown = [theInfo intValueForName:@"SIM Action Speed Down" currentValue:mActionSpeedDown];
    
    mActionStateIDLeft = [theInfo intValueForName:@"SIM Action State ID Left" currentValue:mActionStateIDLeft];
    mActionKomaNumberLeft = [theInfo intValueForName:@"SIM Action Koma Number Left" currentValue:mActionKomaNumberLeft];
    mIgnoresCancelFlagLeft = [theInfo boolValueForName:@"SIM Action Ignores Cancel Flag Left" currentValue:mIgnoresCancelFlagLeft];
    mSkipEndAnimationLeft = [theInfo boolValueForName:@"SIM Action Skip End Animation Left" currentValue:mSkipEndAnimationLeft];
    mActionSpeedLeft = [theInfo intValueForName:@"SIM Action Speed Left" currentValue:mActionSpeedLeft];
    
    mActionStateIDRight = [theInfo intValueForName:@"SIM Action State ID Right" currentValue:mActionStateIDRight];
    mActionKomaNumberRight = [theInfo intValueForName:@"SIM Action Koma Number Right" currentValue:mActionKomaNumberRight];
    mIgnoresCancelFlagRight = [theInfo boolValueForName:@"SIM Action Ignores Cancel Flag Right" currentValue:mIgnoresCancelFlagRight];
    mSkipEndAnimationRight = [theInfo boolValueForName:@"SIM Action Skip End Animation Right" currentValue:mSkipEndAnimationRight];
    mActionSpeedRight = [theInfo intValueForName:@"SIM Action Speed Right" currentValue:mActionSpeedRight];
    
    mActionStateIDZ = [theInfo intValueForName:@"SIM Action State ID Z" currentValue:mActionStateIDZ];
    mActionKomaNumberZ = [theInfo intValueForName:@"SIM Action Koma Number Z" currentValue:mActionKomaNumberZ];
    mIgnoresCancelFlagZ = [theInfo boolValueForName:@"SIM Action Ignores Cancel Flag Z" currentValue:mIgnoresCancelFlagZ];
    mSkipEndAnimationZ = [theInfo boolValueForName:@"SIM Action Skip End Animation Z" currentValue:mSkipEndAnimationZ];
    
    mActionStateIDX = [theInfo intValueForName:@"SIM Action State ID X" currentValue:mActionStateIDX];
    mActionKomaNumberX = [theInfo intValueForName:@"SIM Action Koma Number X" currentValue:mActionKomaNumberX];
    mIgnoresCancelFlagX = [theInfo boolValueForName:@"SIM Action Ignores Cancel Flag X" currentValue:mIgnoresCancelFlagX];
    mSkipEndAnimationX = [theInfo boolValueForName:@"SIM Action Skip End Animation X" currentValue:mSkipEndAnimationX];
    
    mActionStateIDC = [theInfo intValueForName:@"SIM Action State ID C" currentValue:mActionStateIDC];
    mActionKomaNumberC = [theInfo intValueForName:@"SIM Action Koma Number C" currentValue:mActionKomaNumberC];
    mIgnoresCancelFlagC = [theInfo boolValueForName:@"SIM Action Ignores Cancel Flag C" currentValue:mIgnoresCancelFlagC];
    mSkipEndAnimationC = [theInfo boolValueForName:@"SIM Action Skip End Animation C" currentValue:mSkipEndAnimationC];
    
    mActionStateIDMouse = [theInfo intValueForName:@"SIM Action State ID Mouse" currentValue:mActionStateIDMouse];
    mActionKomaNumberMouse = [theInfo intValueForName:@"SIM Action Koma Number Mouse" currentValue:mActionKomaNumberMouse];
    mIgnoresCancelFlagMouse = [theInfo boolValueForName:@"SIM Action Ignores Cancel Flag Mouse" currentValue:mIgnoresCancelFlagMouse];
    mSkipEndAnimationMouse = [theInfo boolValueForName:@"SIM Action Skip End Animation Mouse" currentValue:mSkipEndAnimationMouse];
    mDoChangeMouseLocation = [theInfo boolValueForName:@"SIM Do Change Mouse Location" currentValue:mDoChangeMouseLocation];
}

@end


@implementation BXChara2DSpec (Export)

- (void)exportToFileHandle:(NSFileHandle*)fileHandle
{
    // ヘッダの書き出し
    [fileHandle writeBuffer:"KRC2" length:4];
    
    // リソース情報の書き出し
    NSDictionary* elementInfo = [self elementInfo];
    NSString* errorStr = nil;
    NSData* infoData = [NSPropertyListSerialization dataFromPropertyList:elementInfo
                                                                  format:NSPropertyListBinaryFormat_v1_0
                                                        errorDescription:&errorStr];
    [fileHandle writeUnsignedIntValue:[infoData length]];
    [fileHandle writeData:infoData];
    
    // リソースの書き出し
    for (int i = 0; i < [mImages count]; i++) {
        BXChara2DImage* anImage = (BXChara2DImage*)[mImages objectAtIndex:i];
        NSString* imageTicket = [anImage imageTicket];
        
        BXResourceFileManager* fileManager = [[self document] fileManager];
        NSImage* image = [fileManager image72dpiForTicket:imageTicket];
        NSData* pngData = [image pngData];
        
        NSMutableDictionary* texInfo = [NSMutableDictionary dictionary];
        [texInfo setIntValue:mGroupID forName:@"Group ID"];
        [texInfo setObject:imageTicket forKey:@"Ticket"];
        [texInfo setObject:[fileManager resourceNameForTicket:imageTicket] forKey:@"Resource Name"];
        NSData* texInfoData = [NSPropertyListSerialization dataFromPropertyList:texInfo
                                                                         format:NSPropertyListBinaryFormat_v1_0
                                                               errorDescription:&errorStr];
        
        // ヘッダ
        [fileHandle writeBuffer:"KRT2" length:4];
        [fileHandle writeUnsignedIntValue:[texInfoData length]];
        [fileHandle writeData:texInfoData];
        
        // データ
        [fileHandle writeBuffer:"KRDT" length:4];
        [fileHandle writeUnsignedIntValue:[pngData length]];
        [fileHandle writeData:pngData];
    }
}

@end





