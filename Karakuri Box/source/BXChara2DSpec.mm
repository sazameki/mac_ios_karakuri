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

- (void)addDefaultMotion;

@end


@implementation BXChara2DSpec

#pragma mark -
#pragma mark 初期化・クリーンアップ

- (id)initWithName:(NSString*)name defaultMotion:(BOOL)hasDefaultMotion
{
    self = [super initWithName:name];
    if (self) {
        mMotions = [[NSMutableArray alloc] init];
        
        mKomaPreviewScale = 1.0;
        
        mFirstMotionID = -1;
        mFirstMotionKomaNumber = 1;
        mRevertToFirstMotion = YES;
        mIgnoresCancelFlag = NO;
        mSkipEndAnimation = NO;

        mActionMotionIDUp = -1;
        mActionKomaNumberUp = 1;
        mIgnoresCancelFlagUp = NO;
        mSkipEndAnimationUp = NO;
        mActionSpeedUp = 2;
        
        mActionMotionIDDown = -1;
        mActionKomaNumberDown = 1;
        mIgnoresCancelFlagDown = NO;
        mSkipEndAnimationDown = NO;
        mActionSpeedDown = 2;
        
        mActionMotionIDLeft = -1;
        mActionKomaNumberLeft = 1;
        mIgnoresCancelFlagLeft = NO;
        mSkipEndAnimationLeft = NO;
        mActionSpeedLeft = 2;
        
        mActionMotionIDRight = -1;
        mActionKomaNumberRight = 1;
        mIgnoresCancelFlagRight = NO;
        mSkipEndAnimationRight = NO;
        mActionSpeedRight = 2;
        
        mActionMotionIDZ = -1;
        mActionKomaNumberZ = 1;
        mIgnoresCancelFlagZ = NO;
        mSkipEndAnimationZ = NO;
        
        mActionMotionIDX = -1;
        mActionKomaNumberX = 1;
        mIgnoresCancelFlagX = NO;
        mSkipEndAnimationX = NO;
        
        mActionMotionIDC = -1;
        mActionKomaNumberC = 1;
        mIgnoresCancelFlagC = NO;
        mSkipEndAnimationC = NO;
        
        mActionMotionIDMouse = -1;
        mActionKomaNumberMouse = 1;
        mIgnoresCancelFlagMouse = NO;
        mSkipEndAnimationMouse = NO;
        mDoChangeMouseLocation = YES;
        
        if (hasDefaultMotion) {
            [self addDefaultMotion];
        }
    }
    return self;
}

- (void)dealloc
{
    [mMotions release];

    [super dealloc];
}


#pragma mark -
#pragma mark アクセッサ

- (int)firstMotionID
{
    return mFirstMotionID;
}

- (void)setFirstMotionID:(int)motionID
{
    mFirstMotionID = motionID;
}

- (int)firstMotionKomaNumber
{
    return mFirstMotionKomaNumber;
}

- (void)setFirstMotionKomaNumber:(int)komaNumber
{
    mFirstMotionKomaNumber = komaNumber;
}

- (BOOL)revertToFirstMotion
{
    return mRevertToFirstMotion;
}

