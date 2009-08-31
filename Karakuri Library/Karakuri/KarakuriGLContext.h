/*
 *  KarakuriGLContext.h
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/18.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#import <Karakuri/KarakuriLibrary.h>


typedef struct KarakuriGLContext {

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    CGLContextObj   cglContext;
    CGLContextObj   cglFullScreenContext;
    CFDictionaryRef oldScreenModeRef;
    BOOL            isFullScreen;
#endif
    
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    EAGLContext *eaglContext;
    GLuint      viewRenderbuffer;
    GLuint      viewFramebuffer;
    GLuint      depthRenderbuffer;
#endif

    /* The pixel dimensions of the backbuffer */
    GLint       backingWidth;
    GLint       backingHeight;

} KarakuriGLContext;

