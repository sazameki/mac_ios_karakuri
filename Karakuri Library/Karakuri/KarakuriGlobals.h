/*!
    @file   KarakuriGlobals.h
    @author numata
    @date   09/08/02
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>
#include <string>


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


struct _KRTexture2DDrawData;

extern const int                _gKRTexture2DBatchSize;
extern _KRTexture2DDrawData     _gKRTexture2DDrawData[];
extern int                      _gKRTexture2DBatchCount;
