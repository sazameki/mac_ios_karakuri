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
- (BOOL)isFlipped { return YES; }

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
    
    theSize.width = imageSize.width + gChara2DKomaPreviewPaddingX*2;
    theSize.height = imageSize.height + gChara2DKomaPreviewPaddingY*2;

    NSScrollView* scrollView = (NSScrollView*)[[self superview] superview];
    NSClipView* contentView = [scrollView contentView];
    NSRect visibleRect = [contentView documentVisibleRect];

    if (theSize.width < visibleRect.size.width) {
        theSize.width = visibleRect.size.width;
    }
    if (theSize.height < visibleRect.size.height) {
        theSize.height = visibleRect.size.height;
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
    
    NSImage* nsImage = [theKoma nsImage];
    NSSize imageSize = [nsImage size];

    NSSize frameSize = [self frame].size;
    
    mStartX = (int)((frameSize.width - imageSize.width) / 2);
    mStartY = (int)((frameSize.height - imageSize.height) / 2);

    [[NSColor lightGrayColor] set];
    NSRectFill(dirtyRect);    

    for (int i = 1; i <= 3; i++) {
        [[NSColor colorWithCalibratedWhite:0.3+i*0.12 alpha:1.0] set];
        NSFrameRect(NSMakeRect(mStartX-i, mStartY-i, imageSize.width+i*2, imageSize.height+i*2));
    }
    
    [nsImage setFlipped:YES];
    [nsImage drawAtPoint:NSMakePoint(mStartX, mStartY)
                fromRect:NSMakeRect(0, 0, imageSize.width, -imageSize.height)
               operation:NSCompositeSourceOver
                fraction:1.0];
}

@end

