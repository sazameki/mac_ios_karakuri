/*!
    @file   KRPNGLoader.h
    @author numata
    @date   09/08/14
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>


GLuint KRCreatePNGGLTextureFromImageAtPath(NSString *imagePath, KRVector2D *imageSize, KRVector2D *textureSize, BOOL scalesLinear);


