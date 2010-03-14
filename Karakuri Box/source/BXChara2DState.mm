//
//  BXChara2DState.mm
//  Karakuri Box
//
//  Created by numata on 10/03/08.
//  Copyright 2010 Satoshi Numata. All rights reserved.
//

#import "BXChara2DState.h"
#import "BXDocument.h"
#import "NSMutableArray+Moving.h"
#import "NSDictionary+LoadSave.h"


@interface BXChara2DState ()

- (void)renumberKomas;

@end


@implementation BXChara2DState

- (id)initWithName:(NSString*)name chara2DSpec:(BXChara2DSpec*)chara2DSpec
{
    self = [super init];
    if (self) {
        mParentSpec = chara2DSpec;
        
        mTargetKomaForCancel = nil;
        
        mStateName = [name copy];
        mStateID = 1;
        mKomas = [[NSMutableArray alloc] init];
        
        mDefaultKomaInterval = 4;
        
        mNextStateID = -1;
    }
    return self;
}

- (void)dealloc
{
    [mStateName release];
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

- (int)stateID
{
    return mStateID;
}

- (void)setStateID:(int)value
{
    mStateID = value;
}

- (NSString*)stateName
{
    return mStateName;
}

- (void)setStateName:(NSString*)name
{
    [mStateName release];
    mStateName = [name copy];
}

- (void)renumberKomas
{
    for (int i = 0; i < [mKomas count]; i++) {
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
    [aKoma setParentState:self];
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
    BXChara2DKoma* theKoma = [mKomas objectAtIndex:index];
    [theKoma setParentState:nil];
    BXChara2DImage* theImage = [theKoma image];
    [theImage decrementUsedCount];
    [mKomas removeObjectAtIndex:index];

    [self renumberKomas];
}

- (void)changeStateIDInAllKomaFrom:(int)oldStateID to:(int)newStateID
{
    if (mNextStateID == oldStateID) {
        mNextStateID = newStateID;
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
        
        NSMenuItem* menuItem = [ret addItemWithTitle:[NSString stringWithFormat:@"%d", i+1]
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

- (int)nextStateID
{
    return mNextStateID;
}

- (void)setNextStateID:(int)stateID
{
    mNextStateID = stateID;
}

- (void)preparePreviewTextures
{
    for (int i = 0; i < [mKomas count]; i++) {
        BXChara2DKoma* aKoma = [mKomas objectAtIndex:i];
        [aKoma preparePreviewTexture];
    }    
}

- (NSDictionary*)stateInfo
{
    NSMutableDictionary* theInfo = [NSMutableDictionary dictionary];
    
    // 基本情報
    [theInfo setIntValue:mStateID forName:@"State ID"];
    [theInfo setStringValue:mStateName forName:@"State Name"];
    
    // コマ情報
    NSMutableArray* komaInfos = [NSMutableArray array];
    for (int i = 0; i < [mKomas count]; i++) {
        BXChara2DKoma* aKoma = [mKomas objectAtIndex:i];
        [komaInfos addObject:[aKoma komaInfo]];
    }
    [theInfo setObject:komaInfos forKey:@"Koma Infos"];
    
    // デフォルトの間隔
    [theInfo setIntValue:mDefaultKomaInterval forName:@"Default Interval"];
    
    // 次の状態ID
    [theInfo setIntValue:mNextStateID forName:@"Next State ID"];
    
    // キャンセル時の終了アニメーション開始コマ
    [theInfo setIntValue:[mTargetKomaForCancel komaNumber] forName:@"Cancel Koma"];
    
    return theInfo;
}

- (void)restoreStateInfo:(NSDictionary*)theInfo
{
    // 基本情報
    mStateID = [theInfo intValueForName:@"State ID" currentValue:mStateID];
    [self setStateName:[theInfo stringValueForName:@"State Name" currentValue:mStateName]];
    
    // コマ情報
    NSArray* komaInfos = [theInfo objectForKey:@"Koma Infos"];
    for (int i = 0; i < [komaInfos count]; i++) {
        NSDictionary* aKomaInfo = [komaInfos objectAtIndex:i];
        BXChara2DKoma* aKoma = [[[BXChara2DKoma alloc] initWithInfo:aKomaInfo chara2DSpec:mParentSpec] autorelease];
        [aKoma setParentState:self];
        [mKomas addObject:aKoma];
    }

    // デフォルトの間隔
    mDefaultKomaInterval = [theInfo intValueForName:@"Default Interval" currentValue:mDefaultKomaInterval];

    // 次の状態ID
    mNextStateID = [theInfo intValueForName:@"Next State ID" currentValue:mNextStateID];

    // キャンセル時の終了アニメーション開始コマ
    int theKomaNumber = [theInfo intValueForName:@"Cancel Koma" currentValue:0];
    mTargetKomaForCancel = [self komaWithNumber:theKomaNumber];

    // Gotoコマ情報をオブジェクトに置き換え
    for (int i = 0; i < [mKomas count]; i++) {
        BXChara2DKoma* aKoma = [mKomas objectAtIndex:i];
        [aKoma replaceTempGotoInfoForState:self];
    }
}

@end

