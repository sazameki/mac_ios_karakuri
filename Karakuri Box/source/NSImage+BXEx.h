//
//  NSImage+BXEx.h
//  Karakuri Box
//
//  Created by numata on 10/03/09.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSImage (BXEx)

- (void)drawThumbnailInRect:(NSRect)rect background:(BOOL)drawsBG border:(BOOL)drawsBorder;
- (void)drawThumbnailInRect:(NSRect)rect fromRect:(NSRect)fromRect background:(BOOL)drawsBG border:(BOOL)drawsBorder;

- (NSImage*)subImageFromRect:(NSRect)rect;

- (NSArray*)divideByX:(int)x y:(int)y;

- (NSData*)pngData;

@end

