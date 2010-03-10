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


@interface BXChara2DKoma : NSObject {
    BXChara2DImage* mImage;
    int             mImageAtlasIndex;
    
    int             mKomaNumber;
    BOOL            mIsCancelable;
    int             mInterval;
    
    BXChara2DKoma*  mGotoTargetKoma;
    
    int             mTempGotoTargetKomaNumber;
    KRTexture2D*    mPreviewTex;
}

- (id)initWithInfo:(NSDictionary*)info chara2DSpec:(BXChara2DSpec*)chara2DSpec;

- (void)setImage:(BXChara2DImage*)image atlasAtIndex:(int)index;

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

