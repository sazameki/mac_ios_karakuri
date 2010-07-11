//
//  BXResourceImporter.mm
//  Karakuri Library
//
//  Created by numata on 10/03/17.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXResourceImporter.h"

#include "KarakuriException.h"

#import "KRTexture2DManager.h"


@implementation BXImportContext

- (id)initWithFileAtPath:(NSString*)filepath
{
    self = [super init];
    if (self) {
        mData = [[NSData alloc] initWithContentsOfMappedFile:filepath];
        mPos = 0;
    }
    return self;
}

- (void)dealloc
{
    [mData release];
    [super dealloc];
}

- (BOOL)checkMagic:(const char*)magic
{
    unsigned char* buffer[4];
    
    [self readBytes:buffer length:4];
    
    return (strncmp(magic, (const char*)buffer, 4) == 0)? YES: NO;
}

- (BXResourceType)checkResourceType
{
    unsigned char* buffer[4];    
    [self readBytes:buffer length:4];
    
    if (strncmp("KRED", (const char*)buffer, 4) == 0) {
        return BXResourceTypeEndMark;
    }
    else if (strncmp("KRC2", (const char*)buffer, 4) == 0) {
        return BXResourceTypeChara2D;
    }
    else if (strncmp("KRP2", (const char*)buffer, 4) == 0) {
        return BXResourceTypeParticle2D;
    }
    else if (strncmp("KRT2", (const char*)buffer, 4) == 0) {
        return BXResourceTypeTexture2D;
    }
    else if (strncmp("KRDT", (const char*)buffer, 4) == 0) {
        return BXResourceTypeData;
    }
    
    NSLog(@"Unknown Resource Header: %c%c%c%c (0x%06X)", buffer[0], buffer[1], buffer[2], buffer[3], mPos-4);
    
    return BXResourceTypeUnknown;
}

- (unsigned)currentPos
{
    return mPos;
}

- (void)reset
{
    mPos = 0;
}

- (void)readBytes:(void*)buffer length:(unsigned)length
{
    [mData getBytes:buffer range:NSMakeRange(mPos, length)];
    mPos += length;
}

- (NSData*)readDataWithLength:(unsigned)length
{
    NSData* ret = [mData subdataWithRange:NSMakeRange(mPos, length)];
    
    mPos += length;
    
    return ret;
}

- (unsigned)readUnsignedIntValue
{
    unsigned char buffer[4];
    
    [mData getBytes:buffer range:NSMakeRange(mPos, 4)];
    mPos += 4;
    
    return ((buffer[0] << 24) | (buffer[1] << 16) | (buffer[2] << 8) | buffer[3]);
}

- (void)skip:(unsigned)length
{
    mPos += length;
}

@end


@implementation BXResourceImporter

- (id)initWithFileName:(NSString*)fileName
{
    self = [super init];
    if (self) {
        NSString* filepath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        if (!filepath) {
            [self release];
            return nil;
        }
        
        mContext = [[BXImportContext alloc] initWithFileAtPath:filepath];
        mFileName = [fileName copy];
    }
    return self;
}

- (void)dealloc
{
    [mContext release];
    [mFileName release];

    [super dealloc];
}

- (void)skipChara2D
{
    unsigned infoSize = [mContext readUnsignedIntValue];
    [mContext skip:infoSize];
}

- (void)skipParticle2D
{
    unsigned infoSize = [mContext readUnsignedIntValue];
    [mContext skip:infoSize];
}

