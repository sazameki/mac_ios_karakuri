//
//  KRProxyView.m
//  Karakuri Library
//
//  Created by numata on 10/07/21.
//  Copyright 2010 Satoshi Numata. All rights reserved.
//

#import "KRProxyView.h"
#import <QuartzCore/QuartzCore.h>


@implementation KRProxyView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.multipleTouchEnabled = YES;
        self.backgroundColor = [UIColor lightGrayColor];
        
        mTimer = [NSTimer scheduledTimerWithTimeInterval:4.0
                                                  target:self
                                                selector:@selector(screenUpdateProc:)
                                                userInfo:nil
                                                 repeats:YES];
    }
    return self;
}

- (void)dealloc
{    
    [mTimer invalidate];
    mTimer = nil;

    if (mScreenImage) {
        [mScreenImage release];
        mScreenImage = nil;
    }
    
    [super dealloc];
}

 - (void)drawRect:(CGRect)rect
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformRotate(transform, M_PI_2);
    transform = CGAffineTransformScale(transform, 1024.0f/768, -768.0f/1024);
    
    [self setTransform:transform];

    CGRect frame = [[UIScreen mainScreen] bounds];
    
    if (mScreenImage) {
        [mScreenImage drawInRect:frame];
    }
}

- (void)screenUpdateProc:(NSTimer*)timer
{
    if (mScreenImage) {
        [mScreenImage release];
        mScreenImage = nil;
    }
    
    mScreenImage = [[mGLView currentImage] retain];
    
    [self setNeedsDisplay];
}

- (void)setGLView:(KarakuriGLView*)glView
{
    mGLView = glView;
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [mGLView touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    [mGLView touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    [mGLView touchesEnded:touches withEvent:event];
}

@end

