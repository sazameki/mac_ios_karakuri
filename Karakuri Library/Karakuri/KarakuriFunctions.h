//
//  KarakuriFunctions.h
//  Karakuri Prototype
//
//  Created by numata on 09/07/22.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#pragma once

#include <Karakuri/KarakuriLibrary.h>

#include <Karakuri/Karakuri_Globals.h>


#define KRMin(a, b)  ((a) < (b))? (a): (b);
#define KRMax(a, b)  ((a) > (b))? (a): (b);

#define KRPushMatrix()\
    _KRMatrixPushCount++;\
    glPushMatrix();
#define KRPopMatrix()\
    KRTexture2D::processBatchedTexture2DDraws();\
    _KRMatrixPushCount--;\
    glPopMatrix();

#define KRRotateScreen2D(angle, centerPos)     glTranslatef(((centerPos).x), ((centerPos).y), 0.0f);glRotatef(((angle)*180)/M_PI, 0.0f, 0.0f, 1.0f);glTranslatef(-((centerPos).x), -((centerPos).y), 0.0f);
#define KRRotate2D(angle)       glRotatef(((angle)*180)/M_PI, 0.0f, 0.0f, 1.0f);
#define KRTranslate2D(x, y)     glTranslatef((x), (y), 0.0f);
#define KRScale2D(x, y)         glScalef((x), (y), 1.0f);


void    KRSleep(float interval);
float   KRCurrentTime();

bool    KRCheckOpenGLExtensionSupported(const std::string& extensionName);

std::string KRGetKarakuriVersion();

