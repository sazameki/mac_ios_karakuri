//
//  BXChara2DMotion.h
//  Karakuri Box
//
//  Created by numata on 10/03/08.
//  Copyright 2010 Satoshi Numata. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BXChara2DKoma.h"


@class BXChara2DSpec;


@interface BXChara2DMotion : NSObject {
    BXChara2DSpec*  mParentSpec;
    
    BXChara2DKoma*  mTargetKomaForCancel;
    
    int         mMotionID;
    NSString*   mMotionName;
    
    NSMutableArray* mKomas;
    
    int         mDefaultKomaInterval;
    
    int         mNextMotionID;
}

- (id)initWithName:(NSString*)name chara2DSpec:(BXChara2DSpec*)chara2DSpec;

- (BXDocument*)document;

- (BXChara2DKoma*)targetKomaForCancel;
- (void)setTargetKomaForCancel:(BXChara2DKoma*)koma;

- (BXChara2DSpec*)parentSpec;

- (int)motionID;
- (void)setMotionID:(int)value;

- (NSString*)motionName;
- (void)setMotionName:(NSString*)name;

- (int)komaCount;
- (BXChara2DKoma*)insertKomaAtIndex:(int)index;
- (BXChara2DKoma*)komaAtIndex:(int)index;
- (BXChara2DKoma*)komaWithNumber:(int)komaNumber;
- (int)moveKomaFrom:(int)fromIndex to:(int)toIndex;
- (void)removeKomaAtIndex:(int)index;
- (void)changeMotionIDInAllKomaFrom:(int)oldMotionID to:(int)newMotionID;

- (NSMenu*)makeKomaGotoMenuForKoma:(BXChara2DKoma*)koma document:(id)document;

- (int)defaultKomaInterval;
- (void)setDefaultKomaInterval:(int)interval;

- (int)nextMotionID;
- (void)setNextMotionID:(int)motionID;

- (void)preparePreviewTextures;

- (NSDictionary*)motionInfo;
- (void)restoreMotionInfo:(NSDictionary*)theInfo;

@end

