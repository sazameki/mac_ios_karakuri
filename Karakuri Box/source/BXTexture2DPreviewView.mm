//
//  BXTexture2DPreviewView.m
//  Karakuri Box
//
//  Created by numata on 10/09/20.
//  Copyright 2010 Satoshi Numata. All rights reserved.
//

#import "BXTexture2DPreviewView.h"
#import "BXDocument.h"


@implementation BXTexture2DPreviewView

- (BOOL)isFlipped { return YES; }

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    BXTexture2DSpec* theTexSpec = [oDocument selectedTex2DSpec];

    NSImage* image = [theTexSpec image72dpi];
    double scale = [theTexSpec previewScale];
    [image setFlipped:YES];

    NSSize imageSize = [image size];
    
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

    [[NSGraphicsContext currentContext] restoreGraphicsState];
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
