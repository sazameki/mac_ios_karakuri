//
//  BXParticleSimulatorView.h
//  Karakuri Box
//
//  Created by numata on 10/02/28.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXOpenGLView.h"

#import "BXParticleSpec.h"
#import "KRTexture2D.h"
#import "KRParticle2DSystem.h"


@interface BXParticleSimulatorView : BXOpenGLView {
    BXSingleParticleSpec*    mTargetSpec;

    KRParticle2DSystem*     mParticleSystem;    
    NSTimer*                mTimer;
    
    BOOL                    mHasGeneratedParticle;
    BOOL                    mForceGenerate;
}

- (void)setupForParticleSpec:(BXSingleParticleSpec*)aSpec;
- (void)releaseParticles;

- (void)rebuildParticleSystem;

@end

