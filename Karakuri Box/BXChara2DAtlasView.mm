//
//  BXChara2DAtlasView.mm
//  Karakuri Box
//
//  Created by numata on 10/03/09.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXChara2DAtlasView.h"
#import "BXDocument.h"
#import "BXChara2DImage.h"
#import "NSImage+BXEx.h"


@interface BXChara2DAtlasView ()

- (BXChara2DImage*)selectedImage;

@end


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

- (BXChara2DImage*)selectedImage
{
    return [oDocument selectedChara2DImage];
}

- (NSSize)minSize
{    
    NSSize ret = NSMakeSize(1, 1);
    
    int atlasCount = [[self selectedImage] atlasImageCount];
    
    ret.width = gChara2DImageDivCountX * gChara2DImageAtlasSizeX;
    ret.height = ((atlasCount + (gChara2DImageDivCountX-1)) / gChara2DImageDivCountX) * gChara2DImageAtlasSizeY;
 
    /*NSScrollView* scrollView = (NSScrollView*)[[self superview] superview];
    NSRect scrollViewFrame = [scrollView frame];

    if (ret.height < scrollViewFrame.size.height-2) {
        ret.height = scrollViewFrame.size.height-2;
    }*/
    
    return ret;
}

- (void)deselectAll
{
    mLastSelectedIndex = -1;
    [mSelectionIndexes removeAllIndexes];
}

- (void)selectAll:(id)sender
{
    BXChara2DImage* theImage = [self selectedImage];
    if (!theImage) {
        return;
    }
    
    [mSelectionIndexes addIndexesInRange:NSMakeRange(0, [theImage atlasImageCount])];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    BXChara2DImage* theImage = [self selectedImage];

    if (!theImage) {
        [[NSColor controlColor] set];
        NSRectFill(dirtyRect);
        return;
    }
 
    [NSGraphicsContext saveGraphicsState];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];    
    
    for (int i = 0; i < [theImage atlasImageCount]; i++) {
        int x = i % gChara2DImageDivCountX;
        int y = i / gChara2DImageDivCountX;
        
        NSRect theRect = NSMakeRect(x * gChara2DImageAtlasSizeX, y * gChara2DImageAtlasSizeY, gChara2DImageAtlasSizeX, gChara2DImageAtlasSizeY);
        
        if ([mSelectionIndexes containsIndex:i]) {
            [[NSColor selectedControlColor] set];
            NSRectFill(theRect);
        }

        if (NSIntersectsRect(dirtyRect, theRect)) {
            NSImage* nsImage = [theImage atlasImage72dpiAtIndex:i];
            [nsImage drawThumbnailInRect:NSInsetRect(theRect, 4, 4) background:YES border:YES];
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
    
    BXChara2DImage* theImage = [self selectedImage];
    int atlasCount = [theImage atlasImageCount];

    NSPoint pos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    unsigned modifierFlags = [theEvent modifierFlags];

    int x = (int)pos.x / gChara2DImageAtlasSizeX;
    int y = (int)pos.y / gChara2DImageAtlasSizeY;
    
    int index = y * gChara2DImageDivCountX + x;
    
    if (index < atlasCount) {
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
    BXChara2DImage* theImage = [self selectedImage];

    int selectionCount = [mSelectionIndexes count];
    int imageSize = gChara2DImageAtlasSizeX + (selectionCount - 1) * gChara2DImageAtlasDraggingCascadeSize;
    
    unsigned imageIndexes[selectionCount];
    [mSelectionIndexes getIndexes:imageIndexes maxCount:selectionCount inIndexRange:nil];
    
    NSImage* draggingImage = [[[NSImage alloc] initWithSize:NSMakeSize(imageSize, imageSize)] autorelease];
    [draggingImage lockFocus];
    for (int i = 0; i < selectionCount; i++) {
        NSImage* anAtlasImage = [theImage atlasImage72dpiAtIndex:imageIndexes[i]];
        NSRect theAtlasRect = NSMakeRect(i*gChara2DImageAtlasDraggingCascadeSize, i*gChara2DImageAtlasDraggingCascadeSize, gChara2DImageAtlasSizeX, gChara2DImageAtlasSizeX);
        [anAtlasImage drawThumbnailInRect:theAtlasRect background:NO border:NO];
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

