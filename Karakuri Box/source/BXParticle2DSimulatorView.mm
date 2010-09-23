//
//  BXParticle2DSimulatorView.m
//  Karakuri Box
//
//  Created by numata on 10/02/28.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXParticle2DSimulatorView.h"


@implementation BXParticle2DSimulatorView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        mTargetSpec = nil;
        mParticleSystem = NULL;
    }
    return self;
}

- (void)dealloc
{
    [self releaseParticles]; 
    
    [super dealloc];
}

- (void)refreshProc:(NSTimer*)theTimer
{
    if (mParticleSystem != NULL) {
        mParticleSystem->step();
    }
    [self setNeedsDisplay:YES];
}

- (void)setupForParticleSpec:(BXSingleParticle2DSpec*)aSpec
{
    mTargetSpec = aSpec;
    
    [self rebuildParticleSystem];
    
    if (mTargetSpec) {    
        mTimer = [NSTimer scheduledTimerWithTimeInterval:0.016 target:self selector:@selector(refreshProc:) userInfo:nil repeats:YES];
    }
}

- (void)rebuildParticleSystem
{
    CGLLockContext(mCGLContext);
    CGLSetCurrentContext(mCGLContext);
    
    if (mParticleSystem != NULL) {
        delete mParticleSystem;
        mParticleSystem = NULL;
    }
    
    mParticleSystem = [mTargetSpec createParticleSystem];
    if (mParticleSystem != NULL) {
        KRVector2D startPos = [mTargetSpec generationPos];
        mParticleSystem->setStartPos(startPos);
    }

    CGLUnlockContext(mCGLContext);
}

- (void)releaseParticles
{
    [mTimer invalidate];
    mTimer = nil;
    
    if (mParticleSystem != NULL) {
        delete mParticleSystem;
        mParticleSystem = NULL;
    }
}

- (void)glDrawMain
{
    if (mTargetSpec) {
        mGraphics->clear([mTargetSpec bgColor1]);
    } else {
        mGraphics->clear(KRColor::Red);
    }

    if (mParticleSystem != NULL) {
        mParticleSystem->draw();
    }    
}

- (void)mouseDown:(NSEvent*)theEvent
{
    if (mTargetSpec) {
        NSPoint pos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        [mTargetSpec setGenerationPos:KRVector2D(pos.x, pos.y)];
        if (mParticleSystem != NULL) {
            if ([mTargetSpec doLoop]) {
                mParticleSystem->setStartPos(KRVector2D(pos.x, pos.y));
            } else {
                mParticleSystem->addGenerationPoint(KRVector2D(pos.x, pos.y), 0);
            }
        }
    }
}

- (void)mouseDragged:(NSEvent*)theEvent
{
    if (mTargetSpec) {
        NSPoint pos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        [mTargetSpec setGenerationPos:KRVector2D(pos.x, pos.y)];
        if ([mTargetSpec doLoop]) {
            mParticleSystem->setStartPos(KRVector2D(pos.x, pos.y));
        } else {
            mParticleSystem->addGenerationPoint(KRVector2D(pos.x, pos.y), 0);
        }
    }
}

- (void)mouseUp:(NSEvent*)theEvent
{
    // Do nothing
}

@end

