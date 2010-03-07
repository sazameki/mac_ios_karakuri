//
//  BXParticleSpec.m
//  Karakuri Box
//
//  Created by numata on 10/02/28.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXParticleSpec.h"
#import "KRGraphics.h"


@implementation BXParticleSpec
@end


@implementation BXSingleParticleSpec

- (id)initWithName:(NSString*)name
{
    self = [super initWithName:name];
    if (self) {
        mBGColor1 = new KRColor();
        mColor = new KRColor();
        mGenerationPos = new KRVector2D();
        mGravity = new KRVector2D();
        mMaxV = new KRVector2D(8.0, 8.0);
        mMinV = new KRVector2D(-8.0, -8.0);

        *mBGColor1 = KRColor::Black;
        mDoLoop = NO;
        *mGenerationPos = KRVector2DZero;

        mImageTag = 109;

        mLife = 60;
        *mColor = KRColor::White;
        *mGravity = KRVector2DZero;
        mMinAngleV = -5;
        mMaxAngleV = 5;
        mDeltaScale = -1.0;
        mBlendMode = KRBlendModeAlpha;
        mGenerateCount = 5;
        mMaxParticleCount = 256;
        mDeltaRed = 0.0;
        mDeltaGreen = 0.0;
        mDeltaBlue = 0.0;
        mDeltaAlpha = -2.0;
    }
    return self;
}

- (void)dealloc
{
    delete mBGColor1;
    delete mColor;
    delete mGenerationPos;
    delete mGravity;
    delete mMaxV;
    delete mMinV;

    [super dealloc];
}


- (KRParticle2DSystem*)createParticleSystem
{
    KRParticle2DSystem* ret = new KRParticle2DSystem(mImageTag);
    ret->setGravity(*mGravity);
    ret->setLife(mLife);
    ret->setColor(*mColor);
    ret->setBlendMode(mBlendMode);

    double minAngleV = mMinAngleV * M_PI / 180.0;
    ret->setMinAngleV(minAngleV);
    
    double maxAngleV = mMaxAngleV * M_PI / 180.0;
    ret->setMaxAngleV(maxAngleV);
    
    ret->setMaxV(*mMaxV);
    ret->setMinV(*mMinV);
    
    ret->setScaleDelta(mDeltaScale);
    ret->setGenerateCount(mGenerateCount);
    ret->setParticleCount(mMaxParticleCount);
    
    ret->setColorDelta(mDeltaRed, mDeltaGreen, mDeltaBlue, mDeltaAlpha);

    return ret;
}


#pragma mark -

- (KRColor)bgColor1
{
    return *mBGColor1;
}

- (KRBlendMode)blendMode
{
    return mBlendMode;
}

- (KRColor)color
{
    return *mColor;
}

- (double)deltaScale
{
    return mDeltaScale;
}

- (double)deltaRed
{
    return mDeltaRed;
}

- (double)deltaGreen
{
    return mDeltaGreen;
}

- (double)deltaBlue
{
    return mDeltaBlue;
}

- (double)deltaAlpha
{
    return mDeltaAlpha;
}

- (BOOL)doLoop
{
    return mDoLoop;
}

- (int)generateCount
{
    return mGenerateCount;
}

- (KRVector2D)generationPos
{
    return *mGenerationPos;
}

- (KRVector2D)gravity
{
    return *mGravity;
}

- (int)life
{
    return mLife;
}

- (int)maxAngleV
{
    return mMaxAngleV;
}

- (int)minAngleV
{
    return mMinAngleV;
}

- (KRVector2D)maxV
{
    return *mMaxV;
}

- (KRVector2D)minV
{
    return *mMinV;
}

- (int)maxParticleCount
{
    return mMaxParticleCount;
}


#pragma mark -

- (void)setBGColor1:(KRColor)color
{
    *mBGColor1 = color;
}

- (void)setBlendMode:(KRBlendMode)blendMode
{
    mBlendMode = blendMode;
}

- (void)setColor:(KRColor)color
{
    *mColor = color;
}

- (void)setDeltaScale:(double)scale
{
    mDeltaScale = scale;
}

- (void)setDeltaRed:(double)value
{
    mDeltaRed = value;
}

- (void)setDeltaGreen:(double)value
{
    mDeltaGreen = value;
}

- (void)setDeltaBlue:(double)value
{
    mDeltaBlue = value;
}

- (void)setDeltaAlpha:(double)value
{
    mDeltaAlpha = value;
}

- (void)setDoLoop:(BOOL)flag
{
    mDoLoop = flag;
}

- (void)setGenerateCount:(int)count
{
    mGenerateCount = count;
}

- (void)setGenerationPos:(KRVector2D)pos
{
    *mGenerationPos = pos;
}

- (void)setGravityX:(double)value
{
    mGravity->x = value;
}

- (void)setGravityY:(double)value
{
    mGravity->y = value;
}

- (void)setImageTag:(int)tag
{
    mImageTag = tag;
}

- (void)setLife:(int)value
{
    mLife = value;
}

- (void)setMaxAngleV:(int)value
{
    mMaxAngleV = value;
}

- (void)setMinAngleV:(int)value
{
    mMinAngleV = value;
}

- (void)setMaxVX:(double)value
{
    mMaxV->x = value;
}

- (void)setMaxVY:(double)value
{
    mMaxV->y = value;
}

- (void)setMinVX:(double)value
{
    mMinV->x = value;
}

- (void)setMinVY:(double)value
{
    mMinV->y = value;
}

- (void)setMaxParticleCount:(int)count
{
    mMaxParticleCount = count;
}

@end


@implementation BXCompoundParticleSpec
@end



