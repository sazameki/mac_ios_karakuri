//
//  BXChara2DSpec.h
//  Karakuri Box
//
//  Created by numata on 10/02/28.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXResourceElement.h"
#import "BXChara2DState.h"
#import "BXChara2DImage.h"


@interface BXChara2DSpec : BXResourceElement {
    NSMutableArray*     mStates;
    NSMutableArray*     mImages;
    
    double              mKomaPreviewScale;
    
    int         mFirstStateID;
    int         mFirstStateKomaNumber;
    BOOL        mRevertToFirstState;
    BOOL        mIgnoresCancelFlag;
    BOOL        mSkipEndAnimation;
    
    int         mActionStateIDUp;
    int         mActionKomaNumberUp;
    BOOL        mIgnoresCancelFlagUp;
    BOOL        mSkipEndAnimationUp;
    int         mActionSpeedUp;
    
    int         mActionStateIDDown;
    int         mActionKomaNumberDown;
    BOOL        mIgnoresCancelFlagDown;
    BOOL        mSkipEndAnimationDown;
    int         mActionSpeedDown;
    
    int         mActionStateIDLeft;
    int         mActionKomaNumberLeft;
    BOOL        mIgnoresCancelFlagLeft;
    BOOL        mSkipEndAnimationLeft;
    int         mActionSpeedLeft;
    
    int         mActionStateIDRight;
    int         mActionKomaNumberRight;
    BOOL        mIgnoresCancelFlagRight;
    BOOL        mSkipEndAnimationRight;
    int         mActionSpeedRight;

    int         mActionStateIDZ;
    int         mActionKomaNumberZ;
    BOOL        mIgnoresCancelFlagZ;
    BOOL        mSkipEndAnimationZ;
    
    int         mActionStateIDX;
    int         mActionKomaNumberX;
    BOOL        mIgnoresCancelFlagX;
    BOOL        mSkipEndAnimationX;
    
    int         mActionStateIDC;
    int         mActionKomaNumberC;
    BOOL        mIgnoresCancelFlagC;
    BOOL        mSkipEndAnimationC;
    
    int         mActionStateIDMouse;
    int         mActionKomaNumberMouse;
    BOOL        mIgnoresCancelFlagMouse;
    BOOL        mSkipEndAnimationMouse;
    BOOL        mDoChangeMouseLocation;
}

- (id)initWithName:(NSString*)name defaultState:(BOOL)hasDefaultState;

- (int)firstStateID;
- (void)setFirstStateID:(int)stateID;
- (int)firstStateKomaNumber;
- (void)setFirstStateKomaNumber:(int)komaNumber;
- (BOOL)revertToFirstState;
- (void)setRevertToFirstState:(BOOL)flag;
- (BOOL)ignoresCancelFlag;
- (void)setIgnoresCancelFlag:(BOOL)flag;
- (BOOL)skipEndAnimation;
- (void)setSkipEndAnimation:(BOOL)flag;

- (int)actionStateIDUp;
- (void)setActionStateIDUp:(int)stateID;
- (int)actionKomaNumberUp;
- (void)setActionKomaNumberUp:(int)komaNumber;
- (BOOL)ignoresCancelFlagUp;
- (void)setIgnoresCancelFlagUp:(BOOL)flag;
- (BOOL)skipEndAnimationUp;
- (void)setSkipEndAnimationUp:(BOOL)flag;
- (int)actionSpeedUp;
- (void)setActionSpeedUp:(int)value;

- (int)actionStateIDDown;
- (void)setActionStateIDDown:(int)stateID;
- (int)actionKomaNumberDown;
- (void)setActionKomaNumberDown:(int)komaNumber;
- (BOOL)ignoresCancelFlagDown;
- (void)setIgnoresCancelFlagDown:(BOOL)flag;
- (BOOL)skipEndAnimationDown;
- (void)setSkipEndAnimationDown:(BOOL)flag;
- (int)actionSpeedDown;
- (void)setActionSpeedDown:(int)value;

- (int)actionStateIDLeft;
- (void)setActionStateIDLeft:(int)stateID;
- (int)actionKomaNumberLeft;
- (void)setActionKomaNumberLeft:(int)komaNumber;
- (BOOL)ignoresCancelFlagLeft;
- (void)setIgnoresCancelFlagLeft:(BOOL)flag;
- (BOOL)skipEndAnimationLeft;
- (void)setSkipEndAnimationLeft:(BOOL)flag;
- (int)actionSpeedLeft;
- (void)setActionSpeedLeft:(int)value;

- (int)actionStateIDRight;
- (void)setActionStateIDRight:(int)stateID;
- (int)actionKomaNumberRight;
- (void)setActionKomaNumberRight:(int)komaNumber;
- (BOOL)ignoresCancelFlagRight;
- (void)setIgnoresCancelFlagRight:(BOOL)flag;
- (BOOL)skipEndAnimationRight;
- (void)setSkipEndAnimationRight:(BOOL)flag;
- (int)actionSpeedRight;
- (void)setActionSpeedRight:(int)value;

- (int)actionStateIDZ;
- (void)setActionStateIDZ:(int)stateID;
- (int)actionKomaNumberZ;
- (void)setActionKomaNumberZ:(int)komaNumber;
- (BOOL)ignoresCancelFlagZ;
- (void)setIgnoresCancelFlagZ:(BOOL)flag;
- (BOOL)skipEndAnimationZ;
- (void)setSkipEndAnimationZ:(BOOL)flag;

- (int)actionStateIDX;
- (void)setActionStateIDX:(int)stateID;
- (int)actionKomaNumberX;
- (void)setActionKomaNumberX:(int)komaNumber;
- (BOOL)ignoresCancelFlagX;
- (void)setIgnoresCancelFlagX:(BOOL)flag;
- (BOOL)skipEndAnimationX;
- (void)setSkipEndAnimationX:(BOOL)flag;

- (int)actionStateIDC;
- (void)setActionStateIDC:(int)stateID;
- (int)actionKomaNumberC;
- (void)setActionKomaNumberC:(int)komaNumber;
- (BOOL)ignoresCancelFlagC;
- (void)setIgnoresCancelFlagC:(BOOL)flag;
- (BOOL)skipEndAnimationC;
- (void)setSkipEndAnimationC:(BOOL)flag;

- (int)actionStateIDMouse;
- (void)setActionStateIDMouse:(int)stateID;
- (int)actionKomaNumberMouse;
- (void)setActionKomaNumberMouse:(int)komaNumber;
- (BOOL)ignoresCancelFlagMouse;
- (void)setIgnoresCancelFlagMouse:(BOOL)flag;
- (BOOL)skipEndAnimationMouse;
- (void)setSkipEndAnimationMouse:(BOOL)flag;
- (BOOL)doChangeMouseLocation;
- (void)setDoChangeMouseLocation:(BOOL)flag;


- (BXChara2DState*)addNewState;
- (int)stateCount;
- (BXChara2DState*)stateAtIndex:(int)index;
- (BXChara2DState*)stateWithID:(int)stateID;
- (void)removeState:(BXChara2DState*)theState;
- (void)sortStateList;
- (void)changeStateIDInAllKomaFrom:(int)oldStateID to:(int)newStateID;

- (BXChara2DImage*)addImageAtPath:(NSString*)path document:(BXDocument*)document;
- (int)imageCount;
- (BXChara2DImage*)imageAtIndex:(int)index;
- (BXChara2DImage*)imageWithTicket:(NSString*)imageTicket;
- (void)removeImageAtIndex:(int)index;

- (double)komaPreviewScale;
- (void)setKomaPreviewScale:(double)value;

- (void)preparePreviewTextures;

@end

