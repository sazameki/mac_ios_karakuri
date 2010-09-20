//
//  BXTexture2DSpec.h
//  Karakuri Box
//
//  Created by numata on 10/09/20.
//  Copyright 2010 Satoshi Numata. All rights reserved.
//

#import "BXResourceElement.h"


@class BXDocument;


@interface BXTexture2DSpec : BXResourceElement {
    NSString*   mImageTicket;
    double      mPreviewScale;
    NSString*   mImageName;
}

- (void)setImageWithFileAtPath:(NSString*)path;
- (NSString*)imageName;
- (void)setImageName:(NSString*)str;
- (NSString*)imageTicket;
- (NSImage*)image72dpi;

- (double)previewScale;
- (void)setPreviewScale:(double)scale;

@end

