/*!
    @file   KRPNGLoader.h
    @author numata
    @date   09/08/14
    
    Please write the description of this class.
 */

#pragma once

#include "KarakuriTypes.h"
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>


GLuint KRCreatePNGGLTextureFromImageAtPath(NSString *imagePath, KRVector2D *imageSize, KRVector2D *textureSize, BOOL scalesLinear);


