//
//  BXTexture2DSpec.h
//  Karakuri Box
//
//  Created by numata on 10/09/20.
//  Copyright 2010 Satoshi Numata. All rights reserved.
//

#import "BXResourceElement.h"


@class BXDocument;
@class BXTexture2DAtlas;


@interface BXTexture2DSpec : BXResourceElement {
    NSString*   mImageTicket;
    double      mPreviewScale;
    NSString*   mImageName;
    NSString*   mImageID;
    
    NSMutableArray* mAtlasInfos;
}

- (void)setImageWithFileAtPath:(NSString*)path;
- (NSString*)imageName;
- (void)setImageName:(NSString*)str;
- (NSString*)imageTicket;
- (NSImage*)image72dpi;

- (double)previewScale;
- (void)setPreviewScale:(double)scale;

- (int)allAtlasPieceCount;

- (int)atlasCount;
- (BXTexture2DAtlas*)atlasAtIndex:(int)index;
- (void)addAtlas:(BXTexture2DAtlas*)anAtlas;
- (void)removeAtlas:(BXTexture2DAtlas*)anAtlas;

- (NSString*)textureDescription;

@end

