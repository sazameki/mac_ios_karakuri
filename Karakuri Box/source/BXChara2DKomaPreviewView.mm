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

- (IBAction)doActionCommand:(id)sender
{
    int tag = [oActionCommandButton selectedTag];
 
    BXChara2DKoma* selectedKoma = [oDocument selectedChara2DKoma];
    
    // 他のすべてのコマに当たり範囲を追加
    if (tag == 10) {
        BXChara2DMotion* selectedMotion = [oDocument selectedChara2DMotion];
        for (int i = 0; i < [selectedMotion komaCount]; i++) {
            BXChara2DKoma* aKoma = [selectedMotion komaAtIndex:i];
            if (aKoma == selectedKoma) {
                continue;
            }
            [aKoma importHitInfosFromKoma:selectedKoma];
        }
        [oDocument updateChangeCount:NSChangeUndone];
    }
    // 以降のすべてのコマに当たり範囲を追加
    else if (tag == 20) {
        BOOL foundSelectedKoma = NO;
        BXChara2DMotion* selectedMotion = [oDocument selectedChara2DMotion];
        for (int i = 0; i < [selectedMotion komaCount]; i++) {
            BXChara2DKoma* aKoma = [selectedMotion komaAtIndex:i];
            if (aKoma == selectedKoma) {
                foundSelectedKoma = YES;
                continue;
            }
            if (foundSelectedKoma) {
                [aKoma importHitInfosFromKoma:selectedKoma];
            }
        }
        [oDocument updateChangeCount:NSChangeUndone];
    }
    // 次のコマに当たり範囲を追加
    else if (tag == 30) {
        BXChara2DMotion* selectedMotion = [oDocument selectedChara2DMotion];
        BXChara2DKoma* nextKoma = [selectedMotion komaAtIndex:[selectedKoma komaIndex]];
        if (nextKoma != NULL) {
            [nextKoma importHitInfosFromKoma:selectedKoma];
        }
        [oDocument updateChangeCount:NSChangeUndone];
    }
    // 他のすべてのコマの当たり範囲を置き換え
    if (tag == 40) {
        BXChara2DMotion* selectedMotion = [oDocument selectedChara2DMotion];
        for (int i = 0; i < [selectedMotion komaCount]; i++) {
            BXChara2DKoma* aKoma = [selectedMotion komaAtIndex:i];
            if (aKoma == selectedKoma) {
                continue;
            }
            [aKoma replaceHitInfosFromKoma:selectedKoma];
        }
        [oDocument updateChangeCount:NSChangeUndone];
    }
    // 以降のすべてのコマの当たり範囲を置き換え
    else if (tag == 50) {
        BOOL foundSelectedKoma = NO;
        BXChara2DMotion* selectedMotion = [oDocument selectedChara2DMotion];
        for (int i = 0; i < [selectedMotion komaCount]; i++) {
            BXChara2DKoma* aKoma = [selectedMotion komaAtIndex:i];
            if (aKoma == selectedKoma) {
                foundSelectedKoma = YES;
                continue;
            }
            if (foundSelectedKoma) {
                [aKoma replaceHitInfosFromKoma:selectedKoma];
            }
        }
        [oDocument updateChangeCount:NSChangeUndone];
    }
    // 次のコマの当たり判定を置き換え
    else if (tag == 60) {
        BXChara2DMotion* selectedMotion = [oDocument selectedChara2DMotion];
        BXChara2DKoma* nextKoma = [selectedMotion komaAtIndex:[selectedKoma komaIndex]];
        if (nextKoma != NULL) {
            [nextKoma replaceHitInfosFromKoma:selectedKoma];
        }
        [oDocument updateChangeCount:NSChangeUndone];
    }
    // その他
    else {
        NSLog(@"Unknown action command tag: %d", tag);
    }
    
    [oActionCommandButton selectItemWithTag:0];
}

- (void)keyDown:(NSEvent*)theEvent
{
    if (!mResizingHitInfo) {
        return;
    }
    
    unsigned short keyCode = [theEvent keyCode];
    unsigned modifierFlags = [theEvent modifierFlags];
    
    int speed = (modifierFlags & NSShiftKeyMask)? 4: 1;
    
    // 矢印キー
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
    // Backspace / Delete
    else if (keyCode == 0x33 || keyCode == 0x75) {
        BXChara2DKoma* selectedKoma = [oDocument selectedChara2DKoma];
        if (mResizingHitInfo) {
            [selectedKoma removeHitInfo:mResizingHitInfo];
            mResizingHitInfo = NULL;
            [oDocument updateChangeCount:NSChangeUndone];
        } else {
            NSBeep();
        }
    }

    
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent*)theEvent
{
    mIsResizingFromTop = NO;
    mIsResizingFromBottom = NO;
    mIsResizingFromLeft = NO;
    mIsResizingFromRight = NO;
    
    BXChara2DKoma* theKoma = [oDocument selectedChara2DKoma];
    if (!theKoma) {
        return;
    }
    
    NSPoint pos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if (mResizingHitInfo) {
        if ([mResizingHitInfo isPointInTopMiddleHandle:pos]) {
            mIsResizingFromTop = YES;
            return;
        }
        if ([mResizingHitInfo isPointInBottomMiddleHandle:pos]) {
            mIsResizingFromBottom = YES;
            return;
        }
        if ([mResizingHitInfo isPointInLeftMiddleHandle:pos]) {
            mIsResizingFromLeft = YES;
            return;
        }
        if ([mResizingHitInfo isPointInRightMiddleHandle:pos]) {
            mIsResizingFromRight = YES;
            return;
        }
    }
    
    NSImage* nsImage = [theKoma nsImage];
    NSSize imageSize = [nsImage size];
    
    NSSize frameSize = [self frame].size;
    
    mSizeX = (int)(imageSize.width * mScale + 0.5);
    mSizeY = (int)(imageSize.height * mScale + 0.5);
    mStartX = (int)((frameSize.width - mSizeX) / 2);
    mStartY = (int)((frameSize.height - mSizeY) / 2);
    
    NSRect targetRect = NSMakeRect(mStartX, mStartY, mSizeX, mSizeY);    
    
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
    
    BXChara2DKoma* theKoma = [oDocument selectedChara2DKoma];
    
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

    if (mIsResizingFromTop) {
        [mResizingHitInfo resizeFromTopWithPoint:pos];
    }
    else if (mIsResizingFromBottom) {
        [mResizingHitInfo resizeFromBottomWithPoint:pos];
    }
    else if (mIsResizingFromLeft) {
        [mResizingHitInfo resizeFromLeftWithPoint:pos];
    }
    else if (mIsResizingFromRight) {
        [mResizingHitInfo resizeFromRightWithPoint:pos];
    }
    else {
        NSRect rect = [mResizingHitInfo rect];
        rect.origin.x += [theEvent deltaX] / mScale;
        rect.origin.y -= [theEvent deltaY] / mScale;
        [mResizingHitInfo setRect:rect];
    }

    [self setNeedsDisplay:YES];
}

@end

