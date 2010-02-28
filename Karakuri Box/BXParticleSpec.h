//
//  BXParticleSpec.h
//  Karakuri Box
//
//  Created by numata on 10/02/28.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#pragma once

#import "BXResourceElement.h"

#import "KarakuriTypes.h"
#import "KRGraphics.h"
#import "KRColor.h"
#import "KRParticle2DSystem.h"


@interface BXParticleSpec : BXResourceElement {
}
@end

@interface BXSingleParticleSpec : BXParticleSpec {
    KRColor     mBGColor1;
    KRBlendMode mBlendMode;
    KRColor     mColor;
    KRVector2D  mGravity;
    int         mImageTag;
    int         mLife;
    int         mMinAngleV;
    int         mMaxAngleV;
    
    BOOL        mDoLoop;
    KRVector2D  mGenerationPos;
}

- (KRParticle2DSystem*)createParticleSystem;

- (KRColor)bgColor1;
- (KRBlendMode)blendMode;
- (KRColor)color;
- (BOOL)doLoop;
- (KRVector2D)generationPos;
- (KRVector2D)gravity;
- (int)life;
- (int)maxAngleV;
- (int)minAngleV;

- (void)setBGColor1:(KRColor)color;
- (void)setBlendMode:(KRBlendMode)blendMode;
- (void)setColor:(KRColor)color;
- (void)setDoLoop:(BOOL)flag;
- (void)setGenerationPos:(KRVector2D)pos;
- (void)setGravityX:(double)value;
- (void)setGravityY:(double)value;
- (void)setImageTag:(int)tag;
- (void)setLife:(int)value;
- (void)setMaxAngleV:(int)value;
- (void)setMinAngleV:(int)value;

@end

@interface BXCompoundParticleSpec : BXParticleSpec {
}

@end


