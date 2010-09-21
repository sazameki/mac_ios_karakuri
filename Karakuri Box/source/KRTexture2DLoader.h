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
#import "BXTexture2DSpec.h"


GLuint KRCreateGLTextureFromImageWithName(NSString *imageName, GLenum *textureTarget, KRVector2D *imageSize, KRVector2D *textureSize, BOOL scalesLinear=NO);
GLuint KRCreateGLTextureFromString(NSString *str, void *fontObj, const KRColor& color, GLenum *textureTarget, KRVector2D *imageSize, KRVector2D *textureSize);
GLuint KRCreateGLTextureFromNSImage(NSImage* nsImage, GLenum *textureTarget, KRVector2D *imageSize, KRVector2D *textureSize, BOOL scalesLinear=NO);
GLuint KRCreateGLTextureFromTexture2D(BXTexture2DSpec* tex, GLenum *textureTarget, KRVector2D *imageSize, KRVector2D *textureSize, BOOL scalesLinear=NO);
GLuint KRCreateGLTextureFromTexture2DAtlas(BXTexture2DSpec* tex, NSRect atlasRect, GLenum *textureTarget, KRVector2D *imageSize, KRVector2D *textureSize, BOOL scalesLinear=NO);


