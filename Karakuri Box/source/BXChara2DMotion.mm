//
//  BXChara2DMotion.mm
//  Karakuri Box
//
//  Created by numata on 10/03/08.
//  Copyright 2010 Satoshi Numata. All rights reserved.
//

#import "BXChara2DMotion.h"
#import "BXDocument.h"
#import "NSMutableArray+Moving.h"
#import "NSDictionary+LoadSave.h"


@interface BXChara2DMotion ()

- (void)renumberKomas;

@end


@implementation BXChara2DMotion

- (id)initWithName:(NSString*)name chara2DSpec:(BXChara2DSpec*)chara2DSpec
{
    self = [super init];
    if (self) {
        mParentSpec = chara2DSpec;
        
        mTargetKomaForCancel = nil;
        
        mMotionName = [name copy];
        mMotionID = 0;
        mKomas = [[NSMutableArray alloc] init];
        
        mDefaultKomaInterval = 4;
        
        mNextMotionID = -1;
    }
    return self;
}

- (void)dealloc
{
    [mMotionName release];
    [mKomas release];
    
    [super dealloc];
}

- (BXDocument*)document
{
    return [mParentSpec document];
}

- (BXChara2DKoma*)targetKomaForCancel
{
    return mTargetKomaForCancel;
}

- (void)setTargetKomaForCancel:(BXChara2DKoma*)koma
{
    mTargetKomaForCancel = koma;
}

- (BXChara2DSpec*)parentSpec
{
    return mParentSpec;
}

- (int)motionID
{
    return mMotionID;
}

- (void)setMotionID:(int)value
{
    mMotionID = value;
}

- (NSString*)motionName
{
    return mMotionName;
}

- (void)setMotionName:(NSString*)name
{
    [mMotionName release];
    mMotionName = nil;
    if (name) {
        mMotionName = [name copy];
    }
}

- (void)renumberKomas
{
    unsigned komaCount = [mKomas count];
    for (int i = 0; i < komaCount; i++) {
        BXChara2DKoma* aKoma = [mKomas objectAtIndex:i];
        [aKoma setKomaIndex:i];
    }
}

- (int)komaCount
{
    return [mKomas count];
}

- (BXChara2DKoma*)insertKomaAtIndex:(int)index
{
    BXChara2DKoma* aKoma = [[BXChara2DKoma alloc] init];
    [aKoma setParentMotion:self];
    [mKomas insertObject:aKoma atIndex:index];
    [aKoma release];
    [self renumberKomas];
    return aKoma;
}

- (int)moveKomaFrom:(int)fromIndex to:(int)toIndex
{
    int ret = [mKomas moveObjectAtIndex:fromIndex beforeIndex:toIndex];
    [self renumberKomas];
    return ret;
}

- (BXChara2DKoma*)komaAtIndex:(int)index
{
    if (index < 0) {
        return nil;
    }
    return [mKomas objectAtIndex:index];
}

- (void)removeKomaAtIndex:(int)index
{
    // 削除対象のコマ
    BXChara2DKoma* theKoma = [mKomas objectAtIndex:index];
    
    // 削除対象のコマを GOTO のターゲットに参照しているコマの処理
    unsigned komaCount = [mKomas count];
    for (unsigned i = 0; i < komaCount; i++) {
        if (i == index) {
            continue;
        }
        BXChara2DKoma* aKoma = [mKomas objectAtIndex:i];
        if ([aKoma gotoTargetKoma] == theKoma) {
            // 次のコマを GOTO のターゲットに設定する
            BXChara2DKoma* nextKoma = nil;
            if (index+1 < komaCount && index+1 != i) {
                nextKoma = [mKomas objectAtIndex:index+1];
            } else if (index-1 >= 0 && index-1 != i) {
                nextKoma = [mKomas objectAtIndex:index-1];
            }
            [aKoma setGotoTargetKoma:nextKoma];
        }
    }
    
    // 削除の実行
    [theKoma setParentMotion:nil];
    [mKomas removeObjectAtIndex:index];

    [self renumberKomas];
}

- (void)changeMotionIDInAllKomaFrom:(int)oldMotionID to:(int)newMotionID
{
    if (mNextMotionID == oldMotionID) {
        mNextMotionID = newMotionID;
    }
}

