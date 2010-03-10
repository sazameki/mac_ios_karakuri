//
//  BXChara2DKomaPreviewView.mm
//  Karakuri Box
//
//  Created by numata on 10/03/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXChara2DKomaPreviewView.h"
#import "BXDocument.h"
#import "BXChara2DKoma.h"


@interface BXChara2DKomaPreviewView ()

- (BXChara2DKoma*)selectedKoma;

@end


@implementation BXChara2DKomaPreviewView

- (BOOL)acceptsFirstResponder { return YES; }

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (BXChara2DKoma*)selectedKoma
{
    return [oDocument selectedChara2DKoma];
}

- (void)updateViewSize
{
    BXChara2DKoma* theKoma = [self selectedKoma];
    NSImage* nsImage = [theKoma nsImage];
    NSSize imageSize = [nsImage size];
    
    NSSize theSize = NSZeroSize;
    
    theSize.width = imageSize.width + 20*2;
    theSize.height = imageSize.height + 20*2;
    
    if (theSize.width < 246) {
        theSize.width = 246;
    }
    if (theSize.height < 192) {
        theSize.height = 192;
    }
    
    NSRect frame = [self frame];
    frame.size = theSize;
    [self setFrame:frame];
}

- (void)drawRect:(NSRect)dirtyRect
{
    BXChara2DKoma* theKoma = [self selectedKoma];

    if (!theKoma) {
        [[NSColor controlColor] set];
        NSRectFill(dirtyRect);
        return;
    }

    [[NSColor whiteColor] set];
    NSRectFill(dirtyRect);
    
    [NSGraphicsContext saveGraphicsState];

    NSImage* nsImage = [theKoma nsImage];
    NSSize imageSize = [nsImage size];

    NSAffineTransform* transform = [NSAffineTransform transform];
    [transform scaleXBy:1.0 yBy:-1.0];
    [transform translateXBy:0.0 yBy:-imageSize.height-20*2];
    [transform concat];
    
    [nsImage setFlipped:NO];
    [nsImage drawAtPoint:NSMakePoint(20, 20)
                fromRect:NSMakeRect(0, 0, imageSize.width, -imageSize.height)
               operation:NSCompositeSourceOver
                fraction:1.0];

    [NSGraphicsContext restoreGraphicsState];
}

@end

