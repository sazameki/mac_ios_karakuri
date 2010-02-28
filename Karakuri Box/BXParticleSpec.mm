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
        mBGColor1 = KRColor::Black;
        mDoLoop = NO;
        mGenerationPos = KRVector2DZero;

        mImageTag = 109;

        mLife = 60;
        mColor = KRColor::White;
        mGravity = KRVector2DZero;
        mMinAngleV = -5;
        mMaxAngleV = 5;
        mBlendMode = KRBlendModeAlpha;        
    }
    return self;
}

- (KRParticle2DSystem*)createParticleSystem
{
    KRParticle2DSystem* ret = new KRParticle2DSystem(mImageTag);
    ret->setGravity(mGravity);
    ret->setLife(mLife);
    ret->setColor(mColor);
    ret->setBlendMode(mBlendMode);

    double minAngleV = mMinAngleV * M_PI / 180.0;
    ret->setMinAngleV(minAngleV);
    
    double maxAngleV = mMaxAngleV * M_PI / 180.0;
    ret->setMaxAngleV(maxAngleV);

    return ret;
}


#pragma mark -

- (KRColor)bgColor1
{
    return mBGColor1;
}

- (KRBlendMode)blendMode
{
    return mBlendMode;
}

- (KRColor)color
{
    return mColor;
}

- (BOOL)doLoop
{
    return mDoLoop;
}

- (KRVector2D)generationPos
{
    return mGenerationPos;
}

- (KRVector2D)gravity
{
    return mGravity;
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


#pragma mark -

- (void)setBGColor1:(KRColor)color
{
    mBGColor1 = color;
}

- (void)setBlendMode:(KRBlendMode)blendMode
{
    mBlendMode = blendMode;
}

- (void)setColor:(KRColor)color
{
    mColor = color;
}

- (void)setDoLoop:(BOOL)flag
{
    mDoLoop = flag;
}

- (void)setGenerationPos:(KRVector2D)pos
{
    mGenerationPos = pos;
}

- (void)setGravityX:(double)value
{
    mGravity.x = value;
}

- (void)setGravityY:(double)value
{
    mGravity.y = value;
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

@end


@implementation BXCompoundParticleSpec
@end



