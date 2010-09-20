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


@implementation BXTexture2DSpec

- (id)initWithName:(NSString*)name
{
    self = [super initWithName:name];
    if (self) {
        mPreviewScale = 1.0;
    }
    return self;
}

- (void)dealloc
{
    [mImageTicket release];
    [mImageName release];

    [super dealloc];
}

- (void)setImageWithFileAtPath:(NSString*)path
{
    mImageTicket = [[[mDocument fileManager] storeFileAtPath:path] copy];
    [self setImageName:[path lastPathComponent]];
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


#pragma mark -
#pragma mark シリアライゼーションのサポート


- (NSDictionary*)elementInfo
{
    NSMutableDictionary* theInfo = [NSMutableDictionary dictionary];
    
    // 基本のIDと名前
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
    
    // スケール
    [theInfo setDoubleValue:mPreviewScale forName:@"Preview Scale"];
    
    return theInfo;
}

- (void)restoreElementInfo:(NSDictionary*)theInfo document:(BXDocument*)document
{
    // 基本のIDと名前
    mGroupID = [theInfo intValueForName:@"Group ID" currentValue:mResourceID];
    mResourceID = [theInfo intValueForName:@"Resource ID" currentValue:mResourceID];
    [self setResourceName:[theInfo stringValueForName:@"Resource Name" currentValue:mResourceName]];
    
    // 画像
    mImageTicket = [[theInfo stringValueForName:@"Image Ticket" currentValue:mImageTicket] copy];
    mImageName = [[theInfo stringValueForName:@"Image Name" currentValue:mImageTicket] copy];
    
    // プレビュー
    mPreviewScale = [theInfo doubleValueForName:@"Preview Scale" currentValue:mPreviewScale];
}    
    
@end


