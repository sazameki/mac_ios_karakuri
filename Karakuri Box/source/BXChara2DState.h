//
//  BXChara2DState.h
//  Karakuri Box
//
//  Created by numata on 10/03/08.
//  Copyright 2010 Satoshi Numata. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BXChara2DKoma.h"


@class BXDocument;
@class BXChara2DSpec;


@interface BXChara2DState : NSObject {
    BXChara2DSpec*  mParentSpec;
    
    BXChara2DKoma*  mTargetKomaForCancel;
    
    int         mStateID;
    NSString*   mStateName;
    
    NSMutableArray* mKomas;
    
    int         mDefaultKomaInterval;
    
    int         mNextStateID;
}

- (id)initWithName:(NSString*)name chara2DSpec:(BXChara2DSpec*)chara2DSpec;

- (BXChara2DKoma*)targetKomaForCancel;
- (void)setTargetKomaForCancel:(BXChara2DKoma*)koma;

- (BXChara2DSpec*)parentSpec;

- (int)stateID;
- (void)setStateID:(int)value;

- (NSString*)stateName;
- (void)setStateName:(NSString*)name;

- (int)komaCount;
- (BXChara2DKoma*)insertKomaAtIndex:(int)index;
- (BXChara2DKoma*)komaAtIndex:(int)index;
- (BXChara2DKoma*)komaWithNumber:(int)komaNumber;
- (int)moveKomaFrom:(int)fromIndex to:(int)toIndex;
- (void)removeKomaAtIndex:(int)index;
- (void)changeStateIDInAllKomaFrom:(int)oldStateID to:(int)newStateID;

- (NSMenu*)makeKomaGotoMenuForKoma:(BXChara2DKoma*)koma document:(id)document;

- (int)defaultKomaInterval;
- (void)setDefaultKomaInterval:(int)interval;

- (int)nextStateID;
- (void)setNextStateID:(int)stateID;

- (void)preparePreviewTextures;

- (NSDictionary*)stateInfo;
- (void)restoreStateInfo:(NSDictionary*)theInfo;

@end

