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
        mFirstMotionKomaIndex = 0;
        mRevertToFirstMotion = YES;
        mIgnoresCancelFlag = NO;
        mSkipEndAnimation = NO;

        mActionMotionIDUp = -1;
        mActionKomaIndexUp = 0;
        mIgnoresCancelFlagUp = NO;
        mSkipEndAnimationUp = NO;
        mActionSpeedUp = 2;
        
        mActionMotionIDDown = -1;
        mActionKomaIndexDown = 0;
        mIgnoresCancelFlagDown = NO;
        mSkipEndAnimationDown = NO;
        mActionSpeedDown = 2;
        
        mActionMotionIDLeft = -1;
        mActionKomaIndexLeft = 0;
        mIgnoresCancelFlagLeft = NO;
        mSkipEndAnimationLeft = NO;
        mActionSpeedLeft = 2;
        
        mActionMotionIDRight = -1;
        mActionKomaIndexRight = 0;
        mIgnoresCancelFlagRight = NO;
        mSkipEndAnimationRight = NO;
        mActionSpeedRight = 2;
        
        mActionMotionIDZ = -1;
        mActionKomaIndexZ = 0;
        mIgnoresCancelFlagZ = NO;
        mSkipEndAnimationZ = NO;
        
        mActionMotionIDX = -1;
        mActionKomaIndexX = 0;
        mIgnoresCancelFlagX = NO;
        mSkipEndAnimationX = NO;
        
        mActionMotionIDC = -1;
        mActionKomaIndexC = 0;
        mIgnoresCancelFlagC = NO;
        mSkipEndAnimationC = NO;
        
        mActionMotionIDMouse = -1;
        mActionKomaIndexMouse = 0;
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
    [mSelectingTextureUUID release];

    [super dealloc];
}


#pragma mark -
#pragma mark アクセッサ

- (NSString*)selectingTextureUUID;
{
    return mSelectingTextureUUID;
}

- (void)setSelectingTextureUUID:(NSString*)textureUUID
{
    [mSelectingTextureUUID release];
    mSelectingTextureUUID = nil;
    if (textureUUID) {
        mSelectingTextureUUID = [textureUUID copy];
    }
}

- (int)firstMotionID
{
    return mFirstMotionID;
}

- (void)setFirstMotionID:(int)motionID
{
    mFirstMotionID = motionID;
}

- (int)firstMotionKomaIndex
{
    return mFirstMotionKomaIndex;
}

