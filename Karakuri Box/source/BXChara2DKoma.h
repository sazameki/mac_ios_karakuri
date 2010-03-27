//
//  BXChara2DKoma.h
//  Karakuri Box
//
//  Created by numata on 10/03/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BXChara2DImage.h"
#import "KRTexture2D.h"


@class BXChara2DSpec;
@class BXChara2DState;
@class BXChara2DKoma;


enum {
    BXChara2DKomaHitTypeRect    = 0,
    BXChara2DKomaHitTypeOval    = 1,
};


@interface BXChara2DKomaHitInfo : NSObject<NSCopying> {
    BXChara2DKoma*      mParentKoma;

    int     mHitType;
    int     mGroupIndex;
    NSRect  mRect;
    
    NSPoint mTopMiddlePoint;
    NSPoint mBottomMiddlePoint;
    NSPoint mLeftMiddlePoint;
    NSPoint mRightMiddlePoint;
}

- (id)initWithType:(int)type group:(int)groupIndex rect:(NSRect)rect;
- (id)initWithInfo:(NSDictionary*)infoDict;

- (BXDocument*)document;

- (BOOL)isPointInTopMiddleHandle:(NSPoint)pos;
- (BOOL)isPointInBottomMiddleHandle:(NSPoint)pos;
- (BOOL)isPointInLeftMiddleHandle:(NSPoint)pos;
- (BOOL)isPointInRightMiddleHandle:(NSPoint)pos;

- (void)resizeFromTopWithPoint:(NSPoint)pos;
- (void)resizeFromBottomWithPoint:(NSPoint)pos;
- (void)resizeFromLeftWithPoint:(NSPoint)pos;
- (void)resizeFromRightWithPoint:(NSPoint)pos;

- (BXChara2DKoma*)parentKoma;
- (void)setParentKoma:(BXChara2DKoma*)aKoma;

- (BOOL)contains:(NSPoint)pos;

- (NSRect)rect;
- (void)setRect:(NSRect)rect;

- (void)drawInRect:(NSRect)targetRect scale:(double)scale isMain:(BOOL)isMain;
- (void)drawResizeHandlesInRect:(NSRect)targetRect scale:(double)scale;

- (int)groupIndex;

- (NSDictionary*)infoDict;

@end


@interface BXChara2DKoma : NSObject {
    BXChara2DState* mParentState;

    BXChara2DImage* mImage;
    int             mImageAtlasIndex;
    
    int             mKomaNumber;
    BOOL            mIsCancelable;
    int             mInterval;
    
    BXChara2DKoma*  mGotoTargetKoma;
    
    int             mTempGotoTargetKomaNumber;
    KRTexture2D*    mPreviewTex;
    
    NSMutableArray* mHitInfos;
    BOOL            mShowsHitInfos;
    int             mCurrentHitGroupIndex;
}

- (id)initWithInfo:(NSDictionary*)info chara2DSpec:(BXChara2DSpec*)chara2DSpec;

- (BXDocument*)document;

- (BXChara2DState*)parentState;
- (void)setParentState:(BXChara2DState*)aState;

- (void)setImage:(BXChara2DImage*)image atlasAtIndex:(int)index;

- (void)drawHitInfosInRect:(NSRect)targetRect scale:(double)scale;
- (int)hitInfoCount;
- (BOOL)showsHitInfos;
- (void)setShowsHitInfos:(BOOL)flag;
- (int)currentHitGroupIndex;
- (void)setCurrentHitGroupIndex:(int)index;
- (BXChara2DKomaHitInfo*)addHitInfoOval;
- (BXChara2DKomaHitInfo*)addHitInfoRect;
- (BXChara2DKomaHitInfo*)hitInfoAtPoint:(NSPoint)pos;
- (BXChara2DKomaHitInfo*)hitInfoAtIndex:(int)index;

- (void)addHitInfo:(BXChara2DKomaHitInfo*)aHitInfo;
- (void)importHitInfosFromKoma:(BXChara2DKoma*)aKoma;

- (int)komaNumber;
- (void)setKomaNumber:(int)number;

- (BOOL)isCancelable;
- (void)setCancelable:(BOOL)flag;
- (int)interval;
- (void)setInterval:(int)interval;
- (NSImage*)nsImage;
- (BXChara2DImage*)image;
- (int)atlasIndex;

- (BXChara2DKoma*)gotoTarget;
- (int)gotoTargetNumber;
- (void)setGotoTarget:(BXChara2DKoma*)target;

- (void)replaceTempGotoInfoForState:(BXChara2DState*)state;

- (void)preparePreviewTexture;
- (KRTexture2D*)previewTexture;

- (NSDictionary*)komaInfo;

@end

