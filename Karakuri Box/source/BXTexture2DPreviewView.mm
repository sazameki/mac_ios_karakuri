//
//  BXTexture2DPreviewView.m
//  Karakuri Box
//
//  Created by numata on 10/09/20.
//  Copyright 2010 Satoshi Numata. All rights reserved.
//

#import "BXTexture2DPreviewView.h"
#import "BXDocument.h"
#import "BXTexture2DAtlas.h"


@implementation BXTexture2DPreviewView

- (BOOL)isFlipped { return YES; }

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        mShowsAtlas = YES;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [NSGraphicsContext saveGraphicsState];
    
    NSRect frame = [self frame];
    NSImage* transpImage = [NSImage imageNamed:@"transparent_pattern.png"];
    float yOffset = NSMaxY([self convertRect:frame toView:nil]);
    [[NSGraphicsContext currentContext] setPatternPhase:NSMakePoint(0, yOffset)];
    [[NSColor colorWithPatternImage:transpImage] set];
    frame.origin = NSZeroPoint;
    [NSBezierPath fillRect:frame];

    [NSGraphicsContext restoreGraphicsState];    
    
    
    BXTexture2DSpec* theTexSpec = [oDocument selectedTex2DSpec];

    NSImage* image = [theTexSpec image72dpi];
    double scale = [theTexSpec previewScale];
    [image setFlipped:YES];

    NSSize imageSize = [image size];
    [oDocument setTex2DSizeDescription:[NSString stringWithFormat:@"%d x %d", (int)imageSize.width, (int)imageSize.height]];
    
    [[NSGraphicsContext currentContext] saveGraphicsState];
    
    if (scale < 1.0) {
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    } else {
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
    }
    
    [image drawInRect:NSMakeRect(0, 0, imageSize.width * scale, imageSize.height * scale)
             fromRect:NSMakeRect(0, 0, imageSize.width, imageSize.height)
            operation:NSCompositeSourceOver
             fraction:1.0];
    
    if (mShowsAtlas) {
        [[NSGraphicsContext currentContext] setShouldAntialias:NO];
        
        int atlasCount = [theTexSpec atlasCount];
        for (int i = 0; i < atlasCount; i++) {
            BXTexture2DAtlas* anAtlas = [theTexSpec atlasAtIndex:i];
            KRVector2DInt atlasStartPos = [anAtlas startPos];
            KRVector2DInt atlasSize = [anAtlas size];
            KRVector2DInt atlasCount = [anAtlas count];
            for (int y = 0; y < atlasCount.y; y++) {
                for (int x = 0; x < atlasCount.x; x++) {
                    NSRect theRect = NSMakeRect((atlasStartPos.x+atlasSize.x*x) * scale, (atlasStartPos.y+atlasSize.y*y) * scale + 1, atlasSize.x * scale - 1, atlasSize.y * scale - 1);
                    
                    [[NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:0.2] set];
                    [NSBezierPath fillRect:theRect];

                    [[NSColor redColor] set];
                    [NSBezierPath strokeRect:theRect];

                    [[NSColor colorWithCalibratedWhite:1.0 alpha:0.8] set];
                    [NSBezierPath strokeRect:NSInsetRect(theRect, 1.0, 1.0)];
                }
            }
        }
    }

    [[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (void)setShowsAtlas:(BOOL)flag
{
    mShowsAtlas = flag;
    [self setNeedsDisplay:YES];
}

- (void)updateFrame
{
    BXTexture2DSpec* theTexSpec = [oDocument selectedTex2DSpec];
    
    NSImage* image = [theTexSpec image72dpi];
    double scale = [theTexSpec previewScale];
    NSSize imageSize = [image size];
    imageSize.width *= scale;
    imageSize.height *= scale;
    
    NSRect frame = [self frame];
    frame.size = imageSize;
    [self setFrame:frame];
}

@end
