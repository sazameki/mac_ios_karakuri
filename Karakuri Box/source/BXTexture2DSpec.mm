//
//  BXTex2DSpec.m
//  Karakuri Box
//
//  Created by numata on 10/09/20.
//  Copyright 2010 Satoshi Numata. All rights reserved.
//

#import "BXTexture2DSpec.h"
#import "BXDocument.h"
#import "NSDictionary+LoadSave.h"
#import "NSFileHandle+BXExport.h"
#import "NSImage+BXEx.h"
#import "NSString+UUID.h"
#import "BXTexture2DAtlas.h"


@implementation BXTexture2DSpec

- (id)initWithName:(NSString*)name
{
    self = [super initWithName:name];
    if (self) {
        mPreviewScale = 1.0;
        mAtlasInfos = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [mImageTicket release];
    [mImageName release];
    [mImageID release];

    [mAtlasInfos release];

    [super dealloc];
}

- (void)setImageWithFileAtPath:(NSString*)path
{
    [mImageTicket release];
    mImageTicket = [[[mDocument fileManager] storeFileAtPath:path] copy];
    [self setImageName:[path lastPathComponent]];
    
    [mImageID release];
    mImageID = [[NSString generateUUIDString] retain];
}

- (NSString*)imageName
{
    return mImageName;
}

- (void)setImageName:(NSString*)str
{
    [mImageName release];
    mImageName = [str copy];
}

- (NSString*)imageTicket
{
    return mImageTicket;
}

- (NSImage*)image72dpi
{
    return [[mDocument fileManager] image72dpiForTicket:mImageTicket];
}

- (double)previewScale
{
    return mPreviewScale;
}

- (void)setPreviewScale:(double)scale
{
    mPreviewScale = scale;
}

- (int)allAtlasPieceCount
{
    int atlasCount = [mAtlasInfos count];
    int ret = 0;
    for (int i = 0; i < atlasCount; i++) {
        BXTexture2DAtlas* anAtlas = [mAtlasInfos objectAtIndex:i];
        KRVector2DInt atlasCount = [anAtlas count];
        ret += atlasCount.x * atlasCount.y;
    }
    return ret;
}

- (int)atlasCount
{
    return [mAtlasInfos count];
}

- (BXTexture2DAtlas*)atlasAtIndex:(int)index
{
    return [mAtlasInfos objectAtIndex:index];
}

- (void)addAtlas:(BXTexture2DAtlas*)anAtlas
{
    [mAtlasInfos addObject:anAtlas];
    [anAtlas setTexture2D:self];
}

- (void)removeAtlas:(BXTexture2DAtlas*)anAtlas
{
    [anAtlas setTexture2D:nil];
    [mAtlasInfos removeObject:anAtlas];
}


#pragma mark -
#pragma mark シリアライゼーションのサポート

- (NSDictionary*)elementInfo
{
    NSMutableDictionary* theInfo = [NSMutableDictionary dictionary];
    
    // 基本のIDと名前
    [theInfo setStringValue:mResourceUUID forName:@"Resource UUID"];
    [theInfo setIntValue:mGroupID forName:@"Group ID"];
    [theInfo setIntValue:mResourceID forName:@"Resource ID"];
    [theInfo setStringValue:mResourceName forName:@"Resource Name"];
    
    // 画像
    if (mImageTicket) {
        [theInfo setStringValue:mImageTicket forName:@"Image Ticket"];
    } else {
        [theInfo removeObjectForKey:@"Image Ticket"];
    }
    if (mImageName) {
        [theInfo setStringValue:mImageName forName:@"Image Name"];
    } else {
        [theInfo removeObjectForKey:@"Image Name"];
    }
    if (mImageID) {
        [theInfo setStringValue:mImageID forName:@"Image ID"];
    } else {
        [theInfo removeObjectForKey:@"Image ID"];
    }
    
    // スケール
    [theInfo setDoubleValue:mPreviewScale forName:@"Preview Scale"];
    
    // アトラス
    NSMutableArray* atlasInfos = [NSMutableArray array];
    int atlasCount = [mAtlasInfos count];
    for (int i = 0; i < atlasCount; i++) {
        BXTexture2DAtlas* anAtlas = [mAtlasInfos objectAtIndex:i];
        NSDictionary* atlasInfo = [anAtlas elementInfo];
        [atlasInfos addObject:atlasInfo];
    }
    [theInfo setObject:atlasInfos forKey:@"Atlas Data"];
    
    return theInfo;
}

- (void)restoreElementInfo:(NSDictionary*)theInfo document:(BXDocument*)document
{
    // 基本のIDと名前
    [mResourceUUID release];
    mResourceUUID = [[theInfo stringValueForName:@"Resource UUID" currentValue:mResourceUUID] retain];
    mGroupID = [theInfo intValueForName:@"Group ID" currentValue:mResourceID];
    mResourceID = [theInfo intValueForName:@"Resource ID" currentValue:mResourceID];
    [self setResourceName:[theInfo stringValueForName:@"Resource Name" currentValue:mResourceName]];
    
    // 画像
    mImageTicket = [[theInfo stringValueForName:@"Image Ticket" currentValue:mImageTicket] copy];
    mImageName = [[theInfo stringValueForName:@"Image Name" currentValue:mImageTicket] copy];
    mImageID = [[theInfo stringValueForName:@"Image ID" currentValue:mImageID] copy];
    
    // プレビュー
    mPreviewScale = [theInfo doubleValueForName:@"Preview Scale" currentValue:mPreviewScale];
    
    // アトラス
    NSArray* atlasData = [theInfo objectForKey:@"Atlas Data"];
    int atlasCount = [atlasData count];
    for (int i = 0; i < atlasCount; i++) {
        NSDictionary* anAtlasInfo = [atlasData objectAtIndex:i];
        BXTexture2DAtlas* anAtlas = [[BXTexture2DAtlas alloc] init];
        [anAtlas restoreElementInfo:anAtlasInfo];
        [self addAtlas:anAtlas];
        [anAtlas release];
    }
}    

- (void)exportToFileHandle:(NSFileHandle*)fileHandle
{
    // リソースの書き出し
    if (mImageTicket && [mImageTicket length] > 0) {
        NSString* errorStr = nil;

        BXResourceFileManager* fileManager = [[self document] fileManager];
        NSImage* image = [fileManager image72dpiForTicket:mImageTicket];
        NSData* pngData = [image pngData];
        
        NSMutableDictionary* texInfo = [NSMutableDictionary dictionary];
        [texInfo setIntValue:mGroupID forName:@"Group ID"];
        [texInfo setObject:mImageTicket forKey:@"Ticket"];
        [texInfo setIntValue:mResourceID forName:@"Resource ID"];
        [texInfo setObject:[fileManager resourceNameForTicket:mImageTicket] forKey:@"Resource Name"];
        NSData* texInfoData = [NSPropertyListSerialization dataFromPropertyList:texInfo
                                                                         format:NSPropertyListBinaryFormat_v1_0
                                                               errorDescription:&errorStr];
        
        // ヘッダ
        [fileHandle writeBuffer:"KRT2" length:4];
        [fileHandle writeUnsignedIntValue:[texInfoData length]];
        [fileHandle writeData:texInfoData];
        
        // データ
        [fileHandle writeBuffer:"KRDT" length:4];
        [fileHandle writeUnsignedIntValue:[pngData length]];
        [fileHandle writeData:pngData];
    }
}

- (NSString*)textureDescription
{
    return [NSString stringWithFormat:@"%d: %@", mResourceID, mResourceName];
}

@end


