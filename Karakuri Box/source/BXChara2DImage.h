//
//  BXChara2DImage.h
//  Karakuri Box
//
//  Created by numata on 10/03/09.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class BXDocument;


@interface BXChara2DImage : NSObject {
    BXDocument* mDocument;

    NSString*   mImageTicket;
    
    int         mDivX;
    int         mDivY;
    
    NSMutableArray* mAtlasImages;
    
    int         mUsedCount;
}

- (id)initWithFilepath:(NSString*)path document:(BXDocument*)document;
- (id)initWithInfo:(NSDictionary*)info document:(BXDocument*)document;

- (BXDocument*)document;

- (void)updateAtlasImages;

- (int)divX;
- (int)divY;
- (void)setDivX:(int)value;
- (void)setDivY:(int)value;

- (NSString*)imageTicket;

- (NSString*)imageName;
- (NSImage*)image72dpi;
- (int)atlasImageCount;
- (NSImage*)atlasImage72dpiAtIndex:(int)index;

- (void)incrementUsedCount;
- (void)decrementUsedCount;

- (BOOL)isUsed;

- (NSDictionary*)imageInfo;

@end

