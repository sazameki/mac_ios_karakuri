//
//  BXParticle2DSimulatorView.h
//  Karakuri Box
//
//  Created by numata on 10/02/28.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXOpenGLView.h"

#import "BXParticle2DSpec.h"
#import "KRTexture2D.h"
#import "KRParticle2DSystem.h"


@interface BXParticle2DSimulatorView : BXOpenGLView {
    BXSingleParticle2DSpec*    mTargetSpec;

    KRParticle2DSystem*     mParticleSystem;    
    NSTimer*                mTimer;
    
    BOOL                    mHasGeneratedParticle;
    BOOL                    mForceGenerate;
}

- (void)setupForParticleSpec:(BXSingleParticle2DSpec*)aSpec;
- (void)releaseParticles;

- (void)rebuildParticleSystem;

@end

