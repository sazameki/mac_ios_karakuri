//
//  BXParticleSimulatorView.m
//  Karakuri Box
//
//  Created by numata on 10/02/28.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXParticleSimulatorView.h"


@implementation BXParticleSimulatorView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        mTargetSpec = NULL;
        mParticleSystem = NULL;
        mHasGeneratedParticle = YES;
        mForceGenerate = NO;
    }
    return self;
}

- (void)refreshProc:(NSTimer *)theTimer
{
    if (mParticleSystem != NULL) {
        if ([mTargetSpec doLoop] || !mHasGeneratedParticle || mForceGenerate) {
            mParticleSystem->addGenerationPoint([mTargetSpec generationPos]);
            mHasGeneratedParticle = YES;
        }
        mParticleSystem->step();
    }
    [self setNeedsDisplay:YES];
}

- (void)setupForParticleSpec:(BXSingleParticleSpec*)aSpec
{
    mTargetSpec = aSpec;
    
    [self rebuildParticleSystem];
    
    mTimer = [NSTimer scheduledTimerWithTimeInterval:0.016 target:self selector:@selector(refreshProc:) userInfo:nil repeats:YES];
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

/*!
    @method     drawRect:
    @abstract   ビューの描画を行います。
 */
- (void)drawRect:(NSRect)rect
{
    NSRect frame = [self frame];
    
    CGLLockContext(mCGLContext);
    CGLSetCurrentContext(mCGLContext);

    glViewport(0, 0, frame.size.width, frame.size.height);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0.0, (double)frame.size.width, 0.0, (double)frame.size.height, -1.0, 1.0);
    glMatrixMode(GL_MODELVIEW);

    if (mTargetSpec != NULL) {
        mGraphics->clear([mTargetSpec bgColor1]);
    } else {
        mGraphics->clear(KRColor::Red);
    }

    if (mParticleSystem != NULL) {
        mParticleSystem->draw();
    }    
    
    KRTexture2D::processBatchedTexture2DDraws();

    CGLFlushDrawable(mCGLContext);
    CGLUnlockContext(mCGLContext);
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if (mTargetSpec != NULL) {
        NSPoint pos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        [mTargetSpec setGenerationPos:KRVector2D(pos.x, pos.y)];
    }
    
    mHasGeneratedParticle = NO;
    //mForceGenerate = YES;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if (mTargetSpec != NULL) {
        NSPoint pos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        [mTargetSpec setGenerationPos:KRVector2D(pos.x, pos.y)];
    }
    
    mHasGeneratedParticle = NO;  
}

- (void)mouseUp:(NSEvent *)theEvent
{
    mForceGenerate = NO;
}

@end

