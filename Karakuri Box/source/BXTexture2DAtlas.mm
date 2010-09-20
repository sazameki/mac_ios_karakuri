//
//  BXTexture2DAtlas.mm
//  Karakuri Box
//
//  Created by numata on 10/09/21.
//  Copyright 2010 Satoshi Numata. All rights reserved.
//

#import "BXTexture2DAtlas.h"


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

@end


