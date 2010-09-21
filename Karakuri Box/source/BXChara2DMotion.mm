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
    mMotionName = [name copy];
}

- (void)renumberKomas
{
    unsigned komaCount = [mKomas count];
    for (int i = 0; i < komaCount; i++) {
        BXChara2DKoma* aKoma = [mKomas objectAtIndex:i];
        [aKoma setKomaNumber:i+1];
    }
}

- (int)komaCount
{
    return [mKomas count];
}

- (BXChara2DKoma*)insertKomaAtIndex:(int)index
{
    BXChara2DKoma* aKoma = [[[BXChara2DKoma alloc] init] autorelease];
    [aKoma setParentMotion:self];
    [mKomas insertObject:aKoma atIndex:index];
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
    return [mKomas objectAtIndex:index];
}

- (BXChara2DKoma*)komaWithNumber:(int)komaNumber
{
    for (int i = 0; i < [mKomas count]; i++) {
        BXChara2DKoma* aKoma = [mKomas objectAtIndex:i];
        if ([aKoma komaNumber] == komaNumber) {
            return aKoma;
        }
    }
    return nil;
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
        if ([aKoma gotoTarget] == theKoma) {
            BXChara2DKoma* nextKoma = nil;
            if (index+1 < komaCount && index+1 != i) {
                nextKoma = [mKomas objectAtIndex:index+1];
            } else if (index-1 >= 0 && index-1 != i) {
                nextKoma = [mKomas objectAtIndex:index-1];
            }
            [aKoma setGotoTarget:nextKoma];
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
    [noneItem setTag:0];
    [noneItem setTarget:document];
    
    int sourceIndex = [koma komaNumber] - 1;
    
    for (int i = 0; i < [mKomas count]; i++) {
        if (i == sourceIndex) {
            continue;
        }
        NSMenuItem* menuItem = [ret addItemWithTitle:[NSString stringWithFormat:@"%d", i]
                                              action:@selector(changedChara2DKomaGotoTarget:)
                                       keyEquivalent:@""];
        [menuItem setTag:i+1];
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
    [theInfo setIntValue:mMotionID forName:@"State ID"];
    [theInfo setStringValue:mMotionName forName:@"State Name"];
    
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
    [theInfo setIntValue:mNextMotionID forName:@"Next State ID"];
    
    // キャンセル時の終了アニメーション開始コマ
    [theInfo setIntValue:[mTargetKomaForCancel komaNumber] forName:@"Cancel Koma"];
    
    return theInfo;
}

- (void)restoreMotionInfo:(NSDictionary*)theInfo
{
    // 基本情報
    mMotionID = [theInfo intValueForName:@"State ID" currentValue:mMotionID];
    [self setMotionName:[theInfo stringValueForName:@"State Name" currentValue:mMotionName]];
    
    // コマ情報
    NSArray* komaInfos = [theInfo objectForKey:@"Koma Infos"];
    for (int i = 0; i < [komaInfos count]; i++) {
        NSDictionary* aKomaInfo = [komaInfos objectAtIndex:i];
        BXChara2DKoma* aKoma = [[[BXChara2DKoma alloc] initWithInfo:aKomaInfo chara2DSpec:mParentSpec] autorelease];
        [aKoma setParentMotion:self];
        [mKomas addObject:aKoma];
    }

    // デフォルトの間隔
    mDefaultKomaInterval = [theInfo intValueForName:@"Default Interval" currentValue:mDefaultKomaInterval];

    // 次の動作ID
    mNextMotionID = [theInfo intValueForName:@"Next State ID" currentValue:mNextMotionID];

    // キャンセル時の終了アニメーション開始コマ
    int theKomaNumber = [theInfo intValueForName:@"Cancel Koma" currentValue:0];
    mTargetKomaForCancel = [self komaWithNumber:theKomaNumber];

    // Gotoコマ情報をオブジェクトに置き換え
    for (int i = 0; i < [mKomas count]; i++) {
        BXChara2DKoma* aKoma = [mKomas objectAtIndex:i];
        [aKoma replaceTempGotoInfoForMotion:self];
    }
}

@end

