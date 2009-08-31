/*!
    @file   Karakuri_Globals.h
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

extern float    _KRColorRed;
extern float    _KRColorGreen;
extern float    _KRColorBlue;
extern float    _KRColorAlpha;

extern float    _KRClearColorRed;
extern float    _KRClearColorGreen;
extern float    _KRClearColorBlue;
extern float    _KRClearColorAlpha;

extern int      _KRTextureChangeCount;
extern int      _KRTextureBatchProcessCount;

extern std::string  _KROpenGLVersionStr;
extern float        _KROpenGLVersionValue;

extern bool     _KRIsFullScreen;

extern const std::string  KRFrameworkVersion;

