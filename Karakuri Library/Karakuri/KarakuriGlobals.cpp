/*!
    @file   KarakuriGlobals.cpp
    @author numata
    @date   09/08/02
 */

#include "KarakuriGlobals.h"


int     _KRMatrixPushCount = 0;
bool    _KRTexture2DEnabled = false;
GLuint  _KRTexture2DName = GL_INVALID_VALUE;

double  _KRColorRed     = -1.0;
double  _KRColorGreen   = -1.0;
double  _KRColorBlue    = -1.0;
double  _KRColorAlpha   = -1.0;

double  _KRClearColorRed    = -1.0;
double  _KRClearColorGreen  = -1.0;
double  _KRClearColorBlue   = -1.0;
double  _KRClearColorAlpha  = -1.0;

int     _KRTextureChangeCount = 0;
int     _KRTextureBatchProcessCount = 0;

std::string     _KROpenGLVersionStr;
double          _KROpenGLVersionValue;

bool    _KRIsFullScreen = false;

