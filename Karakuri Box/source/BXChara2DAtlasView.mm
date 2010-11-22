//
//  BXChara2DAtlasView.mm
//  Karakuri Box
//
//  Created by numata on 10/03/09.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXChara2DAtlasView.h"
#import "BXDocument.h"
#import "NSImage+BXEx.h"


@implementation BXChara2DAtlasView

- (BOOL)isFlipped { return YES; }
- (BOOL)acceptsFirstResponder { return YES; }

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        mLastSelectedIndex = -1;
        mSelectionIndexes = [[NSMutableIndexSet alloc] init];
        mHasSelectedAtlasImage = NO;
    }
    return self;
}

- (void)dealloc
{
    [mSelectionIndexes release];
    
    [super dealloc];
}

- (NSSize)minSize
{
    NSSize ret = NSMakeSize(1, 1);
 
    NSScrollView* scrollView = (NSScrollView*)[[self superview] superview];
    NSClipView* contentView = [scrollView contentView];
    NSRect visibleRect = [contentView documentVisibleRect];

    BXTexture2DSpec* theTex = [oDocument selectedChara2DTexture2D];
    int atlasCount = [theTex allAtlasPieceCount];
    
    mCurrentDivCountX = (int)visibleRect.size.width / gChara2DImageAtlasSizeX;
    
    ret.width = mCurrentDivCountX * gChara2DImageAtlasSizeX;
    ret.height = ((atlasCount + (mCurrentDivCountX-1)) / mCurrentDivCountX) * gChara2DImageAtlasSizeY;
 
    if (ret.width < visibleRect.size.width) {
        ret.width = visibleRect.size.width;
    }
    
    if (ret.height < visibleRect.size.height) {
        ret.height = visibleRect.size.height;
    }
    
    return ret;
}

- (void)deselectAll
{
    mLastSelectedIndex = -1;
    [mSelectionIndexes removeAllIndexes];
}

- (void)selectAll:(id)sender
{
    BXTexture2DSpec* theTex = [oDocument selectedChara2DTexture2D];
    if (!theTex) {
        return;
    }
    
    [mSelectionIndexes addIndexesInRange:NSMakeRange(0, [theTex allAtlasPieceCount])];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    BXTexture2DSpec* theTex = [oDocument selectedChara2DTexture2D];
    if (!theTex) {
        [[NSColor darkGrayColor] set];
        NSRectFill(dirtyRect);
        return;
    }
    
    [NSGraphicsContext saveGraphicsState];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [[NSGraphicsContext currentContext] setShouldAntialias:NO];

    int partCount = 0;
    NSImage* theImage = [theTex image72dpi];
    
    int atlasCount = [theTex atlasCount];
    for (int i = 0; i < atlasCount; i++) {
        BXTexture2DAtlas* anAtlas = [theTex atlasAtIndex:i];
        KRVector2DInt atlasCount = [anAtlas count];
        
        for (int y = 0; y < atlasCount.y; y++) {
            for (int x = 0; x < atlasCount.x; x++) {
                int drawX = (mCurrentDivCountX > 0)? (partCount % mCurrentDivCountX): 0;
                int drawY = (mCurrentDivCountX > 0)? (partCount / mCurrentDivCountX): 0;

                NSRect theRect = NSMakeRect(drawX * gChara2DImageAtlasSizeX, drawY * gChara2DImageAtlasSizeY, gChara2DImageAtlasSizeX, gChara2DImageAtlasSizeY);

                if ([mSelectionIndexes containsIndex:partCount]) {
                    [[NSColor selectedControlColor] set];
                    NSRectFill(theRect);
                }
                
                [anAtlas drawAtlasFromTextureImage:theImage point:KRVector2DInt(x, y) inRect:theRect];

                partCount++;
            }
        }
    }
    
    [NSGraphicsContext restoreGraphicsState];
}

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
    return (isLocal? NSDragOperationCopy: NSDragOperationNone);
}

