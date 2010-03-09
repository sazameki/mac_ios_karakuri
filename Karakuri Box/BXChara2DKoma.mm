//
//  BXChara2DKoma.mm
//  Karakuri Box
//
//  Created by numata on 10/03/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXChara2DKoma.h"


@implementation BXChara2DKoma

- (id)init
{
    self = [super init];
    if (self) {
        mKomaNumber = 0;
        mIsCancelable = YES;
        mInterval = 0;
        mTargetKoma = nil;
    }
    return self;
}

- (void)setImage:(BXChara2DImage*)image atlasAtIndex:(int)index
{
    mImage = image;
    mImageAtlasIndex = index;
    
    [mImage incrementUsedCount];
}

- (int)komaNumber
{
    return mKomaNumber;
}

- (void)setKomaNumber:(int)number
{
    mKomaNumber = number;
}

- (BOOL)isCancelable
{
    return mIsCancelable;
}

- (void)setCancelable:(BOOL)flag
{
    mIsCancelable = flag;
}

- (int)interval
{
    return mInterval;
}

- (void)setInterval:(int)interval
{
    mInterval = interval;
}

- (NSImage*)nsImage
{
    return [mImage atlasImage72dpiAtIndex:mImageAtlasIndex];
}

- (BXChara2DImage*)image
{
    return mImage;
}

- (int)gotoTargetNumber
{
    if (!mTargetKoma) {
        return 0;
    }
    return [mTargetKoma komaNumber];
}

- (void)setGotoTarget:(BXChara2DKoma*)target
{
    mTargetKoma = target;
}

@end

