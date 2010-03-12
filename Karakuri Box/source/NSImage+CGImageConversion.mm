//
//  NSImage+CGImageConversion.mm
//  Karakuri Box
//
//  Created by numata on 10/03/11.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "NSImage+CGImageConversion.h"


@implementation NSImage (CGImageConversion)

- (CGImageRef)cgImage
{
    NSSize imageSize = [self size];
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);

    CGContextRef bitmapCtx = CGBitmapContextCreate(NULL/*data - pass NULL to let CG allocate the memory*/,
                                                   imageSize.width,
                                                   imageSize.height, 
                                                   8 /*bitsPerComponent*/, 
                                                   0 /*bytesPerRow - CG will calculate it for you if it's allocating the data.  This might get padded out a bit for better alignment*/, 
                                                   colorSpaceRef, 
                                                   kCGImageAlphaPremultipliedFirst);
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:bitmapCtx flipped:NO]];
    
    NSAffineTransform* transform = [NSAffineTransform transform];
    [transform scaleXBy:1.0 yBy:-1.0];
    [transform translateXBy:0.0 yBy:-imageSize.height];
    [transform concat];
    
    [self drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];
    
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapCtx);
    CGContextRelease(bitmapCtx);
    
    CGColorSpaceRelease(colorSpaceRef);
    
    return cgImage;
}

@end

