//
//  BXOpenGLView.m
//  Karakuri Box
//
//  Created by numata on 10/02/28.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXOpenGLView.h"


@implementation BXOpenGLView

- (id)initWithFrame:(NSRect)frame
{
    NSOpenGLPixelFormatAttribute attrs[] = {
        NSOpenGLPFAWindow,
        NSOpenGLPFAAccelerated,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFANoRecovery,
        NSOpenGLPFAColorSize, (NSOpenGLPixelFormatAttribute)32,
        NSOpenGLPFAAlphaSize, (NSOpenGLPixelFormatAttribute)8,
        NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute)16,
        (NSOpenGLPixelFormatAttribute)0
    };
    NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
    if (!pixelFormat) {
        NSLog(@"KarakuriGLView: Failed to create a pixel format object.");
        [self release];
        return nil;
    }
    
    self = [super initWithFrame:frame
                    pixelFormat:pixelFormat];
    [pixelFormat release];
    if (self) {
        mCGLContext = (CGLContextObj)[[self openGLContext] CGLContextObj];
    }
    return self;
}

/*!
    @method     prepareOpenGL
    @abstract   OpenGLの初期化を行うために、起動後に1回だけ呼ばれます。
 */
- (void)prepareOpenGL
{
    mGraphics = new KRGraphics();
    
    CGLSetCurrentContext(mCGLContext);
    
    // アルファブレンディングの設定
    glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    // このメソッド呼び出しの直後に、reshape メソッドが呼ばれます。
    // 最初のビューポートの設定はそこで行います。
}


- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
}

/*!
 @method     reshape
 @abstract   ビューのサイズが変更される度に呼ばれます。
 起動時にも、prepareOpenGL メソッドの直後に1回呼ばれます。
 */
- (void)reshape
{
    [[self openGLContext] makeCurrentContext];
    
    // 描画対象の四角形のリセット
    NSRect frame = [self frame];
    glViewport(0, 0, (GLsizei)frame.size.width, (GLsizei)frame.size.height);
    
    // 変換行列の初期化
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    // 描画時の
    gluOrtho2D(0.0,     // 左端のx座標
               frame.size.width,   // 右端のx座標
               0.0,     // 下端のy座標
               frame.size.height);  // 上端のy座標
}


@end