- (void)setFirstMotionKomaIndex:(int)komaIndex
{
    mFirstMotionKomaIndex = komaIndex;
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

- (int)actionKomaIndexUp
{
    return mActionKomaIndexUp;
}

- (void)setActionKomaIndexUp:(int)komaIndex
{
    mActionKomaIndexUp = komaIndex;
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

- (int)actionKomaIndexDown
{
    return mActionKomaIndexDown;
}

- (void)setActionKomaIndexDown:(int)komaIndex
{
    mActionKomaIndexDown = komaIndex;
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

- (int)actionKomaIndexLeft
{
    return mActionKomaIndexLeft;
}

- (void)setActionKomaIndexLeft:(int)komaIndex
{
    mActionKomaIndexLeft = komaIndex;
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

- (int)actionKomaIndexRight
{
    return mActionKomaIndexRight;
}

- (void)setActionKomaIndexRight:(int)komaIndex
{
    mActionKomaIndexRight = komaIndex;
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

- (int)actionKomaIndexZ
{
    return mActionKomaIndexZ;
}

- (void)setActionKomaIndexZ:(int)komaIndex
{
    mActionKomaIndexZ = komaIndex;
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

- (int)actionKomaIndexX
{
    return mActionKomaIndexX;
}

- (void)setActionKomaIndexX:(int)komaIndex
{
    mActionKomaIndexX = komaIndex;
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

- (int)actionKomaIndexC
{
    return mActionKomaIndexC;
}

- (void)setActionKomaIndexC:(int)komaIndex
{
    mActionKomaIndexC = komaIndex;
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

- (int)actionKomaIndexMouse
{
    return mActionKomaIndexMouse;
}

- (void)setActionKomaIndexMouse:(int)komaIndex
{
    mActionKomaIndexMouse = komaIndex;
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
    NSSortDescriptor* sortDesc = [[[NSSortDescriptor alloc] initWithKey:@"motionID"
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
    
    // テクスチャの選択
    if (mSelectingTextureUUID) {
        [theInfo setStringValue:mSelectingTextureUUID forName:@"Texture UUID"];
    } else {
        [theInfo removeObjectForKey:@"Texture UUID"];
    }

    // 動作
    NSMutableArray* motionInfos = [NSMutableArray array];
    for (int i = 0; i < [mMotions count]; i++) {
        BXChara2DMotion* aMotion = (BXChara2DMotion*)[mMotions objectAtIndex:i];
        [motionInfos addObject:[aMotion motionInfo]];
    }
    [theInfo setObject:motionInfos forKey:@"Motion Infos"];
    
    // コマプレビューのスケール
    [theInfo setDoubleValue:mKomaPreviewScale forName:@"Preview Scale"];
    
    // シミュレーション用の設定
    [theInfo setIntValue:mFirstMotionID forName:@"SIM First Motion ID"];
    [theInfo setIntValue:mFirstMotionKomaIndex forName:@"SIM First Koma Index"];
    [theInfo setBoolValue:mRevertToFirstMotion forName:@"SIM Revert To First Motion"];
    [theInfo setBoolValue:mIgnoresCancelFlag forName:@"SIM Ignores Cancel Flag"];
    [theInfo setBoolValue:mSkipEndAnimation forName:@"SIM Skip End Animation"];
    
    [theInfo setIntValue:mActionMotionIDUp forName:@"SIM Action Motion ID Up"];
    [theInfo setIntValue:mActionKomaIndexUp forName:@"SIM Action Koma Index Up"];
    [theInfo setBoolValue:mIgnoresCancelFlagUp forName:@"SIM Action Ignores Cancel Flag Up"];
    [theInfo setBoolValue:mSkipEndAnimationUp forName:@"SIM Action Skip End Animation Up"];
    [theInfo setIntValue:mActionSpeedUp forName:@"SIM Action Speed Up"];
    
    [theInfo setIntValue:mActionMotionIDDown forName:@"SIM Action Motion ID Down"];
    [theInfo setIntValue:mActionKomaIndexDown forName:@"SIM Action Koma Index Down"];
    [theInfo setBoolValue:mIgnoresCancelFlagDown forName:@"SIM Action Ignores Cancel Flag Down"];
    [theInfo setBoolValue:mSkipEndAnimationDown forName:@"SIM Action Skip End Animation Down"];
    [theInfo setIntValue:mActionSpeedDown forName:@"SIM Action Speed Down"];
    
    [theInfo setIntValue:mActionMotionIDLeft forName:@"SIM Action Motion ID Left"];
    [theInfo setIntValue:mActionKomaIndexLeft forName:@"SIM Action Koma Index Left"];
    [theInfo setBoolValue:mIgnoresCancelFlagLeft forName:@"SIM Action Ignores Cancel Flag Left"];
    [theInfo setBoolValue:mSkipEndAnimationLeft forName:@"SIM Action Skip End Animation Left"];
    [theInfo setIntValue:mActionSpeedLeft forName:@"SIM Action Speed Left"];
    
    [theInfo setIntValue:mActionMotionIDRight forName:@"SIM Action Motion ID Right"];
    [theInfo setIntValue:mActionKomaIndexRight forName:@"SIM Action Koma Index Right"];
    [theInfo setBoolValue:mIgnoresCancelFlagRight forName:@"SIM Action Ignores Cancel Flag Right"];
    [theInfo setBoolValue:mSkipEndAnimationRight forName:@"SIM Action Skip End Animation Right"];
    [theInfo setIntValue:mActionSpeedRight forName:@"SIM Action Speed Right"];
    
    [theInfo setIntValue:mActionMotionIDZ forName:@"SIM Action Motion ID Z"];
    [theInfo setIntValue:mActionKomaIndexZ forName:@"SIM Action Koma Index Z"];
    [theInfo setBoolValue:mIgnoresCancelFlagZ forName:@"SIM Action Ignores Cancel Flag Z"];
    [theInfo setBoolValue:mSkipEndAnimationZ forName:@"SIM Action Skip End Animation Z"];
    
    [theInfo setIntValue:mActionMotionIDX forName:@"SIM Action Motion ID X"];
    [theInfo setIntValue:mActionKomaIndexX forName:@"SIM Action Koma Index X"];
    [theInfo setBoolValue:mIgnoresCancelFlagX forName:@"SIM Action Ignores Cancel Flag X"];
    [theInfo setBoolValue:mSkipEndAnimationX forName:@"SIM Action Skip End Animation X"];
    
    [theInfo setIntValue:mActionMotionIDC forName:@"SIM Action Motion ID C"];
    [theInfo setIntValue:mActionKomaIndexC forName:@"SIM Action Koma Index C"];
    [theInfo setBoolValue:mIgnoresCancelFlagC forName:@"SIM Action Ignores Cancel Flag C"];
    [theInfo setBoolValue:mSkipEndAnimationC forName:@"SIM Action Skip End Animation C"];
    
    [theInfo setIntValue:mActionMotionIDMouse forName:@"SIM Action Motion ID Mouse"];
    [theInfo setIntValue:mActionKomaIndexMouse forName:@"SIM Action Koma Index Mouse"];
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
    
    // テクスチャの選択
    mSelectingTextureUUID = [[theInfo stringValueForName:@"Texture UUID" currentValue:mSelectingTextureUUID] copy];
    
    // 動作
    NSArray* motionInfos = [theInfo objectForKey:@"Motion Infos"];
    for (int i = 0; i < [motionInfos count]; i++) {
        NSDictionary* aMotionInfo = [motionInfos objectAtIndex:i];
        BXChara2DMotion* theMotion = [[[BXChara2DMotion alloc] initWithName:@"New Motion" chara2DSpec:self] autorelease];
        [theMotion restoreMotionInfo:aMotionInfo];
        [mMotions addObject:theMotion];
    }

    // コマプレビューのスケール
    mKomaPreviewScale = [theInfo doubleValueForName:@"Preview Scale" currentValue:mKomaPreviewScale];
    
    // シミュレーション用の設定
    mFirstMotionID = [theInfo intValueForName:@"SIM First Motion ID" currentValue:mFirstMotionID];
    mFirstMotionKomaIndex = [theInfo intValueForName:@"SIM First Koma Index" currentValue:mFirstMotionKomaIndex];
    mRevertToFirstMotion = [theInfo boolValueForName:@"SIM Revert To First Motion" currentValue:mRevertToFirstMotion];
    mIgnoresCancelFlag = [theInfo boolValueForName:@"SIM Ignores Cancel Flag" currentValue:mIgnoresCancelFlag];
    mSkipEndAnimation = [theInfo boolValueForName:@"SIM Skip End Animation" currentValue:mSkipEndAnimation];
    
    mActionMotionIDUp = [theInfo intValueForName:@"SIM Action Motion ID Up" currentValue:mActionMotionIDUp];
    mActionKomaIndexUp = [theInfo intValueForName:@"SIM Action Koma Index Up" currentValue:mActionKomaIndexUp];
    mIgnoresCancelFlagUp = [theInfo boolValueForName:@"SIM Action Ignores Cancel Flag Up" currentValue:mIgnoresCancelFlagUp];
    mSkipEndAnimationUp = [theInfo boolValueForName:@"SIM Action Skip End Animation Up" currentValue:mSkipEndAnimationUp];
    mActionSpeedUp = [theInfo intValueForName:@"SIM Action Speed Up" currentValue:mActionSpeedUp];
    
    mActionMotionIDDown = [theInfo intValueForName:@"SIM Action Motion ID Down" currentValue:mActionMotionIDDown];
    mActionKomaIndexDown = [theInfo intValueForName:@"SIM Action Koma Index Down" currentValue:mActionKomaIndexDown];
    mIgnoresCancelFlagDown = [theInfo boolValueForName:@"SIM Action Ignores Cancel Flag Down" currentValue:mIgnoresCancelFlagDown];
    mSkipEndAnimationDown = [theInfo boolValueForName:@"SIM Action Skip End Animation Down" currentValue:mSkipEndAnimationDown];
    mActionSpeedDown = [theInfo intValueForName:@"SIM Action Speed Down" currentValue:mActionSpeedDown];
    
    mActionMotionIDLeft = [theInfo intValueForName:@"SIM Action Motion ID Left" currentValue:mActionMotionIDLeft];
    mActionKomaIndexLeft = [theInfo intValueForName:@"SIM Action Koma Index Left" currentValue:mActionKomaIndexLeft];
    mIgnoresCancelFlagLeft = [theInfo boolValueForName:@"SIM Action Ignores Cancel Flag Left" currentValue:mIgnoresCancelFlagLeft];
    mSkipEndAnimationLeft = [theInfo boolValueForName:@"SIM Action Skip End Animation Left" currentValue:mSkipEndAnimationLeft];
    mActionSpeedLeft = [theInfo intValueForName:@"SIM Action Speed Left" currentValue:mActionSpeedLeft];
    
    mActionMotionIDRight = [theInfo intValueForName:@"SIM Action Motion ID Right" currentValue:mActionMotionIDRight];
    mActionKomaIndexRight = [theInfo intValueForName:@"SIM Action Koma Index Right" currentValue:mActionKomaIndexRight];
    mIgnoresCancelFlagRight = [theInfo boolValueForName:@"SIM Action Ignores Cancel Flag Right" currentValue:mIgnoresCancelFlagRight];
    mSkipEndAnimationRight = [theInfo boolValueForName:@"SIM Action Skip End Animation Right" currentValue:mSkipEndAnimationRight];
    mActionSpeedRight = [theInfo intValueForName:@"SIM Action Speed Right" currentValue:mActionSpeedRight];
    
    mActionMotionIDZ = [theInfo intValueForName:@"SIM Action Motion ID Z" currentValue:mActionMotionIDZ];
    mActionKomaIndexZ = [theInfo intValueForName:@"SIM Action Koma Index Z" currentValue:mActionKomaIndexZ];
    mIgnoresCancelFlagZ = [theInfo boolValueForName:@"SIM Action Ignores Cancel Flag Z" currentValue:mIgnoresCancelFlagZ];
    mSkipEndAnimationZ = [theInfo boolValueForName:@"SIM Action Skip End Animation Z" currentValue:mSkipEndAnimationZ];
    
    mActionMotionIDX = [theInfo intValueForName:@"SIM Action Motion ID X" currentValue:mActionMotionIDX];
    mActionKomaIndexX = [theInfo intValueForName:@"SIM Action Koma Index X" currentValue:mActionKomaIndexX];
    mIgnoresCancelFlagX = [theInfo boolValueForName:@"SIM Action Ignores Cancel Flag X" currentValue:mIgnoresCancelFlagX];
    mSkipEndAnimationX = [theInfo boolValueForName:@"SIM Action Skip End Animation X" currentValue:mSkipEndAnimationX];
    
    mActionMotionIDC = [theInfo intValueForName:@"SIM Action Motion ID C" currentValue:mActionMotionIDC];
    mActionKomaIndexC = [theInfo intValueForName:@"SIM Action Koma Index C" currentValue:mActionKomaIndexC];
    mIgnoresCancelFlagC = [theInfo boolValueForName:@"SIM Action Ignores Cancel Flag C" currentValue:mIgnoresCancelFlagC];
    mSkipEndAnimationC = [theInfo boolValueForName:@"SIM Action Skip End Animation C" currentValue:mSkipEndAnimationC];
    
    mActionMotionIDMouse = [theInfo intValueForName:@"SIM Action Motion ID Mouse" currentValue:mActionMotionIDMouse];
    mActionKomaIndexMouse = [theInfo intValueForName:@"SIM Action Koma Index Mouse" currentValue:mActionKomaIndexMouse];
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