- (void)setRevertToFirstMotion:(BOOL)flag
{
    mRevertToFirstMotion = flag;
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

- (int)actionMotionIDUp
{
    return mActionMotionIDUp;
}

- (void)setActionMotionIDUp:(int)motionID
{
    mActionMotionIDUp = motionID;
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

- (int)actionMotionIDDown
{
    return mActionMotionIDDown;
}

- (void)setActionMotionIDDown:(int)motionID
{
    mActionMotionIDDown = motionID;
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

- (int)actionMotionIDLeft
{
    return mActionMotionIDLeft;
}

- (void)setActionMotionIDLeft:(int)motionID
{
    mActionMotionIDLeft = motionID;
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

- (int)actionMotionIDRight
{
    return mActionMotionIDRight;
}

- (void)setActionMotionIDRight:(int)motionID
{
    mActionMotionIDRight = motionID;
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

- (int)actionMotionIDZ
{
    return mActionMotionIDZ;
}

- (void)setActionMotionIDZ:(int)motionID
{
    mActionMotionIDZ = motionID;
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

- (int)actionMotionIDX
{
    return mActionMotionIDX;
}

- (void)setActionMotionIDX:(int)motionID
{
    mActionMotionIDX = motionID;
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

- (int)actionMotionIDC
{
    return mActionMotionIDC;
}

- (void)setActionMotionIDC:(int)motionID
{
    mActionMotionIDC = motionID;
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

- (int)actionMotionIDMouse
{
    return mActionMotionIDMouse;
}

- (void)setActionMotionIDMouse:(int)motionID
{
    mActionMotionIDMouse = motionID;
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

- (void)addDefaultMotion
{
    BXChara2DMotion* theMotion = [self addNewMotion];
    [theMotion setMotionName:@"Default"];
}

- (BXChara2DMotion*)addNewMotion
{
    BXChara2DMotion* newMotion = [[[BXChara2DMotion alloc] initWithName:@"Motion" chara2DSpec:self] autorelease];
    
    [mMotions addObject:newMotion];
    
    return newMotion;
}

- (int)motionCount
{
    return [mMotions count];
}

- (BXChara2DMotion*)motionAtIndex:(int)index
{
    return [mMotions objectAtIndex:index];
}

- (BXChara2DMotion*)motionWithID:(int)motionID
{
    for (int i = 0; i < [mMotions count]; i++) {
        BXChara2DMotion* aMotion = [mMotions objectAtIndex:i];
        if ([aMotion motionID] == motionID) {
            return aMotion;
        }
    }
    return nil;
}

- (void)removeMotion:(BXChara2DMotion*)theMotion
{
    [mMotions removeObject:theMotion];
}

- (void)sortMotionList
{
    NSSortDescriptor* sortDesc = [[[NSSortDescriptor alloc] initWithKey:@"stateID"
                                                              ascending:YES] autorelease];
    
    [mMotions sortUsingDescriptors:[NSArray arrayWithObject:sortDesc]];    
}

- (void)changeMotionIDInAllKomaFrom:(int)oldMotionID to:(int)newMotionID
{
    for (int i = 0; i < [mMotions count]; i++) {
        BXChara2DMotion* aMotion = (BXChara2DMotion*)[mMotions objectAtIndex:i];
        [aMotion changeMotionIDInAllKomaFrom:oldMotionID to:newMotionID];
    }    
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
    for (int i = 0; i < [mMotions count]; i++) {
        BXChara2DMotion* aMotion = (BXChara2DMotion*)[mMotions objectAtIndex:i];
        [aMotion preparePreviewTextures];
    }
}


#pragma mark -
#pragma mark シリアライゼーションのサポート

- (NSDictionary*)elementInfo
{
    NSMutableDictionary* theInfo = [NSMutableDictionary dictionary];
    
    // 基本のIDと名前
    [theInfo setStringValue:mResourceUUID forName:@"Resource UUID"];
    [theInfo setIntValue:mGroupID forName:@"Group ID"];
    [theInfo setIntValue:mResourceID forName:@"Resource ID"];
    [theInfo setStringValue:mResourceName forName:@"Resource Name"];
    
    // 動作
    NSMutableArray* motionInfos = [NSMutableArray array];
    for (int i = 0; i < [mMotions count]; i++) {
        BXChara2DMotion* aMotion = (BXChara2DMotion*)[mMotions objectAtIndex:i];
        [motionInfos addObject:[aMotion motionInfo]];
    }
    [theInfo setObject:motionInfos forKey:@"State Infos"];
    
    // コマプレビューのスケール
    [theInfo setDoubleValue:mKomaPreviewScale forName:@"Preview Scale"];
    
    // シミュレーション用の設定
    [theInfo setIntValue:mFirstMotionID forName:@"SIM First State ID"];
    [theInfo setIntValue:mFirstMotionKomaNumber forName:@"SIM First Koma Number"];
    [theInfo setBoolValue:mRevertToFirstMotion forName:@"SIM Revert To First State"];
    [theInfo setBoolValue:mIgnoresCancelFlag forName:@"SIM Ignores Cancel Flag"];
    [theInfo setBoolValue:mSkipEndAnimation forName:@"SIM Skip End Animation"];
    
    [theInfo setIntValue:mActionMotionIDUp forName:@"SIM Action State ID Up"];
    [theInfo setIntValue:mActionKomaNumberUp forName:@"SIM Action Koma Number Up"];
    [theInfo setBoolValue:mIgnoresCancelFlagUp forName:@"SIM Action Ignores Cancel Flag Up"];
    [theInfo setBoolValue:mSkipEndAnimationUp forName:@"SIM Action Skip End Animation Up"];
    [theInfo setIntValue:mActionSpeedUp forName:@"SIM Action Speed Up"];
    
    [theInfo setIntValue:mActionMotionIDDown forName:@"SIM Action State ID Down"];
    [theInfo setIntValue:mActionKomaNumberDown forName:@"SIM Action Koma Number Down"];
    [theInfo setBoolValue:mIgnoresCancelFlagDown forName:@"SIM Action Ignores Cancel Flag Down"];
    [theInfo setBoolValue:mSkipEndAnimationDown forName:@"SIM Action Skip End Animation Down"];
    [theInfo setIntValue:mActionSpeedDown forName:@"SIM Action Speed Down"];
    
    [theInfo setIntValue:mActionMotionIDLeft forName:@"SIM Action State ID Left"];
    [theInfo setIntValue:mActionKomaNumberLeft forName:@"SIM Action Koma Number Left"];
    [theInfo setBoolValue:mIgnoresCancelFlagLeft forName:@"SIM Action Ignores Cancel Flag Left"];
    [theInfo setBoolValue:mSkipEndAnimationLeft forName:@"SIM Action Skip End Animation Left"];
    [theInfo setIntValue:mActionSpeedLeft forName:@"SIM Action Speed Left"];
    
    [theInfo setIntValue:mActionMotionIDRight forName:@"SIM Action State ID Right"];
    [theInfo setIntValue:mActionKomaNumberRight forName:@"SIM Action Koma Number Right"];
    [theInfo setBoolValue:mIgnoresCancelFlagRight forName:@"SIM Action Ignores Cancel Flag Right"];
    [theInfo setBoolValue:mSkipEndAnimationRight forName:@"SIM Action Skip End Animation Right"];
    [theInfo setIntValue:mActionSpeedRight forName:@"SIM Action Speed Right"];
    
    [theInfo setIntValue:mActionMotionIDZ forName:@"SIM Action Motion ID Z"];
    [theInfo setIntValue:mActionKomaNumberZ forName:@"SIM Action Koma Number Z"];
    [theInfo setBoolValue:mIgnoresCancelFlagZ forName:@"SIM Action Ignores Cancel Flag Z"];
    [theInfo setBoolValue:mSkipEndAnimationZ forName:@"SIM Action Skip End Animation Z"];
    
    [theInfo setIntValue:mActionMotionIDX forName:@"SIM Action State ID X"];
    [theInfo setIntValue:mActionKomaNumberX forName:@"SIM Action Koma Number X"];
    [theInfo setBoolValue:mIgnoresCancelFlagX forName:@"SIM Action Ignores Cancel Flag X"];
    [theInfo setBoolValue:mSkipEndAnimationX forName:@"SIM Action Skip End Animation X"];
    
    [theInfo setIntValue:mActionMotionIDC forName:@"SIM Action State ID C"];
    [theInfo setIntValue:mActionKomaNumberC forName:@"SIM Action Koma Number C"];
    [theInfo setBoolValue:mIgnoresCancelFlagC forName:@"SIM Action Ignores Cancel Flag C"];
    [theInfo setBoolValue:mSkipEndAnimationC forName:@"SIM Action Skip End Animation C"];
    
    [theInfo setIntValue:mActionMotionIDMouse forName:@"SIM Action State ID Mouse"];
    [theInfo setIntValue:mActionKomaNumberMouse forName:@"SIM Action Koma Number Mouse"];
    [theInfo setBoolValue:mIgnoresCancelFlagMouse forName:@"SIM Action Ignores Cancel Flag Mouse"];
    [theInfo setBoolValue:mSkipEndAnimationMouse forName:@"SIM Action Skip End Animation Mouse"];
    [theInfo setBoolValue:mDoChangeMouseLocation forName:@"SIM Do Change Mouse Location"];
    
    return theInfo;
}

- (void)restoreElementInfo:(NSDictionary*)theInfo document:(BXDocument*)document
{
    // 基本のIDと名前
    [mResourceUUID release];
    mResourceUUID = [[theInfo stringValueForName:@"Resource UUID" currentValue:mResourceUUID] retain];
    mGroupID = [theInfo intValueForName:@"Group ID" currentValue:mResourceID];
    mResourceID = [theInfo intValueForName:@"Resource ID" currentValue:mResourceID];
    [self setResourceName:[theInfo stringValueForName:@"Resource Name" currentValue:mResourceName]];    
    
    // 動作
    NSArray* motionInfos = [theInfo objectForKey:@"State Infos"];
    for (int i = 0; i < [motionInfos count]; i++) {
        NSDictionary* aMotionInfo = [motionInfos objectAtIndex:i];
        BXChara2DMotion* theMotion = [[[BXChara2DMotion alloc] initWithName:@"New Motion" chara2DSpec:self] autorelease];
        [theMotion restoreMotionInfo:aMotionInfo];
        [mMotions addObject:theMotion];
    }

    // コマプレビューのスケール
    mKomaPreviewScale = [theInfo doubleValueForName:@"Preview Scale" currentValue:mKomaPreviewScale];
    
    // シミュレーション用の設定
    mFirstMotionID = [theInfo intValueForName:@"SIM First State ID" currentValue:mFirstMotionID];
    mFirstMotionKomaNumber = [theInfo intValueForName:@"SIM First Koma Number" currentValue:mFirstMotionKomaNumber];
    mRevertToFirstMotion = [theInfo boolValueForName:@"SIM Revert To First State" currentValue:mRevertToFirstMotion];
    mIgnoresCancelFlag = [theInfo boolValueForName:@"SIM Ignores Cancel Flag" currentValue:mIgnoresCancelFlag];
    mSkipEndAnimation = [theInfo boolValueForName:@"SIM Skip End Animation" currentValue:mSkipEndAnimation];
    
    mActionMotionIDUp = [theInfo intValueForName:@"SIM Action State ID Up" currentValue:mActionMotionIDUp];
    mActionKomaNumberUp = [theInfo intValueForName:@"SIM Action Koma Number Up" currentValue:mActionKomaNumberUp];
    mIgnoresCancelFlagUp = [theInfo boolValueForName:@"SIM Action Ignores Cancel Flag Up" currentValue:mIgnoresCancelFlagUp];
    mSkipEndAnimationUp = [theInfo boolValueForName:@"SIM Action Skip End Animation Up" currentValue:mSkipEndAnimationUp];
    mActionSpeedUp = [theInfo intValueForName:@"SIM Action Speed Up" currentValue:mActionSpeedUp];
    
    mActionMotionIDDown = [theInfo intValueForName:@"SIM Action State ID Down" currentValue:mActionMotionIDDown];
    mActionKomaNumberDown = [theInfo intValueForName:@"SIM Action Koma Number Down" currentValue:mActionKomaNumberDown];
    mIgnoresCancelFlagDown = [theInfo boolValueForName:@"SIM Action Ignores Cancel Flag Down" currentValue:mIgnoresCancelFlagDown];
    mSkipEndAnimationDown = [theInfo boolValueForName:@"SIM Action Skip End Animation Down" currentValue:mSkipEndAnimationDown];
    mActionSpeedDown = [theInfo intValueForName:@"SIM Action Speed Down" currentValue:mActionSpeedDown];
    
    mActionMotionIDLeft = [theInfo intValueForName:@"SIM Action State ID Left" currentValue:mActionMotionIDLeft];
    mActionKomaNumberLeft = [theInfo intValueForName:@"SIM Action Koma Number Left" currentValue:mActionKomaNumberLeft];
    mIgnoresCancelFlagLeft = [theInfo boolValueForName:@"SIM Action Ignores Cancel Flag Left" currentValue:mIgnoresCancelFlagLeft];
    mSkipEndAnimationLeft = [theInfo boolValueForName:@"SIM Action Skip End Animation Left" currentValue:mSkipEndAnimationLeft];
    mActionSpeedLeft = [theInfo intValueForName:@"SIM Action Speed Left" currentValue:mActionSpeedLeft];
    
    mActionMotionIDRight = [theInfo intValueForName:@"SIM Action State ID Right" currentValue:mActionMotionIDRight];
    mActionKomaNumberRight = [theInfo intValueForName:@"SIM Action Koma Number Right" currentValue:mActionKomaNumberRight];
    mIgnoresCancelFlagRight = [theInfo boolValueForName:@"SIM Action Ignores Cancel Flag Right" currentValue:mIgnoresCancelFlagRight];
    mSkipEndAnimationRight = [theInfo boolValueForName:@"SIM Action Skip End Animation Right" currentValue:mSkipEndAnimationRight];
    mActionSpeedRight = [theInfo intValueForName:@"SIM Action Speed Right" currentValue:mActionSpeedRight];
    
    mActionMotionIDZ = [theInfo intValueForName:@"SIM Action State ID Z" currentValue:mActionMotionIDZ];
    mActionKomaNumberZ = [theInfo intValueForName:@"SIM Action Koma Number Z" currentValue:mActionKomaNumberZ];
    mIgnoresCancelFlagZ = [theInfo boolValueForName:@"SIM Action Ignores Cancel Flag Z" currentValue:mIgnoresCancelFlagZ];
    mSkipEndAnimationZ = [theInfo boolValueForName:@"SIM Action Skip End Animation Z" currentValue:mSkipEndAnimationZ];
    
    mActionMotionIDX = [theInfo intValueForName:@"SIM Action State ID X" currentValue:mActionMotionIDX];
    mActionKomaNumberX = [theInfo intValueForName:@"SIM Action Koma Number X" currentValue:mActionKomaNumberX];
    mIgnoresCancelFlagX = [theInfo boolValueForName:@"SIM Action Ignores Cancel Flag X" currentValue:mIgnoresCancelFlagX];
    mSkipEndAnimationX = [theInfo boolValueForName:@"SIM Action Skip End Animation X" currentValue:mSkipEndAnimationX];
    
    mActionMotionIDC = [theInfo intValueForName:@"SIM Action State ID C" currentValue:mActionMotionIDC];
    mActionKomaNumberC = [theInfo intValueForName:@"SIM Action Koma Number C" currentValue:mActionKomaNumberC];
    mIgnoresCancelFlagC = [theInfo boolValueForName:@"SIM Action Ignores Cancel Flag C" currentValue:mIgnoresCancelFlagC];
    mSkipEndAnimationC = [theInfo boolValueForName:@"SIM Action Skip End Animation C" currentValue:mSkipEndAnimationC];
    
    mActionMotionIDMouse = [theInfo intValueForName:@"SIM Action State ID Mouse" currentValue:mActionMotionIDMouse];
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
}

@end





