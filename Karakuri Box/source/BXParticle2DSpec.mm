//
//  BXParticle2DSpec.m
//  Karakuri Box
//
//  Created by numata on 10/02/28.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXParticle2DSpec.h"
#import "KRGraphics.h"
#import "NSDictionary+LoadSave.h"
#import "BXDocument.h"
#import "NSFileHandle+BXExport.h"
#import "NSImage+BXEx.h"
#import "NSString+UUID.h"


@implementation BXParticle2DSpec
@end


@implementation BXSingleParticle2DSpec

- (id)initWithName:(NSString*)name
{
    self = [super initWithName:name];
    if (self) {
        mBGColor1 = new KRColor();
        mColor = new KRColor();
        mGenerationPos = new KRVector2D();
        mGravity = new KRVector2D();
        mMaxV = new KRVector2D(3.0, 0.0);
        mMinV = new KRVector2D(-3.0, 0.0);

        *mBGColor1 = KRColor::DimGray;
        mDoLoop = YES;
        *mGenerationPos = KRVector2DZero;

        mTexture2DResourceUUID = nil;

        mLife = 60;
        *mColor = KRColor::White;
        *mGravity = KRVector2D(0.0, 0.24);
        mMinAngleV = -5;
        mMaxAngleV = 5;
        mDeltaScale = -0.2;
        mBlendMode = KRBlendModeAddition;
        mGenerateCount = 1.0;
        mMaxParticleCount = 1;
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
    
    [mTexture2DResourceUUID release];

    [super dealloc];
}


- (KRParticle2DSystem*)createParticleSystem
{
    if (!mTexture2DResourceUUID) {
        return NULL;
    }
    
    std::string customPath = "";
    
    BXTexture2DSpec* texture = [[self document] tex2DWithUUID:mTexture2DResourceUUID];
    if (!texture) {
        return NULL;
    }

    KRParticle2DSystem* ret = new KRParticle2DSystem(texture);

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
    
    if ([self doLoop]) {
        ret->startAutoGeneration(0);
    }

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

- (double)generateCount
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

- (BXTexture2DSpec*)texture
{
    return [[self document] tex2DWithUUID:mTexture2DResourceUUID];
}


#pragma mark -
#pragma mark Setter

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

- (void)setGenerateCount:(double)count
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

- (void)setTexture:(BXTexture2DSpec*)texture;
{
    [mTexture2DResourceUUID release];
    mTexture2DResourceUUID = nil;
    
    if (texture) {
        mTexture2DResourceUUID = [[texture resourceUUID] copy];
    }
}


#pragma mark -
#pragma mark シリアライゼーションのサポート

- (NSDictionary*)elementInfo
{
    NSMutableDictionary* theInfo = [NSMutableDictionary dictionary];
    
    // 基本のIDと名前
    [theInfo setIntValue:mGroupID forName:@"Group ID"];
    [theInfo setIntValue:mResourceID forName:@"Resource ID"];
    [theInfo setStringValue:mResourceName forName:@"Resource Name"];
    
    // パーティクル色
    [theInfo setDoubleValue:mColor->r forName:@"Color Red"];
    [theInfo setDoubleValue:mColor->g forName:@"Color Green"];
    [theInfo setDoubleValue:mColor->b forName:@"Color Blue"];
    [theInfo setDoubleValue:mColor->a forName:@"Color Alpha"];
    
    // プレビューの背景色
    [theInfo setDoubleValue:mBGColor1->r forName:@"BG Color1 Red"];
    [theInfo setDoubleValue:mBGColor1->g forName:@"BG Color1 Green"];
    [theInfo setDoubleValue:mBGColor1->b forName:@"BG Color1 Blue"];
    [theInfo setDoubleValue:mBGColor1->a forName:@"BG Color1 Alpha"];
    
    // ブレンドモード
    [theInfo setIntValue:(int)mBlendMode forName:@"Blend Mode"];
    
    // 重力
    [theInfo setDoubleValue:mGravity->x forName:@"Gravity X"];
    [theInfo setDoubleValue:mGravity->y forName:@"Gravity Y"];
    
    // ライフ
    [theInfo setIntValue:mLife forName:@"Life"];
    
    // 最小・最大の角速度
    [theInfo setIntValue:mMaxAngleV forName:@"Max AngleV"];
    [theInfo setIntValue:mMinAngleV forName:@"Min AngleV"];

    // 最小・最大の速度
    [theInfo setDoubleValue:mMaxV->x forName:@"Max VX"];
    [theInfo setDoubleValue:mMaxV->y forName:@"Max VY"];
    [theInfo setDoubleValue:mMinV->x forName:@"Min VX"];
    [theInfo setDoubleValue:mMinV->y forName:@"Min VY"];

    // スケールの変化量
    [theInfo setDoubleValue:mDeltaScale forName:@"Delta Scale"];

    // 色の変化量
    [theInfo setDoubleValue:mDeltaRed forName:@"Delta Red"];
    [theInfo setDoubleValue:mDeltaGreen forName:@"Delta Green"];
    [theInfo setDoubleValue:mDeltaBlue forName:@"Delta Blue"];
    [theInfo setDoubleValue:mDeltaAlpha forName:@"Delta Alpha"];

    // フレーム当たりの生成量
    [theInfo setDoubleValue:mGenerateCount forName:@"Generate Count"];

    // 最大生成数
    [theInfo setIntValue:mMaxParticleCount forName:@"Max Particle Count"];
    
    // ループ再生
    [theInfo setBoolValue:mDoLoop forName:@"Do Loop"];
    
    // パーティクルの生成位置
    [theInfo setDoubleValue:mGenerationPos->x forName:@"Generation Pos X"];
    [theInfo setDoubleValue:mGenerationPos->y forName:@"Generation Pos Y"];
    
    // 画像
    if (mTexture2DResourceUUID) {
        [theInfo setStringValue:mTexture2DResourceUUID forName:@"Texture UUID"];
        
        BXTexture2DSpec* tex = [[self document] tex2DWithUUID:mTexture2DResourceUUID];
        if (tex) {
            [theInfo setIntValue:[tex resourceID] forName:@"Texture ID"];
        } else {
            [theInfo removeObjectForKey:@"Texture ID"];
        }
    } else {
        [theInfo removeObjectForKey:@"Texture UUID"];
        [theInfo removeObjectForKey:@"Texture ID"];
    }

    return theInfo;
}

- (void)restoreElementInfo:(NSDictionary*)theInfo document:(BXDocument*)document
{
    ///// 基本のIDと名前
    mGroupID = [theInfo intValueForName:@"Group ID" currentValue:mGroupID];
    mResourceID = [theInfo intValueForName:@"Resource ID" currentValue:mResourceID];
    [self setResourceName:[theInfo stringValueForName:@"Resource Name" currentValue:mResourceName]];

    ///// パーティクル色
    mColor->r = [theInfo doubleValueForName:@"Color Red" currentValue:mColor->r];
    mColor->g = [theInfo doubleValueForName:@"Color Green" currentValue:mColor->g];
    mColor->b = [theInfo doubleValueForName:@"Color Blue" currentValue:mColor->b];
    mColor->a = [theInfo doubleValueForName:@"Color Alpha" currentValue:mColor->a];

    // プレビューの背景色
    mBGColor1->r = [theInfo doubleValueForName:@"BG Color1 Red" currentValue:mBGColor1->r];
    mBGColor1->g = [theInfo doubleValueForName:@"BG Color1 Green" currentValue:mBGColor1->g];
    mBGColor1->b = [theInfo doubleValueForName:@"BG Color1 Blue" currentValue:mBGColor1->b];
    mBGColor1->a = [theInfo doubleValueForName:@"BG Color1 Alpha" currentValue:mBGColor1->a];

    // ブレンドモード
    mBlendMode = (KRBlendMode)[theInfo intValueForName:@"Blend Mode" currentValue:(int)mBlendMode];
    
    // 重力
    mGravity->x = [theInfo doubleValueForName:@"Gravity X" currentValue:mGravity->x];
    mGravity->y = [theInfo doubleValueForName:@"Gravity Y" currentValue:mGravity->y];

    // ライフ
    mLife = [theInfo intValueForName:@"Life" currentValue:mLife];

    // 最小・最大の角速度
    mMaxAngleV = [theInfo intValueForName:@"Max AngleV" currentValue:mMaxAngleV];
    mMinAngleV = [theInfo intValueForName:@"Min AngleV" currentValue:mMinAngleV];
    
    // 最小・最大の速度
    mMaxV->x = [theInfo doubleValueForName:@"Max VX" currentValue:mMaxV->x];
    mMaxV->y = [theInfo doubleValueForName:@"Max VY" currentValue:mMaxV->y];
    mMinV->x = [theInfo doubleValueForName:@"Min VX" currentValue:mMinV->x];
    mMinV->y = [theInfo doubleValueForName:@"Min VY" currentValue:mMinV->y];

    // スケールの変化量
    mDeltaScale = [theInfo doubleValueForName:@"Delta Scale" currentValue:mDeltaScale];

    // 色の変化量
    mDeltaRed = [theInfo doubleValueForName:@"Delta Red" currentValue:mDeltaRed];
    mDeltaGreen = [theInfo doubleValueForName:@"Delta Green" currentValue:mDeltaGreen];
    mDeltaBlue = [theInfo doubleValueForName:@"Delta Blue" currentValue:mDeltaBlue];
    mDeltaAlpha = [theInfo doubleValueForName:@"Delta Alpha" currentValue:mDeltaAlpha];
    
    // フレーム当たりの生成量
    mGenerateCount = [theInfo doubleValueForName:@"Generate Count" currentValue:mGenerateCount];
    
    // 最大生成数
    mMaxParticleCount = [theInfo intValueForName:@"Max Particle Count" currentValue:mMaxParticleCount];
    
    // ループ再生
    mDoLoop = [theInfo boolValueForName:@"Do Loop" currentValue:mDoLoop];
    
    // パーティクルの生成位置
    mGenerationPos->x = [theInfo doubleValueForName:@"Generation Pos X" currentValue:mGenerationPos->x];
    mGenerationPos->y = [theInfo doubleValueForName:@"Generation Pos Y" currentValue:mGenerationPos->y];

    // 画像
    mTexture2DResourceUUID = [[theInfo stringValueForName:@"Texture UUID" currentValue:mTexture2DResourceUUID] copy];
}

@end


@implementation BXSingleParticle2DSpec (Export)

- (void)exportUnsignedIntValue:(unsigned)value fileHandle:(NSFileHandle*)fileHandle
{
    unsigned char buffer[4];
    
    buffer[0] = (unsigned char)((value >> 24) & 0xff);
    buffer[1] = (unsigned char)((value >> 16) & 0xff);
    buffer[2] = (unsigned char)((value >> 8) & 0xff);
    buffer[3] = (unsigned char)(value & 0xff);
    
    NSData* data = [[NSData alloc] initWithBytesNoCopy:buffer length:4 freeWhenDone:NO];
    [fileHandle writeData:data];
    [data release];
}

- (void)exportToFileHandle:(NSFileHandle*)fileHandle
{
    // ヘッダの書き出し
    [fileHandle writeBuffer:"KRP2" length:4];
    
    // リソース情報の書き出し
    NSDictionary* elementInfo = [self elementInfo];    
    
    NSString* errorStr = nil;
    NSData* infoData = [NSPropertyListSerialization dataFromPropertyList:elementInfo
                                                                  format:NSPropertyListBinaryFormat_v1_0
                                                        errorDescription:&errorStr];
    [fileHandle writeUnsignedIntValue:[infoData length]];
    [fileHandle writeData:infoData];    
}

@end


@implementation BXCompoundParticle2DSpec
@end