- (void)importChara2D
{
    unsigned infoSize = [mContext readUnsignedIntValue];
    NSData* data = [mContext readDataWithLength:infoSize];
    
    NSString* errorStr = nil;
    NSDictionary* chara2DInfo = [NSPropertyListSerialization propertyListFromData:data
                                                                 mutabilityOption:NSPropertyListImmutable
                                                                           format:nil
                                                                 errorDescription:&errorStr];
    
    int resourceID = [[chara2DInfo objectForKey:@"Resource ID"] intValue];
    int groupID = [[chara2DInfo objectForKey:@"Group ID"] intValue];
    NSString* resourceName = [chara2DInfo objectForKey:@"Resource Name"];

    _KRChara2DSpec* chara2DSpec = new _KRChara2DSpec(groupID, std::string([resourceName cStringUsingEncoding:NSUTF8StringEncoding]));

    NSArray* imageInfos = [chara2DInfo objectForKey:@"Image Infos"];
    for (int i = 0; i < [imageInfos count]; i++) {
        NSDictionary* anImageInfo = [imageInfos objectAtIndex:i];
        int divX = [[anImageInfo objectForKey:@"Div X"] intValue];
        int divY = [[anImageInfo objectForKey:@"Div Y"] intValue];
        NSString* ticket = [anImageInfo objectForKey:@"Image Ticket"];
        gKRTex2DMan->_setDivForTicket([ticket cStringUsingEncoding:NSUTF8StringEncoding], divX, divY);
    }
    
    NSArray* motionInfos = [chara2DInfo objectForKey:@"State Infos"];
    for (int i = 0; i < [motionInfos count]; i++) {
        NSDictionary* aMotionInfo = [motionInfos objectAtIndex:i];
        
        //NSString* stateName = [aStateInfo objectForKey:@"State Name"];
        int motionID = [[aMotionInfo objectForKey:@"State ID"] intValue];
        int nextMotionID = [[aMotionInfo objectForKey:@"Next Motion ID"] intValue];
        int cancelKomaNumber = [[aMotionInfo objectForKey:@"Cancel Koma"] intValue]; // キャンセル時の終了アニメーション開始コマ
        
        _KRChara2DMotion* aMotion = new _KRChara2DMotion();
        aMotion->initForBoxChara2D(cancelKomaNumber, nextMotionID);

        int defaultInterval = [[aMotionInfo objectForKey:@"Default Interval"] intValue]; // キャンセル時の終了アニメーション開始コマ

        NSArray* komaInfos = [aMotionInfo objectForKey:@"Koma Infos"];
        for (int j = 0; j < [komaInfos count]; j++) {
            NSDictionary* aKomaInfo = [komaInfos objectAtIndex:j];
            
            int interval = [[aKomaInfo objectForKey:@"Interval"] intValue];
            if (interval == 0) {
                interval = defaultInterval;
            }
            //int komaNumber = [[aKomaInfo objectForKey:@"Koma Number"] intValue];
            NSString* imageTicket = [aKomaInfo objectForKey:@"Image Ticket"];
            int atlasIndex = [[aKomaInfo objectForKey:@"Atlas Index"] intValue];
            BOOL isCancelable = [[aKomaInfo objectForKey:@"Cancelable"] boolValue];
            int gotoTarget = [[aKomaInfo objectForKey:@"Goto Target"] intValue];

            NSArray* hitInfos = [aKomaInfo objectForKey:@"Hit Infos"];

            _KRChara2DKoma* aKoma = new _KRChara2DKoma();
            aKoma->_importHitArea(hitInfos);
            aKoma->initForBoxChara2D([imageTicket cStringUsingEncoding:NSUTF8StringEncoding], atlasIndex, interval,
                                     (isCancelable? true: false), gotoTarget);
            aMotion->addKoma(aKoma);
        }
        
        chara2DSpec->addMotion(motionID, aMotion);
    }

    gKRAnime2DMan->_addCharaSpec(resourceID, chara2DSpec);
}

