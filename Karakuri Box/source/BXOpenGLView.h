//
//  BXOpenGLView.h
//  Karakuri Box
//
//  Created by numata on 10/02/28.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>

#include "KRGraphics.h"


@interface BXOpenGLView : NSOpenGLView {
    CGLContextObj           mCGLContext;
    KRGraphics*             mGraphics;
}

@end