- (void)mouseDown:(NSEvent*)theEvent
{
    mHasSelectedAtlasImage = NO;
    
    BXTexture2DSpec* theTex = [oDocument selectedChara2DTexture2D];
    if (!theTex) {
        [self setNeedsDisplay:YES];
        return;
    }

    int pieceCount = [theTex allAtlasPieceCount];

    NSPoint pos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    unsigned modifierFlags = [theEvent modifierFlags];
    
    int x = (int)pos.x / gChara2DImageAtlasSizeX;
    int y = (int)pos.y / gChara2DImageAtlasSizeY;
    
    int index = y * mCurrentDivCountX + x;
    
    if (index < pieceCount) {
        // 追加の選択
        if (modifierFlags & NSCommandKeyMask) {
            if ([mSelectionIndexes containsIndex:index]) {
                [mSelectionIndexes removeIndex:index];
            } else {
                [mSelectionIndexes addIndex:index];
                mHasSelectedAtlasImage = YES;
            }
            mLastSelectedIndex = index;
        }
        // 範囲の追加
        else if (modifierFlags & NSShiftKeyMask) {
            if (mLastSelectedIndex >= 0) {
                for (int i = index; i <= mLastSelectedIndex; i++) {
                    [mSelectionIndexes addIndex:i];
                }
                for (int i = mLastSelectedIndex; i <= index; i++) {
                    [mSelectionIndexes addIndex:i];
                }
            } else {
                [mSelectionIndexes addIndex:index];
                mLastSelectedIndex = index;
            }
            mHasSelectedAtlasImage = YES;
        }
        // 通常の選択
        else {
            if (![mSelectionIndexes containsIndex:index]) {
                [self deselectAll];
                [mSelectionIndexes addIndex:index];
                mLastSelectedIndex = index;
            }
            mHasSelectedAtlasImage = YES;
        }
    } else {
        if (modifierFlags & (NSCommandKeyMask | NSShiftKeyMask)) {
            // Do nothing
        } else {
            [self deselectAll];
        }
    }
    
    [self setNeedsDisplay:YES];
}

- (NSImage*)draggingImage
{
    BXTexture2DSpec* theTex = [oDocument selectedChara2DTexture2D];

    int selectionCount = [mSelectionIndexes count];
    int imageSize = gChara2DImageAtlasSizeX + (selectionCount - 1) * gChara2DImageAtlasDraggingCascadeSize;
    
    NSImage* theImage = [theTex image72dpi];
    
    NSImage* draggingImage = [[[NSImage alloc] initWithSize:NSMakeSize(imageSize, imageSize)] autorelease];
    [draggingImage lockFocus];
    
    int drawCount = 0;
    
    int atlasCount = [theTex atlasCount];
    int index = 0;
    for (int i = 0; i < atlasCount; i++) {
        BXTexture2DAtlas* anAtlas = [theTex atlasAtIndex:i];
        KRVector2DInt atlasCount = [anAtlas count];
        
        for (int y = 0; y < atlasCount.y; y++) {
            for (int x = 0; x < atlasCount.x; x++) {
                if ([mSelectionIndexes containsIndex:index]) {
                    NSRect theAtlasRect = NSMakeRect(drawCount*gChara2DImageAtlasDraggingCascadeSize, drawCount*gChara2DImageAtlasDraggingCascadeSize, gChara2DImageAtlasSizeX, gChara2DImageAtlasSizeX);
                    [anAtlas drawAtlasFromTextureImage:theImage point:KRVector2DInt(x, y) inRect:theAtlasRect];
                    drawCount++;
                }
                index++;
            }
        }
    }
    
    [draggingImage unlockFocus];
    [draggingImage setFlipped:YES];

    return draggingImage;
}

- (void)mouseDragged:(NSEvent*)theEvent
{
    if (!mHasSelectedAtlasImage) {
        return;
    }

    NSPoint pos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSImage* draggingImage = [self draggingImage];
    NSSize imageSize = [draggingImage size];

    NSPasteboard* pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
    
    [pboard declareTypes:[NSArray arrayWithObject:gChara2DImageAtlasDraggingPboardType] owner:self];
    
    NSData* indexesData = [NSArchiver archivedDataWithRootObject:mSelectionIndexes];
    [pboard setData:indexesData forType:gChara2DImageAtlasDraggingPboardType]; 

    [self dragImage:draggingImage
                 at:NSMakePoint(pos.x - imageSize.width/2, pos.y + imageSize.height/2)
             offset:NSZeroSize
              event:theEvent
         pasteboard:pboard
             source:self
          slideBack:YES];
}

- (void)keyDown:(NSEvent*)theEvent
{
    unsigned short keyCode = [theEvent keyCode];
    
    // ESCキー
    if (keyCode == 0x35) {
        [self deselectAll];
        [self setNeedsDisplay:YES];
    }
    // その他
    else {
        NSLog(@"key=0x%02x", keyCode);
    }
}

@end

