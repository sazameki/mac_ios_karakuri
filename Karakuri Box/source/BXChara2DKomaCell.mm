//
//  BXChara2DKomaCell.mm
//  Karakuri Box
//
//  Created by numata on 10/03/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXChara2DKomaCell.h"


@implementation BXChara2DKomaCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
    NSImage* image = [self image];
    
    NSSize imageSize = [image size];
    
    int width = cellFrame.size.height * imageSize.width / imageSize.height;
    NSRect theRect = NSMakeRect(cellFrame.origin.x, cellFrame.origin.y, width, cellFrame.size.height);
    
    NSImage* transpImage = [NSImage imageNamed:@"transparent_pattern.png"];
    [[NSColor colorWithPatternImage:transpImage] set];
    float xOffset = NSMinX([controlView convertRect:cellFrame toView:nil]);
    float yOffset = NSMaxY([controlView convertRect:cellFrame toView:nil]);
    [[NSGraphicsContext currentContext] setPatternPhase:NSMakePoint(xOffset-3, yOffset-1)];
    NSRectFill(theRect);
    
    [image drawInRect:theRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
    
    [[NSColor blackColor] set];
    NSFrameRect(theRect);
}

@end

