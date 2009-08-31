/*
 *  KRTexture2DLoader.h
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/18.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>
#include <Karakuri/KRColor.h>


GLuint KRCreateGLTextureFromImageWithName(NSString *imageName, GLenum *textureTarget, KRVector2D *imageSize, KRVector2D *textureSize) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
GLuint KRCreateGLTextureFromString(NSString *str, void *fontObj, const KRColor& color, GLenum *textureTarget, KRVector2D *imageSize, KRVector2D *textureSize) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;


