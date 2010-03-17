//
//  BXChara2DImage.mm
//  Karakuri Box
//
//  Created by numata on 10/03/09.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXChara2DImage.h"
#import "BXDocument.h"
#import "NSImage+BXEx.h"
#import "NSDictionary+LoadSave.h"


@implementation BXChara2DImage

- (id)initWithFilepath:(NSString*)path imageID:(int)imageID document:(BXDocument*)document
{
    self = [super init];
    if (self) {
        mDocument = document;
        
        mImageID = imageID;

        mImageTicket = [[[document fileManager] storeFileAtPath:path] copy];
        
        mAtlasImages = [[NSMutableArray alloc] init];
        
        mDivX = 1;
        mDivY = 1;
        
        mUsedCount = 0;
        
        [self updateAtlasImages];
    }
    return self;
}

- (id)initWithInfo:(NSDictionary*)info document:(BXDocument*)document
{
    self = [super init];
    if (self) {
        mDocument = document;
        
        mImageID = [info intValueForName:@"Image ID" currentValue:-1];

        mImageTicket = [[info stringValueForName:@"Image Ticket" currentValue:nil] copy];
        
        mAtlasImages = [[NSMutableArray alloc] init];
        
        mDivX = [info intValueForName:@"Div X" currentValue:1];
        mDivY = [info intValueForName:@"Div Y" currentValue:1];
        mUsedCount = [info intValueForName:@"Used Count" currentValue:0];
        
        [self updateAtlasImages];
    }
    return self;
}

- (void)dealloc
{
    [mAtlasImages release];
    [mImageTicket release];

    [super dealloc];
}

- (BXDocument*)document
{
    return mDocument;
}

- (int)imageID
{
    return mImageID;
}

- (void)updateAtlasImages
{
    [mAtlasImages removeAllObjects];

    NSImage* theImage = [self image72dpi];
    [mAtlasImages addObjectsFromArray:[theImage divideByX:mDivX y:mDivY]];
}

- (int)divX
{
    return mDivX;
}

- (int)divY
{
    return mDivY;
}

- (void)setDivX:(int)value
{
    mDivX = value;
}

- (void)setDivY:(int)value
{
    mDivY = value;
}

- (NSString*)imageTicket
{
    return mImageTicket;
}

- (NSString*)imageName
{
    return [[mDocument fileManager] imageNameForTicket:mImageTicket];
}

- (NSImage*)image72dpi
{
    return [[mDocument fileManager] image72dpiForTicket:mImageTicket];
}

- (int)atlasImageCount
{
    return [mAtlasImages count];
}

- (NSImage*)atlasImage72dpiAtIndex:(int)index
{
    return [mAtlasImages objectAtIndex:index];
}

- (void)incrementUsedCount
{
    mUsedCount++;
}

- (void)decrementUsedCount
{
    mUsedCount--;
}

- (BOOL)isUsed
{
    return (mUsedCount > 0);
}

- (NSDictionary*)imageInfo
{
    NSMutableDictionary* theInfo = [NSMutableDictionary dictionary];
    
    [theInfo setIntValue:mImageID forName:@"Image ID"];
    [theInfo setStringValue:mImageTicket forName:@"Image Ticket"];
    [theInfo setIntValue:mDivX forName:@"Div X"];
    [theInfo setIntValue:mDivY forName:@"Div Y"];
    [theInfo setIntValue:mUsedCount forName:@"Used Count"];
    
    return theInfo;
}

@end