- (NSMenu*)makeKomaGotoMenuForKoma:(BXChara2DKoma*)koma document:(id)document
{
    NSMenu* ret = [[[NSMenu alloc] initWithTitle:@"Koma Goto Popup Menu"] autorelease];
    
    NSMenuItem* noneItem = [ret addItemWithTitle:@"----" action:@selector(changedChara2DKomaGotoTarget:) keyEquivalent:@""];
    [noneItem setTag:-1];
    [noneItem setTarget:document];
    
    int sourceKomaIndex = [koma komaIndex];
    
    for (int i = 0; i < [mKomas count]; i++) {
        if (i == sourceKomaIndex) {
            continue;
        }
        NSMenuItem* menuItem = [ret addItemWithTitle:[NSString stringWithFormat:@"%d", i]
                                              action:@selector(changedChara2DKomaGotoTarget:)
                                       keyEquivalent:@""];
        [menuItem setTag:i];
        [menuItem setTarget:document];
    }
    
    return ret;
}

- (int)defaultKomaInterval
{
    return mDefaultKomaInterval;
}

- (void)setDefaultKomaInterval:(int)interval
{
    mDefaultKomaInterval = interval;
}

- (int)nextMotionID
{
    return mNextMotionID;
}

- (void)setNextMotionID:(int)motionID
{
    mNextMotionID = motionID;
}

- (void)preparePreviewTextures
{
    for (int i = 0; i < [mKomas count]; i++) {
        BXChara2DKoma* aKoma = [mKomas objectAtIndex:i];
        [aKoma preparePreviewTexture];
    }    
}

- (NSDictionary*)motionInfo
{
    NSMutableDictionary* theInfo = [NSMutableDictionary dictionary];
    
    // 基本情報
    [theInfo setIntValue:mMotionID forName:@"Motion ID"];
    [theInfo setStringValue:mMotionName forName:@"Motion Name"];
    
    // コマ情報
    NSMutableArray* komaInfos = [NSMutableArray array];
    for (int i = 0; i < [mKomas count]; i++) {
        BXChara2DKoma* aKoma = [mKomas objectAtIndex:i];
        [komaInfos addObject:[aKoma komaInfo]];
    }
    [theInfo setObject:komaInfos forKey:@"Koma Infos"];
    
    // デフォルトの間隔
    [theInfo setIntValue:mDefaultKomaInterval forName:@"Default Interval"];
    
    // 次の動作ID
    [theInfo setIntValue:mNextMotionID forName:@"Next Motion ID"];
    
    // キャンセル時の終了アニメーション開始コマ
    if (mTargetKomaForCancel) {
        [theInfo setIntValue:[mTargetKomaForCancel komaIndex] forName:@"Cancel Koma Index"];
    } else {
        [theInfo setIntValue:-1 forName:@"Cancel Koma Index"];
    }
    
    return theInfo;
}

- (void)restoreMotionInfo:(NSDictionary*)theInfo
{
    // 基本情報
    mMotionID = [theInfo intValueForName:@"Motion ID" currentValue:mMotionID];
    [self setMotionName:[theInfo stringValueForName:@"Motion Name" currentValue:mMotionName]];
    
    // コマ情報
    NSArray* komaInfos = [theInfo objectForKey:@"Koma Infos"];
    for (int i = 0; i < [komaInfos count]; i++) {
        NSDictionary* aKomaInfo = [komaInfos objectAtIndex:i];
        BXChara2DKoma* aKoma = [[BXChara2DKoma alloc] initWithInfo:aKomaInfo chara2DSpec:mParentSpec];
        [aKoma setParentMotion:self];
        [mKomas addObject:aKoma];
        [aKoma release];
    }

    // デフォルトの間隔
    mDefaultKomaInterval = [theInfo intValueForName:@"Default Interval" currentValue:mDefaultKomaInterval];

    // 次の動作ID
    mNextMotionID = [theInfo intValueForName:@"Next Motion ID" currentValue:mNextMotionID];

    // キャンセル時の終了アニメーション開始コマ
    int cancelKomaIndex = [theInfo intValueForName:@"Cancel Koma Index" currentValue:-1];
    if (cancelKomaIndex >= 0 && [mKomas count] > cancelKomaIndex) {
        mTargetKomaForCancel = [self komaAtIndex:cancelKomaIndex];
    } else {
        mTargetKomaForCancel = nil;
    }

    // Gotoコマ情報をオブジェクトに置き換え
    for (int i = 0; i < [mKomas count]; i++) {
        BXChara2DKoma* aKoma = [mKomas objectAtIndex:i];
        [aKoma replaceTempGotoInfoForMotion:self];
    }
}

@end

