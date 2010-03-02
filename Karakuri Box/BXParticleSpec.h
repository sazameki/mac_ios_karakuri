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
    KRColor*    mBGColor1;
    KRBlendMode mBlendMode;
    KRColor*    mColor;
    KRVector2D* mGravity;
    int         mImageTag;
    int         mLife;
    int         mMinAngleV;
    int         mMaxAngleV;
    KRVector2D* mMaxV;
    KRVector2D* mMinV;
    double      mDeltaScale;
    double      mDeltaRed;
    double      mDeltaGreen;
    double      mDeltaBlue;
    double      mDeltaAlpha;
    int         mGenerateCount;
    int         mMaxParticleCount;
    
    BOOL        mDoLoop;
    KRVector2D  *mGenerationPos;
}

- (KRParticle2DSystem*)createParticleSystem;

- (KRColor)bgColor1;
- (KRBlendMode)blendMode;
- (KRColor)color;
- (double)deltaScale;
- (double)deltaRed;
- (double)deltaGreen;
- (double)deltaBlue;
- (double)deltaAlpha;
- (BOOL)doLoop;
- (int)generateCount;
- (KRVector2D)generationPos;
- (KRVector2D)gravity;
- (int)life;
- (int)maxAngleV;
- (int)minAngleV;
- (KRVector2D)maxV;
- (KRVector2D)minV;
- (int)maxParticleCount;

- (void)setBGColor1:(KRColor)color;
- (void)setBlendMode:(KRBlendMode)blendMode;
- (void)setColor:(KRColor)color;
- (void)setDeltaScale:(double)scale;
- (void)setDeltaRed:(double)value;
- (void)setDeltaGreen:(double)value;
- (void)setDeltaBlue:(double)value;
- (void)setDeltaAlpha:(double)value;
- (void)setDoLoop:(BOOL)flag;
- (void)setGenerateCount:(int)count;
- (void)setGenerationPos:(KRVector2D)pos;
- (void)setGravityX:(double)value;
- (void)setGravityY:(double)value;
- (void)setImageTag:(int)tag;
- (void)setLife:(int)value;
- (void)setMaxAngleV:(int)value;
- (void)setMinAngleV:(int)value;
- (void)setMaxVX:(double)value;
- (void)setMaxVY:(double)value;
- (void)setMinVX:(double)value;
- (void)setMinVY:(double)value;
- (void)setMaxParticleCount:(int)count;

@end

@interface BXCompoundParticleSpec : BXParticleSpec {
}

@end


