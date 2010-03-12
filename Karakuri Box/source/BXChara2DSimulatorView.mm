//
//  BXChara2DSimulatorView.m
//  Karakuri Box
//
//  Created by numata on 10/03/11.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXChara2DSimulatorView.h"


@implementation BXChara2DSimulatorView

- (BOOL)acceptsFirstResponder { return YES; }

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        mTargetSpec = NULL;
        mCurrentPos = new KRVector2D();
    }
    return self;
}

- (void)dealloc
{
    delete mCurrentPos;
    
    [super dealloc];
}

- (void)setupForChara2DSpec:(BXChara2DSpec*)aSpec
{
    [self setNeedsDisplay:YES];
    
    *mCurrentPos = KRVector2D(100, 100);

    CGLLockContext(mCGLContext);
    CGLSetCurrentContext(mCGLContext);

    mTargetSpec = aSpec;
    
    [mTargetSpec preparePreviewTextures];
    
    mCurrentState = [mTargetSpec stateAtIndex:0];

    mKomaNumber = 1;
    mCurrentKoma = [mCurrentState komaWithNumber:mKomaNumber];
    mKomaInterval = [mCurrentKoma interval];
    if (mKomaInterval == 0) {
        mKomaInterval = [mCurrentState defaultKomaInterval];
    }

    CGLUnlockContext(mCGLContext);
}

- (void)glDrawMain
{
    mGraphics->clear(KRColor::Black);
    
    KRTexture2D* theTex = [mCurrentKoma previewTexture];
    theTex->drawAtPoint(*mCurrentPos, KRColor::White);
}

- (void)startAnimation
{
    mTimer = [NSTimer scheduledTimerWithTimeInterval:0.016 target:self selector:@selector(refreshProc:) userInfo:nil repeats:YES];
}

- (void)stopAnimation
{
    [mTimer invalidate];
    mTimer = nil;
}

- (void)refreshProc:(NSTimer*)theTimer
{
    mKomaInterval--;
    if (mKomaInterval == 0) {
        int gotoTargetNumber = [mCurrentKoma gotoTargetNumber];
        if (gotoTargetNumber > 0) {
            mKomaNumber = gotoTargetNumber;
        } else {
            mKomaNumber++;
        }
        if (mKomaNumber <= [mCurrentState komaCount]) {
            mCurrentKoma = [mCurrentState komaWithNumber:mKomaNumber];
            mKomaInterval = [mCurrentKoma interval];
            if (mKomaInterval == 0) {
                mKomaInterval = [mCurrentState defaultKomaInterval];
            }
        } else {
            BXChara2DState* nextState = [mTargetSpec stateWithID:[mCurrentState nextStateID]];
            if (nextState) {
                mCurrentState = nextState;
                mKomaNumber = 1;
                mCurrentKoma = [mCurrentState komaWithNumber:mKomaNumber];
                mKomaInterval = [mCurrentKoma interval];
                if (mKomaInterval == 0) {
                    mKomaInterval = [mCurrentState defaultKomaInterval];
                }                
            }
        }
    }
    
    [self setNeedsDisplay:YES];
}

@end

