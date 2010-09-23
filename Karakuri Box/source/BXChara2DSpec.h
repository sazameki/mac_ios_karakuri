//
//  BXChara2DSpec.h
//  Karakuri Box
//
//  Created by numata on 10/02/28.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXResourceElement.h"
#import "BXChara2DMotion.h"


@interface BXChara2DSpec : BXResourceElement {
    NSMutableArray*     mMotions;
    
    double              mKomaPreviewScale;
    
    NSString*           mSelectingTextureUUID;
    
    int         mFirstMotionID;
    int         mFirstMotionKomaIndex;
    BOOL        mRevertToFirstMotion;
    BOOL        mIgnoresCancelFlag;
    BOOL        mSkipEndAnimation;
    
    int         mActionMotionIDUp;
    int         mActionKomaIndexUp;
    BOOL        mIgnoresCancelFlagUp;
    BOOL        mSkipEndAnimationUp;
    int         mActionSpeedUp;
    
    int         mActionMotionIDDown;
    int         mActionKomaIndexDown;
    BOOL        mIgnoresCancelFlagDown;
    BOOL        mSkipEndAnimationDown;
    int         mActionSpeedDown;
    
    int         mActionMotionIDLeft;
    int         mActionKomaIndexLeft;
    BOOL        mIgnoresCancelFlagLeft;
    BOOL        mSkipEndAnimationLeft;
    int         mActionSpeedLeft;
    
    int         mActionMotionIDRight;
    int         mActionKomaIndexRight;
    BOOL        mIgnoresCancelFlagRight;
    BOOL        mSkipEndAnimationRight;
    int         mActionSpeedRight;

    int         mActionMotionIDZ;
    int         mActionKomaIndexZ;
    BOOL        mIgnoresCancelFlagZ;
    BOOL        mSkipEndAnimationZ;
    
    int         mActionMotionIDX;
    int         mActionKomaIndexX;
    BOOL        mIgnoresCancelFlagX;
    BOOL        mSkipEndAnimationX;
    
    int         mActionMotionIDC;
    int         mActionKomaIndexC;
    BOOL        mIgnoresCancelFlagC;
    BOOL        mSkipEndAnimationC;
    
    int         mActionMotionIDMouse;
    int         mActionKomaIndexMouse;
    BOOL        mIgnoresCancelFlagMouse;
    BOOL        mSkipEndAnimationMouse;
    BOOL        mDoChangeMouseLocation;
}

- (id)initWithName:(NSString*)name defaultMotion:(BOOL)hasDefaultMotion;

- (NSString*)selectingTextureUUID;
- (void)setSelectingTextureUUID:(NSString*)textureUUID;

- (int)firstMotionID;
- (void)setFirstMotionID:(int)motionID;
- (int)firstMotionKomaIndex;
- (void)setFirstMotionKomaIndex:(int)komaIndex;
- (BOOL)revertToFirstMotion;
- (void)setRevertToFirstMotion:(BOOL)flag;
- (BOOL)ignoresCancelFlag;
- (void)setIgnoresCancelFlag:(BOOL)flag;
- (BOOL)skipEndAnimation;
- (void)setSkipEndAnimation:(BOOL)flag;

- (int)actionMotionIDUp;
- (void)setActionMotionIDUp:(int)motionID;
- (int)actionKomaIndexUp;
- (void)setActionKomaIndexUp:(int)komaIndex;
- (BOOL)ignoresCancelFlagUp;
- (void)setIgnoresCancelFlagUp:(BOOL)flag;
- (BOOL)skipEndAnimationUp;
- (void)setSkipEndAnimationUp:(BOOL)flag;
- (int)actionSpeedUp;
- (void)setActionSpeedUp:(int)value;

