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


enum {
    BXChara2DKomaHitTypeRect    = 0,
    BXChara2DKomaHitTypeOval    = 1,
};


@interface BXChara2DKomaHitInfo : NSObject {
    int     mHitType;
    int     mGroupIndex;
    NSRect  mRect;
}

- (id)initWithType:(int)type group:(int)groupIndex rect:(NSRect)rect;
- (id)initWithInfo:(NSDictionary*)infoDict;

- (BOOL)contains:(NSPoint)pos;

- (NSRect)rect;
- (void)setRect:(NSRect)rect;

- (void)drawInRect:(NSRect)targetRect scale:(double)scale isMain:(BOOL)isMain;
- (void)drawResizeHandlesInRect:(NSRect)targetRect scale:(double)scale;

- (int)groupIndex;

- (NSDictionary*)infoDict;

@end


@interface BXChara2DKoma : NSObject {
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

- (void)drawHitInfosInRect:(NSRect)targetRect scale:(double)scale;

- (void)setImage:(BXChara2DImage*)image atlasAtIndex:(int)index;

- (int)hitInfoCount;
- (BOOL)showsHitInfos;
- (void)setShowsHitInfos:(BOOL)flag;
- (int)currentHitGroupIndex;
- (void)setCurrentHitGroupIndex:(int)index;
- (BXChara2DKomaHitInfo*)addHitInfoOval;
- (BXChara2DKomaHitInfo*)addHitInfoRect;
- (BXChara2DKomaHitInfo*)hitInfoAtPoint:(NSPoint)pos;

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