- (void)importParticle2D
{
    unsigned infoSize = [mContext readUnsignedIntValue];
    NSData* data = [mContext readDataWithLength:infoSize];
    
    NSString* errorStr = nil;
    NSDictionary* particle2DInfo = [NSPropertyListSerialization propertyListFromData:data
                                                                    mutabilityOption:NSPropertyListImmutable
                                                                              format:nil
                                                                    errorDescription:&errorStr];
    
    int particleID = [[particle2DInfo objectForKey:@"Resource ID"] intValue];
    int groupID = [[particle2DInfo objectForKey:@"Group ID"] intValue];
    NSString* imageTicket = [particle2DInfo objectForKey:@"Image Ticket"];
    
    gKRAnime2DMan->_addParticle2DWithTicket(particleID, groupID, [imageTicket cStringUsingEncoding:NSUTF8StringEncoding]);
    
    KRBlendMode blendMode = KRBlendModeAddition;
    KRColor color = KRColor::White;
    KRVector2D gravity;
    int life = 60;
    int maxAngleV = 5;
    int minAngleV = -5;
    KRVector2D maxV;
    KRVector2D minV;
    double deltaScale = -1.0;
    double deltaRed = 0.0;
    double deltaGreen = 0.0;
    double deltaBlue = 0.0;
    double deltaAlpha = -2.0;
    int generateCount = 5;
    int maxParticleCount = 256;
    
    // パーティクル色
    if ([particle2DInfo objectForKey:@"Color Red"]) {
        color.r = [[particle2DInfo objectForKey:@"Color Red"] doubleValue];
    }
    if ([particle2DInfo objectForKey:@"Color Green"]) {
        color.g = [[particle2DInfo objectForKey:@"Color Green"] doubleValue];
    }
    if ([particle2DInfo objectForKey:@"Color Blue"]) {
        color.b = [[particle2DInfo objectForKey:@"Color Blue"] doubleValue];
    }
    if ([particle2DInfo objectForKey:@"Color Alpha"]) {
        color.a = [[particle2DInfo objectForKey:@"Color Alpha"] doubleValue];
    }

    // ブレンドモード
    if ([particle2DInfo objectForKey:@"Blend Mode"]) {
        blendMode = (KRBlendMode)[[particle2DInfo objectForKey:@"Blend Mode"] intValue];
    }
    
    // 重力
    if ([particle2DInfo objectForKey:@"Gravity X"]) {
        gravity.x = [[particle2DInfo objectForKey:@"Gravity X"] doubleValue];
    }
    if ([particle2DInfo objectForKey:@"Gravity Y"]) {
        gravity.y = [[particle2DInfo objectForKey:@"Gravity Y"] doubleValue];
    }
    
    // ライフ
    if ([particle2DInfo objectForKey:@"Life"]) {
        life = [[particle2DInfo objectForKey:@"Life"] intValue];
    }
    
    // 最小・最大の角速度
    if ([particle2DInfo objectForKey:@"Max AngleV"]) {
        maxAngleV = [[particle2DInfo objectForKey:@"Max AngleV"] intValue];
    }
    if ([particle2DInfo objectForKey:@"Min AngleV"]) {
        minAngleV = [[particle2DInfo objectForKey:@"Min AngleV"] intValue];
    }
    
    // 最小・最大の速度
    if ([particle2DInfo objectForKey:@"Max VX"]) {
        maxV.x = [[particle2DInfo objectForKey:@"Max VX"] doubleValue];
    }
    if ([particle2DInfo objectForKey:@"Max VY"]) {
        maxV.y = [[particle2DInfo objectForKey:@"Max VY"] doubleValue];
    }
    if ([particle2DInfo objectForKey:@"Min VX"]) {
        minV.x = [[particle2DInfo objectForKey:@"Min VX"] doubleValue];
    }
    if ([particle2DInfo objectForKey:@"Min VY"]) {
        minV.y = [[particle2DInfo objectForKey:@"Min VY"] doubleValue];
    }
    
    // スケールの変化量
    if ([particle2DInfo objectForKey:@"Delta Scale"]) {
        deltaScale = [[particle2DInfo objectForKey:@"Delta Scale"] doubleValue];
    }
    
    // 色の変化量
    if ([particle2DInfo objectForKey:@"Delta Red"]) {
        deltaRed = [[particle2DInfo objectForKey:@"Delta Red"] doubleValue];
    }
    if ([particle2DInfo objectForKey:@"Delta Green"]) {
        deltaGreen = [[particle2DInfo objectForKey:@"Delta Green"] doubleValue];
    }
    if ([particle2DInfo objectForKey:@"Delta Blue"]) {
        deltaBlue = [[particle2DInfo objectForKey:@"Delta Blue"] doubleValue];
    }
    if ([particle2DInfo objectForKey:@"Delta Alpha"]) {
        deltaAlpha = [[particle2DInfo objectForKey:@"Delta Alpha"] doubleValue];
    }
    
    // フレーム当たりの生成量
    if ([particle2DInfo objectForKey:@"Generate Count"]) {
        generateCount = [[particle2DInfo objectForKey:@"Generate Count"] intValue];
    }
    
    // 最大生成数
    if ([particle2DInfo objectForKey:@"Max Particle Count"]) {
        maxParticleCount = [[particle2DInfo objectForKey:@"Max Particle Count"] intValue];
    }
    
    _KRParticle2DSystem* particleSys = gKRAnime2DMan->_getParticleSystem(particleID);
    
    particleSys->setColor(color);
    particleSys->setBlendMode(blendMode);
    particleSys->setGravity(gravity);
    particleSys->setLife(life);
    particleSys->setParticleCount(maxParticleCount);
    particleSys->setGenerateCount(generateCount);
    particleSys->setMinAngleV(minAngleV * M_PI / 180.0);
    particleSys->setMaxAngleV(maxAngleV * M_PI / 180.0);
    particleSys->setMaxV(maxV);
    particleSys->setMinV(minV);
    particleSys->setScaleDelta(deltaScale);
    particleSys->setColorDelta(deltaRed, deltaGreen, deltaBlue, deltaAlpha);
}

