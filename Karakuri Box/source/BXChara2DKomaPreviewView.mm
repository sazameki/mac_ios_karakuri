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
#import "BXChara2DSpec.h"


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

- (void)updateViewSize
{
    BXChara2DSpec* theSpec = [oDocument selectedChara2DSpec];
    BXChara2DKoma* theKoma = [oDocument selectedChara2DKoma];

    double scale = [theSpec komaPreviewScale];
    
    NSImage* nsImage = [theKoma nsImage];
    NSSize imageSize = [nsImage size];
    
    NSSize theSize = NSZeroSize;
    
    theSize.width = imageSize.width * scale + gChara2DKomaPreviewPaddingX*2;
    theSize.height = imageSize.height * scale + gChara2DKomaPreviewPaddingY*2;

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
    BXChara2DKoma* theKoma = [oDocument selectedChara2DKoma];

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
    
    NSRect targetRect = NSMakeRect(mStartX, mStartY, imageSize.width, imageSize.height);

    [[NSColor darkGrayColor] set];
    NSFrameRect(NSInsetRect(targetRect, -1, -1));

    NSImage* transpImage = [NSImage imageNamed:@"transparent_pattern.png"];
    [[NSColor colorWithPatternImage:transpImage] set];
    float xOffset = NSMinX([self convertRect:targetRect toView:nil]);
    float yOffset = NSMaxY([self convertRect:targetRect toView:nil]);
    [[NSGraphicsContext currentContext] setPatternPhase:NSMakePoint(xOffset, yOffset)];
    NSRectFill(targetRect);
     
    [nsImage setFlipped:YES];
    [nsImage drawAtPoint:NSMakePoint(mStartX, mStartY)
                fromRect:NSMakeRect(0, 0, imageSize.width, -imageSize.height)
               operation:NSCompositeSourceOver
                fraction:1.0];
}

@end

