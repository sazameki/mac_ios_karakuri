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
        mMaxV = new KRVector2D(8.0, 8.0);
        mMinV = new KRVector2D(-8.0, -8.0);

        *mBGColor1 = KRColor::Black;
        mDoLoop = NO;
        *mGenerationPos = KRVector2DZero;

        mImageTag = 109;
        mImageTicket = nil;

        mLife = 60;
        *mColor = KRColor::White;
        *mGravity = KRVector2DZero;
        mMinAngleV = -5;
        mMaxAngleV = 5;
        mDeltaScale = -1.0;
        mBlendMode = KRBlendModeAddition;
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
    
    [mImageTicket release];

    [super dealloc];
}


- (KRParticle2DSystem*)createParticleSystem
{    
    std::string customPath = "";
    
    if (mImageTag == 999) {
        BXResourceFileManager* fileManager = [[self document] fileManager];
        NSString* imagePath = [fileManager pathForTicket:mImageTicket];
        customPath = [imagePath cStringUsingEncoding:NSUTF8StringEncoding];
    }
    
    KRParticle2DSystem* ret = new KRParticle2DSystem(mImageTag, customPath);

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

- (int)imageTag
{
    return mImageTag;
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

- (void)setImageAtPath:(NSString*)path
{
    mImageTag = 999;
    
    if (mImageTicket) {
        [mImageTicket release];
    }
    
    BXResourceFileManager* fileManager = [[self document] fileManager];
    mImageTicket = [[fileManager storeFileAtPath:path] copy];
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
    [theInfo setIntValue:mGenerateCount forName:@"Generate Count"];

    // 最大生成数
    [theInfo setIntValue:mMaxParticleCount forName:@"Max Particle Count"];
    
    // ループ再生
    [theInfo setBoolValue:mDoLoop forName:@"Do Loop"];
    
    // パーティクルの生成位置
    [theInfo setDoubleValue:mGenerationPos->x forName:@"Generation Pos X"];
    [theInfo setDoubleValue:mGenerationPos->y forName:@"Generation Pos Y"];
    
    // 画像
    [theInfo setIntValue:mImageTag forName:@"Image Tag"];
    if (mImageTicket) {
        [theInfo setStringValue:mImageTicket forName:@"Image Ticket"];
    } else {
        [theInfo removeObjectForKey:@"Image Ticket"];
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
    mGenerateCount = [theInfo intValueForName:@"Generate Count" currentValue:mGenerateCount];
    
    // 最大生成数
    mMaxParticleCount = [theInfo intValueForName:@"Max Particle Count" currentValue:mMaxParticleCount];
    
    // ループ再生
    mDoLoop = [theInfo boolValueForName:@"Do Loop" currentValue:mDoLoop];
    
    // パーティクルの生成位置
    mGenerationPos->x = [theInfo doubleValueForName:@"Generation Pos X" currentValue:mGenerationPos->x];
    mGenerationPos->y = [theInfo doubleValueForName:@"Generation Pos Y" currentValue:mGenerationPos->y];

    // 画像
    mImageTag = [theInfo intValueForName:@"Image Tag" currentValue:mImageTag];
    mImageTicket = [[theInfo stringValueForName:@"Image Ticket" currentValue:mImageTicket] copy];
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
    
    // リソースの書き出し
    if (mImageTicket && [mImageTicket length] > 0) {
        BXResourceFileManager* fileManager = [[self document] fileManager];
        NSImage* image = [fileManager image72dpiForTicket:mImageTicket];
        NSData* pngData = [image pngData];
        
        NSMutableDictionary* texInfo = [NSMutableDictionary dictionary];
        [texInfo setObject:mImageTicket forKey:@"Ticket"];
        [texInfo setObject:[fileManager resourceNameForTicket:mImageTicket] forKey:@"Resource Name"];
        NSData* texInfoData = [NSPropertyListSerialization dataFromPropertyList:texInfo
                                                                         format:NSPropertyListBinaryFormat_v1_0
                                                               errorDescription:&errorStr];
        
        // ヘッダ
        [fileHandle writeBuffer:"KRPR" length:4];
        [fileHandle writeUnsignedIntValue:[texInfoData length]];
        [fileHandle writeData:texInfoData];

        // データ
        [fileHandle writeBuffer:"KRIM" length:4];
        [fileHandle writeUnsignedIntValue:[pngData length]];
        [fileHandle writeData:pngData];
    }
}

@end


@implementation BXCompoundParticle2DSpec
@end