- (void)skipTexture2D
{
    unsigned infoSize = [mContext readUnsignedIntValue];
    [mContext skip:infoSize];

    if ([mContext checkResourceType] != BXResourceTypeData) {
        throw KRRuntimeError("KRGameManager::addResources(): Resource data is lacking: 0x%06x", [mContext currentPos]-4);
    }
    
    unsigned dataLength = [mContext readUnsignedIntValue];
    [mContext skip:dataLength];
}

- (void)importTexture2D
{
    unsigned infoSize = [mContext readUnsignedIntValue];
    NSData* data = [mContext readDataWithLength:infoSize];

    NSString* errorStr = nil;
    NSDictionary* tex2DInfo = [NSPropertyListSerialization propertyListFromData:data
                                                               mutabilityOption:NSPropertyListImmutable
                                                                         format:nil
                                                               errorDescription:&errorStr];
    
    if ([mContext checkResourceType] != BXResourceTypeData) {
        throw KRRuntimeError("KRGameManager::addResources(): Resource data is lacking: 0x%06x", [mContext currentPos]-4);
    }

    unsigned dataLength = [mContext readUnsignedIntValue];
    unsigned dataStartPos = [mContext currentPos];

    int groupID = [[tex2DInfo objectForKey:@"Group ID"] intValue];
    NSString* resourceName = [tex2DInfo objectForKey:@"Resource Name"];
    NSString* ticket = [tex2DInfo objectForKey:@"Ticket"];
    
    gKRTex2DMan->_addTexture(groupID,
                             [resourceName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ticket cStringUsingEncoding:NSUTF8StringEncoding],
                             [mFileName cStringUsingEncoding:NSUTF8StringEncoding],
                             dataStartPos, dataLength);

    [mContext skip:dataLength];
}

- (void)importPrimitiveResources
{
    [mContext reset];

    // MAGIC
    if (![mContext checkMagic:"KRRS"]) {
        throw KRRuntimeError("KRGameManager::addResources(): Invalid resource file header.");
    }
    
    // Version numbers
    //unsigned majorVersion = [mContext readUnsignedIntValue];
    [mContext skip:4];
    //unsigned minorVersion = [mContext readUnsignedIntValue];
    [mContext skip:4];
    
    while (YES) {
        BXResourceType type = [mContext checkResourceType];
        
        // リソースの終端
        if (type == BXResourceTypeEndMark) {
            break;
        }
        // 2Dキャラクタ
        else if (type == BXResourceTypeChara2D) {
            [self skipChara2D];
        }
        // 2Dパーティクル
        else if (type == BXResourceTypeParticle2D) {
            [self skipParticle2D];
        }
        // 2Dテクスチャ
        else if (type == BXResourceTypeTexture2D) {
            [self importTexture2D];
        }
        // 未知のタイプ
        else {
            throw KRRuntimeError("Unknown resource header appeared!!");
        }
    }    
}

- (void)importRichResources
{
    [mContext reset];

    // MAGIC
    if (![mContext checkMagic:"KRRS"]) {
        throw KRRuntimeError("KRGameManager::addResources(): Invalid resource file header.");
    }
    
    // Version numbers
    //unsigned majorVersion = [mContext readUnsignedIntValue];
    [mContext skip:4];
    //unsigned minorVersion = [mContext readUnsignedIntValue];
    [mContext skip:4];

    while (YES) {
        BXResourceType type = [mContext checkResourceType];

        // リソースの終端
        if (type == BXResourceTypeEndMark) {
            break;
        }
        // 2Dキャラクタ
        else if (type == BXResourceTypeChara2D) {
            [self importChara2D];
        }
        // 2Dパーティクル
        else if (type == BXResourceTypeParticle2D) {
            [self importParticle2D];
        }
        // 2Dテクスチャ
        else if (type == BXResourceTypeTexture2D) {
            [self skipTexture2D];
        }
        // 未知のタイプ
        else {
            throw KRRuntimeError("Unknown resource header appeared!!");
        }
    }
}

@end


