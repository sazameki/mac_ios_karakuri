//
//  BXChara2DKoma.mm
//  Karakuri Box
//
//  Created by numata on 10/03/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXChara2DKoma.h"
#import "NSDictionary+LoadSave.h"
#import "BXChara2DSpec.h"
#import "BXChara2DState.h"


@implementation BXChara2DKoma

- (id)init
{
    self = [super init];
    if (self) {
        mKomaNumber = 0;
        mIsCancelable = YES;
        mInterval = 0;
        mGotoTargetKoma = nil;
    }
    return self;
}

- (id)initWithInfo:(NSDictionary*)info chara2DSpec:(BXChara2DSpec*)chara2DSpec
{
    self = [super init];
    if (self) {
        int imageID = [info intValueForName:@"Image ID" currentValue:-1];
        mImage = [chara2DSpec imageWithID:imageID];
        mImageAtlasIndex = [info intValueForName:@"Atlas Index" currentValue:0];
        
        mKomaNumber = [info intValueForName:@"Koma Number" currentValue:0];
        mIsCancelable = [info boolValueForName:@"Cancelable" currentValue:YES];
        mInterval = [info intValueForName:@"Interval" currentValue:0];
        
        mTempGotoTargetKomaNumber = [info intValueForName:@"Goto Target" currentValue:0];
        
        mGotoTargetKoma = nil;
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
    if (!mGotoTargetKoma) {
        return 0;
    }
    return [mGotoTargetKoma komaNumber];
}

- (void)setGotoTarget:(BXChara2DKoma*)target
{
    mGotoTargetKoma = target;
}

- (void)replaceTempGotoInfoForState:(BXChara2DState*)state
{
    if (mTempGotoTargetKomaNumber > 0) {
        BXChara2DKoma* targetKoma = [state komaWithNumber:mTempGotoTargetKomaNumber];
        mGotoTargetKoma = targetKoma;
    }
    
    mTempGotoTargetKomaNumber = -1;
}

- (NSDictionary*)komaInfo
{
    NSMutableDictionary* theInfo = [NSMutableDictionary dictionary];
    
    [theInfo setIntValue:[mImage imageID] forName:@"Image ID"];
    [theInfo setIntValue:mImageAtlasIndex forName:@"Atlas Index"];
    [theInfo setIntValue:mKomaNumber forName:@"Koma Number"];
    [theInfo setBoolValue:mIsCancelable forName:@"Cancelable"];
    [theInfo setIntValue:mInterval forName:@"Interval"];
    [theInfo setIntValue:[self gotoTargetNumber] forName:@"Goto Target"];

    return theInfo;
}

@end

