//
//  BXTexture2DAtlas.mm
//  Karakuri Box
//
//  Created by numata on 10/09/21.
//  Copyright 2010 Satoshi Numata. All rights reserved.
//

#import "BXTexture2DAtlas.h"
#import "NSDictionary+LoadSave.h"
#import "NSImage+BXEx.h"


@implementation BXTexture2DAtlas

- (id)init
{
    self = [super init];
    if (self) {
        mStartPos = KRVector2DInt(0, 0);
        mSize = KRVector2DInt(32, 32);
        mCount = KRVector2DInt(2, 2);
    }
    return self;
}

- (void)setTexture2D:(BXTexture2DSpec*)tex
{
    mTex2D = tex;
}

- (KRVector2DInt)startPos
{
    return mStartPos;
}

- (KRVector2DInt)size
{
    return mSize;
}

- (KRVector2DInt)count
{
    return mCount;
}

- (void)setStartPos:(KRVector2DInt)pos
{
    mStartPos = pos;
}

- (void)setSize:(KRVector2DInt)size
{
    mSize = size;
}

- (void)setCount:(KRVector2DInt)count
{
    mCount = count;
}

- (NSString*)atlasDescription
{
    return [NSString stringWithFormat:@"(%d, %d): (%d x %d)", mStartPos.x, mStartPos.y, mSize.x, mSize.y];
}

- (void)drawAtlasFromTextureImage:(NSImage*)image point:(KRVector2DInt)point inRect:(NSRect)rect
{
    rect = NSInsetRect(rect, 4.0, 4.0);
    
    [image drawThumbnailInRect:rect fromRect:NSMakeRect(mStartPos.x + mSize.x * point.x, mStartPos.y + mSize.y * point.y, mSize.x, mSize.y) background:YES border:YES];
}

- (void)restoreElementInfo:(NSDictionary*)dict
{
    mStartPos.x = [dict intValueForName:@"Atlas StartPos X" currentValue:mStartPos.x];
    mStartPos.y = [dict intValueForName:@"Atlas StartPos Y" currentValue:mStartPos.y];
    mSize.x = [dict intValueForName:@"Atlas Size X" currentValue:mSize.x];
    mSize.y = [dict intValueForName:@"Atlas Size Y" currentValue:mSize.y];
    mCount.x = [dict intValueForName:@"Atlas Count X" currentValue:mCount.x];
    mCount.y = [dict intValueForName:@"Atlas Count Y" currentValue:mCount.y];
}

- (NSDictionary*)elementInfo
{
    NSMutableDictionary* theInfo = [NSMutableDictionary dictionary];
    
    [theInfo setIntValue:mStartPos.x forName:@"Atlas StartPos X"];
    [theInfo setIntValue:mStartPos.y forName:@"Atlas StartPos Y"];
    [theInfo setIntValue:mSize.x forName:@"Atlas Size X"];
    [theInfo setIntValue:mSize.y forName:@"Atlas Size Y"];
    [theInfo setIntValue:mCount.x forName:@"Atlas Count X"];
    [theInfo setIntValue:mCount.y forName:@"Atlas Count Y"];
    
    return theInfo;
}

@end


