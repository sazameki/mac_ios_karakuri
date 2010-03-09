//
//  BXChara2DKoma.h
//  Karakuri Box
//
//  Created by numata on 10/03/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BXChara2DImage.h"


@interface BXChara2DKoma : NSObject {
    BXChara2DImage*     mImage;
    int                 mImageAtlasIndex;
    
    int     mKomaNumber;
    BOOL    mIsCancelable;
    int     mInterval;
    
    BXChara2DKoma*  mTargetKoma;
}

- (void)setImage:(BXChara2DImage*)image atlasAtIndex:(int)index;

- (int)komaNumber;
- (void)setKomaNumber:(int)number;

- (BOOL)isCancelable;
- (void)setCancelable:(BOOL)flag;
- (int)interval;
- (void)setInterval:(int)interval;
- (NSImage*)nsImage;
- (BXChara2DImage*)image;

- (int)gotoTargetNumber;
- (void)setGotoTarget:(BXChara2DKoma*)target;

@end

