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
        mScale = 1.0;
        mResizingHitInfo = nil;
    }
    return self;
}

- (void)updateViewSize
{
    BXChara2DSpec* theSpec = [oDocument selectedChara2DSpec];
    BXChara2DKoma* theKoma = [oDocument selectedChara2DKoma];

    mScale = [theSpec komaPreviewScale];
    
    NSImage* nsImage = [theKoma nsImage];
    NSSize imageSize = [nsImage size];
    
    imageSize.width = (int)(imageSize.width * mScale + 0.5);
    imageSize.height = (int)(imageSize.height * mScale + 0.5);
    
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
    BXChara2DKoma* theKoma = [oDocument selectedChara2DKoma];

    if (!theKoma) {
        [[NSColor controlColor] set];
        NSRectFill(dirtyRect);
        return;
    }
    
    NSImage* nsImage = [theKoma nsImage];
    NSSize imageSize = [nsImage size];

    NSSize frameSize = [self frame].size;
    
    mSizeX = (int)(imageSize.width * mScale + 0.5);
    mSizeY = (int)(imageSize.height * mScale + 0.5);
    mStartX = (int)((frameSize.width - mSizeX) / 2);
    mStartY = (int)((frameSize.height - mSizeY) / 2);

    [[NSColor lightGrayColor] set];
    NSRectFill(dirtyRect);
    
    NSRect targetRect = NSMakeRect(mStartX, mStartY, mSizeX, mSizeY);

    [[NSColor darkGrayColor] set];
    NSFrameRect(NSInsetRect(targetRect, -1, -1));

    [NSGraphicsContext saveGraphicsState];
    
    NSImage* transpImage = [NSImage imageNamed:@"transparent_pattern.png"];
    [[NSColor colorWithPatternImage:transpImage] set];
    float xOffset = NSMinX([self convertRect:targetRect toView:nil]);
    float yOffset = NSMaxY([self convertRect:targetRect toView:nil]);
    [[NSGraphicsContext currentContext] setPatternPhase:NSMakePoint(xOffset, yOffset)];
    NSRectFill(targetRect);

    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];

    [nsImage setFlipped:YES];
    [nsImage drawInRect:targetRect
               fromRect:NSMakeRect(0, 0, imageSize.width, imageSize.height)
              operation:NSCompositeSourceOver
               fraction:1.0];

    [NSGraphicsContext restoreGraphicsState];
    
    if ([theKoma showsHitInfos]) {
        [theKoma drawHitInfosInRect:targetRect scale:mScale];
    }
    
    if (mResizingHitInfo) {
        [mResizingHitInfo drawResizeHandlesInRect:targetRect scale:mScale];
    }
}

- (void)selectHitInfo:(BXChara2DKomaHitInfo*)anInfo
{
    mResizingHitInfo = anInfo;
    [self setNeedsDisplay:YES];
}

- (void)deselectHitInfo
{
    mResizingHitInfo = nil;
    [self setNeedsDisplay:YES];
}

- (void)keyDown:(NSEvent*)theEvent
{
    if (!mResizingHitInfo) {
        return;
    }
    
    unsigned short keyCode = [theEvent keyCode];
    unsigned modifierFlags = [theEvent modifierFlags];
    
    int speed = (modifierFlags & NSShiftKeyMask)? 4: 1;
    
    if (keyCode == 0x7b) {
        NSRect rect = [mResizingHitInfo rect];
        rect.origin.x -= speed;
        [mResizingHitInfo setRect:rect];
    }
    else if (keyCode == 0x7c) {
        NSRect rect = [mResizingHitInfo rect];
        rect.origin.x += speed;
        [mResizingHitInfo setRect:rect];
    }
    else if (keyCode == 0x7e) {
        NSRect rect = [mResizingHitInfo rect];
        rect.origin.y += speed;
        [mResizingHitInfo setRect:rect];
    }
    else if (keyCode == 0x7d) {
        NSRect rect = [mResizingHitInfo rect];
        rect.origin.y -= speed;
        [mResizingHitInfo setRect:rect];
    }
    
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent*)theEvent
{
    BXChara2DKoma* theKoma = [oDocument selectedChara2DKoma];
    if (!theKoma) {
        return;
    }
    
    NSImage* nsImage = [theKoma nsImage];
    NSSize imageSize = [nsImage size];
    
    NSSize frameSize = [self frame].size;
    
    mSizeX = (int)(imageSize.width * mScale + 0.5);
    mSizeY = (int)(imageSize.height * mScale + 0.5);
    mStartX = (int)((frameSize.width - mSizeX) / 2);
    mStartY = (int)((frameSize.height - mSizeY) / 2);
    
    NSRect targetRect = NSMakeRect(mStartX, mStartY, mSizeX, mSizeY);
    
    NSPoint pos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    pos.x -= targetRect.origin.x;
    pos.y -= targetRect.origin.y;
    pos.x /= mScale;
    pos.y /= mScale;
    pos.y = imageSize.height - pos.y;
    
    mResizingHitInfo = [theKoma hitInfoAtPoint:pos];
    
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent*)theEvent
{
    if (!mResizingHitInfo) {
        return;
    }

    NSRect rect = [mResizingHitInfo rect];
    rect.origin.x += [theEvent deltaX];
    rect.origin.y -= [theEvent deltaY];
    [mResizingHitInfo setRect:rect];

    [self setNeedsDisplay:YES];
}

@end

