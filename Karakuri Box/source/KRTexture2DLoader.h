/*
 *  KRTexture2DLoader.h
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/18.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include "KRColor.h"
#include "KarakuriTypes.h"
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>
#import "BXChara2DImage.h"


GLuint KRCreateGLTextureFromImageWithName(NSString *imageName, GLenum *textureTarget, KRVector2D *imageSize, KRVector2D *textureSize, BOOL scalesLinear=NO);
GLuint KRCreateGLTextureFromString(NSString *str, void *fontObj, const KRColor& color, GLenum *textureTarget, KRVector2D *imageSize, KRVector2D *textureSize);
GLuint KRCreateGLTextureFromChara2DImage(BXChara2DImage* charaImage, int atlasIndex, GLenum *textureTarget, KRVector2D *imageSize, KRVector2D *textureSize, BOOL scalesLinear=NO);


