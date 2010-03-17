//
//  NSImage+BXEx.mm
//  Karakuri Box
//
//  Created by numata on 10/03/09.
//  Copyright 2010 Satoshi Numata. All rights reserved.
//

#import "NSImage+BXEx.h"


@implementation NSImage (BXEx)

- (void)drawThumbnailInRect:(NSRect)rect background:(BOOL)drawsBG border:(BOOL)drawsBorder
{
    [self setFlipped:YES];
    
    NSSize theSize = [self size];
    
    double sourceRatio = theSize.width / theSize.height;
    double targetRatio = rect.size.width / rect.size.height;

    NSRect theRect = rect;
    if (sourceRatio < targetRatio) {
        // 横方向のサイズを縮小
        theRect.size.width *= sourceRatio;
        theRect.size.width = (int)theRect.size.width;
        theRect.origin.x = rect.origin.x + (rect.size.width - theRect.size.width) / 2;
    } else {
        // 縦方向のサイズを縮小
        theRect.size.height /= sourceRatio;
        theRect.size.height = (int)theRect.size.height;
        theRect.origin.y = rect.origin.y + (rect.size.height - theRect.size.height) / 2;
    }

    if (drawsBG) {
        NSImage* transpImage = [NSImage imageNamed:@"transparent_pattern.png"];
        [[NSColor colorWithPatternImage:transpImage] set];
        //[[NSGraphicsContext currentContext] setPatternPhase:
        //    NSMakePoint(theRect.origin.x, -(int)theRect.size.height % 8)];
        NSRectFill(theRect);
        //[[NSBezierPath bezierPathWithRect:theRect] fill];
    }

    [self drawInRect:theRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    
    if (drawsBorder) {
        NSRect frameRect = NSInsetRect(theRect, -1, -1);
        [[NSColor blackColor] set];
        NSFrameRect(frameRect);
    } else {
        [[NSColor blackColor] set];
        NSFrameRect(theRect);
    }
}

- (NSArray*)divideByX:(int)divX y:(int)divY
{
    [self setFlipped:YES];

    NSMutableArray* ret = [NSMutableArray array];
    
    NSSize theSize = [self size];
    NSSize oneSize = NSMakeSize((int)(theSize.width / divX), (int)(theSize.height / divY));

    for (int y = 0; y < divY; y++) {
        for (int x = 0; x < divX; x++) {
            NSImage* anImage = [[[NSImage alloc] initWithSize:oneSize] autorelease];
            
            [anImage lockFocus];
            
            [self drawInRect:NSMakeRect(0, 0, oneSize.width, oneSize.height)
                    fromRect:NSMakeRect(x*oneSize.width, y*oneSize.height, oneSize.width, oneSize.height)
                   operation:NSCompositeSourceOver
                    fraction:1.0f];

            [anImage unlockFocus];
            
            [ret addObject:anImage];
        }
    }
    
    return ret;
}

- (NSData*)pngData
{
    NSData* tiffData = [self TIFFRepresentation];
    NSBitmapImageRep* bitmapImageRep = [NSBitmapImageRep imageRepWithData:tiffData];

    NSDictionary* pngInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                        forKey:NSImageInterlaced];

    return [bitmapImageRep representationUsingType:NSPNGFileType
                                        properties:pngInfo];    
}

@end