- (int)actionMotionIDDown;
- (void)setActionMotionIDDown:(int)motionID;
- (int)actionKomaIndexDown;
- (void)setActionKomaIndexDown:(int)komaIndex;
- (BOOL)ignoresCancelFlagDown;
- (void)setIgnoresCancelFlagDown:(BOOL)flag;
- (BOOL)skipEndAnimationDown;
- (void)setSkipEndAnimationDown:(BOOL)flag;
- (int)actionSpeedDown;
- (void)setActionSpeedDown:(int)value;

- (int)actionMotionIDLeft;
- (void)setActionMotionIDLeft:(int)motionID;
- (int)actionKomaIndexLeft;
- (void)setActionKomaIndexLeft:(int)komaIndex;
- (BOOL)ignoresCancelFlagLeft;
- (void)setIgnoresCancelFlagLeft:(BOOL)flag;
- (BOOL)skipEndAnimationLeft;
- (void)setSkipEndAnimationLeft:(BOOL)flag;
- (int)actionSpeedLeft;
- (void)setActionSpeedLeft:(int)value;

- (int)actionMotionIDRight;
- (void)setActionMotionIDRight:(int)motionID;
- (int)actionKomaIndexRight;
- (void)setActionKomaIndexRight:(int)komaIndex;
- (BOOL)ignoresCancelFlagRight;
- (void)setIgnoresCancelFlagRight:(BOOL)flag;
- (BOOL)skipEndAnimationRight;
- (void)setSkipEndAnimationRight:(BOOL)flag;
- (int)actionSpeedRight;
- (void)setActionSpeedRight:(int)value;

- (int)actionMotionIDZ;
- (void)setActionMotionIDZ:(int)motionID;
- (int)actionKomaIndexZ;
- (void)setActionKomaIndexZ:(int)komaIndex;
- (BOOL)ignoresCancelFlagZ;
- (void)setIgnoresCancelFlagZ:(BOOL)flag;
- (BOOL)skipEndAnimationZ;
- (void)setSkipEndAnimationZ:(BOOL)flag;

- (int)actionMotionIDX;
- (void)setActionMotionIDX:(int)motionID;
- (int)actionKomaIndexX;
- (void)setActionKomaIndexX:(int)komaIndex;
- (BOOL)ignoresCancelFlagX;
- (void)setIgnoresCancelFlagX:(BOOL)flag;
- (BOOL)skipEndAnimationX;
- (void)setSkipEndAnimationX:(BOOL)flag;

- (int)actionMotionIDC;
- (void)setActionMotionIDC:(int)motionID;
- (int)actionKomaIndexC;
- (void)setActionKomaIndexC:(int)komaIndex;
- (BOOL)ignoresCancelFlagC;
- (void)setIgnoresCancelFlagC:(BOOL)flag;
- (BOOL)skipEndAnimationC;
- (void)setSkipEndAnimationC:(BOOL)flag;

- (int)actionMotionIDMouse;
- (void)setActionMotionIDMouse:(int)motionID;
- (int)actionKomaIndexMouse;
- (void)setActionKomaIndexMouse:(int)komaIndex;
- (BOOL)ignoresCancelFlagMouse;
- (void)setIgnoresCancelFlagMouse:(BOOL)flag;
- (BOOL)skipEndAnimationMouse;
- (void)setSkipEndAnimationMouse:(BOOL)flag;
- (BOOL)doChangeMouseLocation;
- (void)setDoChangeMouseLocation:(BOOL)flag;


- (BXChara2DMotion*)addNewMotion;
- (int)motionCount;
- (BXChara2DMotion*)motionAtIndex:(int)index;
- (BXChara2DMotion*)motionWithID:(int)motionID;
- (void)removeMotion:(BXChara2DMotion*)theMotion;
- (void)sortMotionList;
- (void)changeMotionIDInAllKomaFrom:(int)oldMotionID to:(int)newMotionID;

- (double)komaPreviewScale;
- (void)setKomaPreviewScale:(double)value;

- (void)preparePreviewTextures;

@end

