//
//  BXTexture2DAtlas.h
//  Karakuri Box
//
//  Created by numata on 10/09/21.
//  Copyright 2010 Satoshi Numata. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KarakuriTypes.h"


@class BXTexture2DSpec;


@interface BXTexture2DAtlas : NSObject {
    BXTexture2DSpec*    mTex2D;
    
    KRVector2DInt       mStartPos;
    KRVector2DInt       mSize;
    KRVector2DInt       mCount;
}

- (void)setTexture2D:(BXTexture2DSpec*)tex;
- (NSString*)atlasDescription;
- (KRVector2DInt)startPos;
- (KRVector2DInt)size;
- (KRVector2DInt)count;
- (void)setStartPos:(KRVector2DInt)pos;
- (void)setSize:(KRVector2DInt)size;
- (void)setCount:(KRVector2DInt)count;

@end

