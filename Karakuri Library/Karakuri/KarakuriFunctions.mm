//
//  KarakuriFunctions.mm
//  Karakuri Prototype
//
//  Created by numata on 09/07/22.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "KarakuriFunctions.h"
#import "Karakuri_Defines.h"

#include "KarakuriGame.h"
#include <string>

#import <Foundation/Foundation.h>


inline void KRRotate2D(double angle)
{
#if defined(KR_IPHONE) && !defined(KR_IPHONE_MACOSX_EMU)
    glRotatef(((float)angle * 180) / M_PI, 0.0f, 0.0f, 1.0f);
#else
    glRotated((angle * 180) / M_PI, 0.0, 0.0, 1.0);
#endif    
}

inline void KRRotate2D(double angle, const KRVector2D& centerPos)
{
#if defined(KR_IPHONE) && !defined(KR_IPHONE_MACOSX_EMU)
    glTranslatef((float)centerPos.x, (float)centerPos.y, 0.0f);
    glRotatef(((float)angle * 180) / M_PI, 0.0f, 0.0f, 1.0f);
    glTranslatef((float)(-centerPos.x), (float)(-centerPos.y), 0.0f);
#else
    glTranslated(centerPos.x, centerPos.y, 0.0);
    glRotated((angle * 180) / M_PI, 0.0, 0.0, 1.0);
    glTranslated(-centerPos.x, -centerPos.y, 0.0);
#endif    
}

inline void KRScale2D(double x, double y)
{
#if defined(KR_IPHONE) && !defined(KR_IPHONE_MACOSX_EMU)
    glScalef((float)x, (float)y, 1.0f);
#else
    glScaled(x, y, 1.0);
#endif
}

inline void KRScale2D(const KRVector2D& scale)
{
    KRScale2D(scale.x, scale.y);
}

inline void KRTranslate2D(double x, double y)
{
#if defined(KR_IPHONE) && !defined(KR_IPHONE_MACOSX_EMU)
    glTranslatef((float)x, (float)y, 0.0f);
#else
    glTranslated(x, y, 0.0);
#endif    
}

inline void KRTranslate2D(const KRVector2D& size)
{
    KRTranslate2D(size.x, size.y);
}

void KRSleep(double interval)
{
    [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:interval]];
}

double KRCurrentTime()
{
    return [NSDate timeIntervalSinceReferenceDate];
}

void KRChangeWorld(const std::string& worldName)
{
    gKRGameInst->changeWorld(worldName);
}

bool KRCheckOpenGLExtensionSupported(const std::string& extensionName)
{
    const char *extensions = (const char *)glGetString(GL_EXTENSIONS);
    return (strstr(extensions, extensionName.c_str()) != NULL);
}

std::string KRGetKarakuriVersion()
{
    return KARAKURI_FRAMEWORK_VERSION;
}

