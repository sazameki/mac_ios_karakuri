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

- (NSArray*)divideByX:(int)x y:(int)y;

@end

