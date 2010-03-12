/*!
    @file   KarakuriGlobals.h
    @author numata
    @date   09/08/02
    
    Please write the description of this class.
 */

#pragma once

#include <string>
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>


extern int      _KRMatrixPushCount;
extern bool     _KRTexture2DEnabled;
extern GLuint   _KRTexture2DName;

extern double   _KRColorRed;
extern double   _KRColorGreen;
extern double   _KRColorBlue;
extern double   _KRColorAlpha;

extern double   _KRClearColorRed;
extern double   _KRClearColorGreen;
extern double   _KRClearColorBlue;
extern double   _KRClearColorAlpha;

extern int      _KRTextureChangeCount;
extern int      _KRTextureBatchProcessCount;

extern std::string  _KROpenGLVersionStr;
extern double       _KROpenGLVersionValue;

extern bool     _KRIsFullScreen;

extern const std::string  KRFrameworkVersion;

