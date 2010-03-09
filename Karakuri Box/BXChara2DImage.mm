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


@implementation BXChara2DImage

- (id)initWithFilepath:(NSString*)path document:(BXDocument*)document
{
    self = [super init];
    if (self) {
        mDocument = document;
        mImageTicket = [[document fileManager] storeImageFileAtPath:path];
        
        mAtlasImages = [[NSMutableArray alloc] init];
        
        mDivX = 1;
        mDivY = 1;
        
        mUsedCount = 0;
        
        [self updateAtlasImages];
    }
    return self;
}

- (void)dealloc
{
    [mAtlasImages release];

    [super dealloc];
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

@end

