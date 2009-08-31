/*!
    @file   Karakuri_Globals.cpp
    @author numata
    @date   09/08/02
 */

#include "Karakuri_Globals.h"


int     _KRMatrixPushCount = 0;
bool    _KRTexture2DEnabled = false;
GLuint  _KRTexture2DName = GL_INVALID_VALUE;

float   _KRColorRed     = -1.0f;
float   _KRColorGreen   = -1.0f;
float   _KRColorBlue    = -1.0f;
float   _KRColorAlpha   = -1.0f;

float   _KRClearColorRed    = -1.0f;
float   _KRClearColorGreen  = -1.0f;
float   _KRClearColorBlue   = -1.0f;
float   _KRClearColorAlpha  = -1.0f;

int     _KRTextureChangeCount = 0;
int     _KRTextureBatchProcessCount = 0;

std::string     _KROpenGLVersionStr;
float           _KROpenGLVersionValue;

bool    _KRIsFullScreen = false;

const std::string     KRFrameworkVersion = "0.5.2";

