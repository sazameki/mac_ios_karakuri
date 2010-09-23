/*
 *  KRTexture2D.mm
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/18.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#include "KRTexture2DManager.h"
#include "KRTexture2DLoader.h"
#include "KRFont.h"
#include "KRColor.h"
#include "KRPNGLoader.h"
#include "KRTexture2DAtlas.h"
#include "KarakuriGlobals.h"


const int _gKRTexture2DBatchSize = 1024;    // KRTexture2DBatchSize * 16 bytes will be used.
_KRTexture2DDrawData    _gKRTexture2DDrawData[_gKRTexture2DBatchSize*6];
int                     _gKRTexture2DBatchCount = 0;


int _KRTexture2D::getResourceSize(const std::string& filename)
{
    int ret = 0;
    
    NSString* filenameStr = [NSString stringWithCString:filename.c_str() encoding:NSUTF8StringEncoding];
    NSString* filepath = [[NSBundle mainBundle] pathForResource:filenameStr ofType:nil];
    
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    if (filepath) {
        NSDictionary* fileInfo = [[NSFileManager defaultManager] fileAttributesAtPath:filepath traverseLink:NO];
        ret += (int)[fileInfo fileSize];
    }
#endif
    
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    if (filepath) {
        NSDictionary* fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:filepath
                                                                                  error:nil];
        ret += (int)[fileInfo fileSize];
    }
#endif
    
    return ret;
}

void _KRTexture2D::processBatchedTexture2DDraws()
{
    if (_gKRTexture2DBatchCount == 0) {
        return;
    }

    glVertexPointer(2, GL_SHORT, sizeof(_KRTexture2DDrawData), _gKRTexture2DDrawData);
	glTexCoordPointer(2, GL_FLOAT, sizeof(_KRTexture2DDrawData), ((GLshort*)_gKRTexture2DDrawData)+2);
    glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(_KRTexture2DDrawData), ((GLfloat*)(((GLshort*)_gKRTexture2DDrawData)+2))+2);

	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
    
    glDrawArrays(GL_TRIANGLES, 0, _gKRTexture2DBatchCount * 6);
    
    _gKRTexture2DBatchCount = 0;
    
#if __DEBUG__
    _KRTextureBatchProcessCount++;
#endif    
}


#pragma mark Constructor / Destructor

_KRTexture2D::_KRTexture2D(const std::string& filename, KRTexture2DScaleMode scaleMode)
{
    if (_gKRTexture2DBatchCount > 0) {
        _KRTexture2D::processBatchedTexture2DDraws();
    }
    
    mTextureTarget = GL_TEXTURE_2D;

    mFileName = filename;
    NSString* filenameStr = [[NSString alloc] initWithCString:filename.c_str() encoding:NSUTF8StringEncoding];
    mTextureName = KRCreateGLTextureFromImageWithName(filenameStr, &mImageSize, &mTextureSize, (scaleMode==KRTexture2DScaleModeLinear)? YES: NO);
    [filenameStr release];

    if (mTextureName == GL_INVALID_VALUE || mTextureName == GL_INVALID_OPERATION) {
        const char* errorFormat = "Failed to load \"%s\". Please confirm that the image file exists.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "\"%s\" の読み込みに失敗しました。画像ファイルが存在することを確認してください。";
        }
        throw KRRuntimeError(errorFormat, filename.c_str());
    }

    _KRTexture2DName = GL_INVALID_VALUE;
}

_KRTexture2D::_KRTexture2D(const std::string& resourceFileName, unsigned startPos, unsigned length, KRTexture2DScaleMode scaleMode)
{
    if (_gKRTexture2DBatchCount > 0) {
        _KRTexture2D::processBatchedTexture2DDraws();
    }
    
    mTextureTarget = GL_TEXTURE_2D;
    
    NSString* filenameStr = [[NSString alloc] initWithCString:resourceFileName.c_str() encoding:NSUTF8StringEncoding];
    
    NSString* filepath = [[NSBundle mainBundle] pathForResource:filenameStr ofType:nil];
    NSData* data = [[NSData alloc] initWithContentsOfMappedFile:filepath];
    NSData* imageData = [data subdataWithRange:NSMakeRange(startPos, length)];
    
    mTextureName = KRCreatePNGGLTextureFromImageData(imageData, &mImageSize, &mTextureSize, (scaleMode==KRTexture2DScaleModeLinear)? YES: NO);
    if (mTextureName == GL_INVALID_VALUE) {
        mTextureName = KRCreateGLTextureFromImageData(imageData, &mImageSize, &mTextureSize, (scaleMode==KRTexture2DScaleModeLinear)? YES: NO);
    }
    
    [data release];
    [filenameStr release];
    
    if (mTextureName == GL_INVALID_VALUE || mTextureName == GL_INVALID_OPERATION) {
        const char* errorFormat = "Failed to load \"%s\".";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "\"%s\" の読み込みに失敗しました。";
        }
        throw KRRuntimeError(errorFormat, resourceFileName.c_str());
    }
    
    _KRTexture2DName = GL_INVALID_VALUE;
}

_KRTexture2D::_KRTexture2D(const std::string& str, _KRFont* font)
{
    if (_gKRTexture2DBatchCount > 0) {
        _KRTexture2D::processBatchedTexture2DDraws();
    }
    
    NSString* strStr = [[NSString alloc] initWithCString:str.c_str() encoding:NSUTF8StringEncoding];
    mTextureName = KRCreateGLTextureFromString(strStr, font->getFontObject(), KRColor::White, &mTextureTarget, &mImageSize, &mTextureSize);
    [strStr release];
    if (mTextureName == GL_INVALID_VALUE || mTextureName == GL_INVALID_OPERATION) {
        const char* errorFormat = "Failed to create a texture for a string: \"%s\"";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "文字列テクスチャの生成に失敗しました。\"%s\"";
        }
        throw KRRuntimeError(errorFormat, str.c_str());
    }
    _KRTexture2DName = GL_INVALID_VALUE;
}

_KRTexture2D::~_KRTexture2D()
{
    if (_KRTexture2DName == mTextureName) {
        _KRTexture2DName = GL_INVALID_VALUE;
    }
    glDeleteTextures(1, &mTextureName);
}


#pragma mark -
#pragma mark Status Getting Functions

double _KRTexture2D::getWidth() const
{
    return mImageSize.x;
}

double _KRTexture2D::getHeight() const
{
    return mImageSize.y;
}

KRVector2D _KRTexture2D::getSize() const
{
    return mImageSize;
}

KRVector2D _KRTexture2D::getCenterPos() const
{
    return KRVector2D(mImageSize.x / 2, mImageSize.y / 2);
}


#pragma mark -
#pragma mark Drawing Functions (New)

void _KRTexture2D::drawAtPoint(const KRVector2D& pos, const KRColor& color)
{
    drawAtPointEx(pos, KRRect2DZero, 0.0, KRVector2DZero, KRVector2DOne, color);
}

void _KRTexture2D::drawAtPointEx(const KRVector2D& pos, const KRRect2D& srcRect, double rotate, const KRVector2D& origin_, const KRVector2D& scale, const KRColor& color)
{
    if (_KRTexture2DName != mTextureName) {
        processBatchedTexture2DDraws();
    }
    
    if (!_KRTexture2DEnabled) {
        _KRTexture2DEnabled = true;
        glEnable(GL_TEXTURE_2D);
    }
    if (_KRTexture2DName != mTextureName) {
        _KRTexture2DName = mTextureName;
        glBindTexture(GL_TEXTURE_2D, mTextureName);
        
#if __DEBUG__
        _KRTextureChangeCount++;
#endif
    }
    
    KRVector2D origin = KRVector2D(mImageSize.x * origin_.x, mImageSize.y * origin_.y);
    
    KRRect2D theSrcRect = srcRect;
    if (theSrcRect.width == 0.0 && theSrcRect.height == 0.0) {
        theSrcRect.x = 0;
        theSrcRect.y = 0;
        theSrcRect.width = mImageSize.x;
        theSrcRect.height = mImageSize.y;
    }
    theSrcRect.y = mImageSize.y - theSrcRect.y;
    
    float texX = (theSrcRect.x / mImageSize.x) * mTextureSize.x;
    float texY = (theSrcRect.y / mImageSize.y) * mTextureSize.y;
    float texWidth = (theSrcRect.width / mImageSize.x) * mTextureSize.x;
    float texHeight = (theSrcRect.height / mImageSize.y) * mTextureSize.y * -1;
    
    float p1_x = 0.0f;
    float p2_x = theSrcRect.width;
    float p3_x = 0.0f;
    float p4_x = theSrcRect.width;
    
    float p1_y = theSrcRect.height;
    float p2_y = theSrcRect.height;
    float p3_y = 0.0f;
    float p4_y = 0.0f;
    
    // Scale the 4 coord points
    if (scale.x != 1.0) {
        p1_x *= scale.x;
        p2_x *= scale.x;
        p3_x *= scale.x;
        p4_x *= scale.x;
    }
    if (scale.y != 1.0) {
        p1_y *= scale.y;
        p2_y *= scale.y;
        p3_y *= scale.y;
        p4_y *= scale.y;
    }
    
    // Translate the 4 coord points according to the origin
    if (origin.x != 0.0) {
        p1_x -= origin.x * scale.x;
        p2_x -= origin.x * scale.x;
        p3_x -= origin.x * scale.x;
        p4_x -= origin.x * scale.x;
    }
    if (origin.y != 0.0) {
        p1_y -= origin.y * scale.y;
        p2_y -= origin.y * scale.y;
        p3_y -= origin.y * scale.y;
        p4_y -= origin.y * scale.y;
    }
    
    // Rotate the 4 coord points
    if (rotate != 0.0) {
        double cos_value = cos(rotate);
        double sin_value = sin(rotate);
        float p1_x2 = p1_x * cos_value - p1_y * sin_value;
        float p2_x2 = p2_x * cos_value - p2_y * sin_value;
        float p3_x2 = p3_x * cos_value - p3_y * sin_value;
        float p4_x2 = p4_x * cos_value - p4_y * sin_value;
        
        float p1_y2 = p1_x * sin_value + p1_y * cos_value;
        float p2_y2 = p2_x * sin_value + p2_y * cos_value;
        float p3_y2 = p3_x * sin_value + p3_y * cos_value;
        float p4_y2 = p4_x * sin_value + p4_y * cos_value;
        
        p1_x = p1_x2;
        p2_x = p2_x2;
        p3_x = p3_x2;
        p4_x = p4_x2;
        
        p1_y = p1_y2;
        p2_y = p2_y2;
        p3_y = p3_y2;
        p4_y = p4_y2;
    }
    
    if (origin.x != 0.0) {
        p1_x += origin.x * scale.x;
        p2_x += origin.x * scale.x;
        p3_x += origin.x * scale.x;
        p4_x += origin.x * scale.x;
    }
    if (origin.y != 0.0) {
        p1_y += origin.y * scale.y;
        p2_y += origin.y * scale.y;
        p3_y += origin.y * scale.y;
        p4_y += origin.y * scale.y;
    }    
    
    // Translate the point to the appropriate location
    p1_x += pos.x;
    p2_x += pos.x;
    p3_x += pos.x;
    p4_x += pos.x;
    
    p1_y += pos.y;
    p2_y += pos.y;
    p3_y += pos.y;
    p4_y += pos.y;
    
    // Set the vertices into an array
    int batchPos = _gKRTexture2DBatchCount * 6;
    
    _gKRTexture2DDrawData[batchPos].vertex_x = (GLfloat)p1_x;    _gKRTexture2DDrawData[batchPos].vertex_y = (GLfloat)p1_y;
    _gKRTexture2DDrawData[batchPos+1].vertex_x = (GLfloat)p2_x;  _gKRTexture2DDrawData[batchPos+1].vertex_y = (GLfloat)p2_y;
    _gKRTexture2DDrawData[batchPos+2].vertex_x = (GLfloat)p3_x;  _gKRTexture2DDrawData[batchPos+2].vertex_y = (GLfloat)p3_y;
    _gKRTexture2DDrawData[batchPos+3].vertex_x = (GLfloat)p2_x;  _gKRTexture2DDrawData[batchPos+3].vertex_y = (GLfloat)p2_y;
    _gKRTexture2DDrawData[batchPos+4].vertex_x = (GLfloat)p3_x;  _gKRTexture2DDrawData[batchPos+4].vertex_y = (GLfloat)p3_y;
    _gKRTexture2DDrawData[batchPos+5].vertex_x = (GLfloat)p4_x;  _gKRTexture2DDrawData[batchPos+5].vertex_y = (GLfloat)p4_y;
    
    float tx_1 = texX;
    float tx_2 = texX + texWidth;
    float ty_1 = texY;
    float ty_2 = texY + texHeight;
    
    _gKRTexture2DDrawData[batchPos].texCoords_x = tx_1;      _gKRTexture2DDrawData[batchPos].texCoords_y = ty_2;
    _gKRTexture2DDrawData[batchPos+1].texCoords_x = tx_2;    _gKRTexture2DDrawData[batchPos+1].texCoords_y = ty_2;
    _gKRTexture2DDrawData[batchPos+2].texCoords_x = tx_1;    _gKRTexture2DDrawData[batchPos+2].texCoords_y = ty_1;
    _gKRTexture2DDrawData[batchPos+3].texCoords_x = tx_2;    _gKRTexture2DDrawData[batchPos+3].texCoords_y = ty_2;
    _gKRTexture2DDrawData[batchPos+4].texCoords_x = tx_1;    _gKRTexture2DDrawData[batchPos+4].texCoords_y = ty_1;
    _gKRTexture2DDrawData[batchPos+5].texCoords_x = tx_2;    _gKRTexture2DDrawData[batchPos+5].texCoords_y = ty_1;
    
    _gKRTexture2DDrawData[batchPos].colors[0] =
    _gKRTexture2DDrawData[batchPos+1].colors[0] =
    _gKRTexture2DDrawData[batchPos+2].colors[0] =
    _gKRTexture2DDrawData[batchPos+3].colors[0] =
    _gKRTexture2DDrawData[batchPos+4].colors[0] =
    _gKRTexture2DDrawData[batchPos+5].colors[0] =
    (GLubyte)(255 * color.r);
    
    _gKRTexture2DDrawData[batchPos].colors[1] =
    _gKRTexture2DDrawData[batchPos+1].colors[1] =
    _gKRTexture2DDrawData[batchPos+2].colors[1] =
    _gKRTexture2DDrawData[batchPos+3].colors[1] =
    _gKRTexture2DDrawData[batchPos+4].colors[1] =
    _gKRTexture2DDrawData[batchPos+5].colors[1] =
    (GLubyte)(255 * color.g);
    
    _gKRTexture2DDrawData[batchPos].colors[2] =
    _gKRTexture2DDrawData[batchPos+1].colors[2] =
    _gKRTexture2DDrawData[batchPos+2].colors[2] =
    _gKRTexture2DDrawData[batchPos+3].colors[2] =
    _gKRTexture2DDrawData[batchPos+4].colors[2] =
    _gKRTexture2DDrawData[batchPos+5].colors[2] =
    (GLubyte)(255 * color.b);
    
    _gKRTexture2DDrawData[batchPos].colors[3] =
    _gKRTexture2DDrawData[batchPos+1].colors[3] =
    _gKRTexture2DDrawData[batchPos+2].colors[3] =
    _gKRTexture2DDrawData[batchPos+3].colors[3] =
    _gKRTexture2DDrawData[batchPos+4].colors[3] =
    _gKRTexture2DDrawData[batchPos+5].colors[3] =
    (GLubyte)(255 * color.a);
    
    _gKRTexture2DBatchCount++;
    
    if (_gKRTexture2DBatchCount >= _gKRTexture2DBatchSize) {
        processBatchedTexture2DDraws();
    }
}

void _KRTexture2D::drawAtPointCenter(const KRVector2D& centerPos, const KRColor& color)
{
    drawAtPointCenterEx(centerPos, KRRect2DZero, 0.0, KRVector2DOne, color);
}

void _KRTexture2D::drawAtPointCenterEx(const KRVector2D& centerPos, const KRRect2D& srcRect, double rotate, const KRVector2D& scale, const KRColor& color)
{
    KRVector2D theSize = getSize();
    theSize.x *= scale.x;
    theSize.y *= scale.y;
    KRVector2D pos = centerPos - theSize / 2;

    if (_KRTexture2DName != mTextureName) {
        processBatchedTexture2DDraws();
    }
    
    if (!_KRTexture2DEnabled) {
        _KRTexture2DEnabled = true;
        glEnable(GL_TEXTURE_2D);
    }
    if (_KRTexture2DName != mTextureName) {
        _KRTexture2DName = mTextureName;
        glBindTexture(GL_TEXTURE_2D, mTextureName);
        
#if __DEBUG__
        _KRTextureChangeCount++;
#endif
    }
    
    KRVector2D origin = KRVector2D(mImageSize.x * 0.5, mImageSize.y * 0.5);

    KRRect2D theSrcRect = srcRect;
    if (theSrcRect.width == 0.0 && theSrcRect.height == 0.0) {
        theSrcRect.x = 0;
        theSrcRect.y = 0;
        theSrcRect.width = mImageSize.x;
        theSrcRect.height = mImageSize.y;
    }
    theSrcRect.y = mImageSize.y - theSrcRect.y;
    
    float texX = (theSrcRect.x / mImageSize.x) * mTextureSize.x;
    float texY = (theSrcRect.y / mImageSize.y) * mTextureSize.y;
    float texWidth = (theSrcRect.width / mImageSize.x) * mTextureSize.x;
    float texHeight = (theSrcRect.height / mImageSize.y) * mTextureSize.y * -1;
    
    float p1_x = 0.0f;
    float p2_x = theSrcRect.width;
    float p3_x = 0.0f;
    float p4_x = theSrcRect.width;
    
    float p1_y = theSrcRect.height;
    float p2_y = theSrcRect.height;
    float p3_y = 0.0f;
    float p4_y = 0.0f;
    
    // Scale the 4 coord points
    if (scale.x != 1.0) {
        p1_x *= scale.x;
        p2_x *= scale.x;
        p3_x *= scale.x;
        p4_x *= scale.x;
    }
    if (scale.y != 1.0) {
        p1_y *= scale.y;
        p2_y *= scale.y;
        p3_y *= scale.y;
        p4_y *= scale.y;
    }
    
    // Translate the 4 coord points according to the origin
    if (origin.x != 0.0) {
        p1_x -= origin.x * scale.x;
        p2_x -= origin.x * scale.x;
        p3_x -= origin.x * scale.x;
        p4_x -= origin.x * scale.x;
    }
    if (origin.y != 0.0) {
        p1_y -= origin.y * scale.y;
        p2_y -= origin.y * scale.y;
        p3_y -= origin.y * scale.y;
        p4_y -= origin.y * scale.y;
    }
    
    // Rotate the 4 coord points
    if (rotate != 0.0) {
        double cos_value = cos(rotate);
        double sin_value = sin(rotate);
        float p1_x2 = p1_x * cos_value - p1_y * sin_value;
        float p2_x2 = p2_x * cos_value - p2_y * sin_value;
        float p3_x2 = p3_x * cos_value - p3_y * sin_value;
        float p4_x2 = p4_x * cos_value - p4_y * sin_value;
        
        float p1_y2 = p1_x * sin_value + p1_y * cos_value;
        float p2_y2 = p2_x * sin_value + p2_y * cos_value;
        float p3_y2 = p3_x * sin_value + p3_y * cos_value;
        float p4_y2 = p4_x * sin_value + p4_y * cos_value;
        
        p1_x = p1_x2;
        p2_x = p2_x2;
        p3_x = p3_x2;
        p4_x = p4_x2;
        
        p1_y = p1_y2;
        p2_y = p2_y2;
        p3_y = p3_y2;
        p4_y = p4_y2;
    }
    
    // Translate the point to the appropriate location
    p1_x += centerPos.x;
    p2_x += centerPos.x;
    p3_x += centerPos.x;
    p4_x += centerPos.x;
    
    p1_y += centerPos.y;
    p2_y += centerPos.y;
    p3_y += centerPos.y;
    p4_y += centerPos.y;
    
    // Set the vertices into an array
    int batchPos = _gKRTexture2DBatchCount * 6;
    
    _gKRTexture2DDrawData[batchPos].vertex_x = (GLfloat)p1_x;    _gKRTexture2DDrawData[batchPos].vertex_y = (GLfloat)p1_y;
    _gKRTexture2DDrawData[batchPos+1].vertex_x = (GLfloat)p2_x;  _gKRTexture2DDrawData[batchPos+1].vertex_y = (GLfloat)p2_y;
    _gKRTexture2DDrawData[batchPos+2].vertex_x = (GLfloat)p3_x;  _gKRTexture2DDrawData[batchPos+2].vertex_y = (GLfloat)p3_y;
    _gKRTexture2DDrawData[batchPos+3].vertex_x = (GLfloat)p2_x;  _gKRTexture2DDrawData[batchPos+3].vertex_y = (GLfloat)p2_y;
    _gKRTexture2DDrawData[batchPos+4].vertex_x = (GLfloat)p3_x;  _gKRTexture2DDrawData[batchPos+4].vertex_y = (GLfloat)p3_y;
    _gKRTexture2DDrawData[batchPos+5].vertex_x = (GLfloat)p4_x;  _gKRTexture2DDrawData[batchPos+5].vertex_y = (GLfloat)p4_y;
    
    float tx_1 = texX;
    float tx_2 = texX + texWidth;
    float ty_1 = texY;
    float ty_2 = texY + texHeight;
    
    _gKRTexture2DDrawData[batchPos].texCoords_x = tx_1;      _gKRTexture2DDrawData[batchPos].texCoords_y = ty_2;
    _gKRTexture2DDrawData[batchPos+1].texCoords_x = tx_2;    _gKRTexture2DDrawData[batchPos+1].texCoords_y = ty_2;
    _gKRTexture2DDrawData[batchPos+2].texCoords_x = tx_1;    _gKRTexture2DDrawData[batchPos+2].texCoords_y = ty_1;
    _gKRTexture2DDrawData[batchPos+3].texCoords_x = tx_2;    _gKRTexture2DDrawData[batchPos+3].texCoords_y = ty_2;
    _gKRTexture2DDrawData[batchPos+4].texCoords_x = tx_1;    _gKRTexture2DDrawData[batchPos+4].texCoords_y = ty_1;
    _gKRTexture2DDrawData[batchPos+5].texCoords_x = tx_2;    _gKRTexture2DDrawData[batchPos+5].texCoords_y = ty_1;
    
    _gKRTexture2DDrawData[batchPos].colors[0] =
    _gKRTexture2DDrawData[batchPos+1].colors[0] =
    _gKRTexture2DDrawData[batchPos+2].colors[0] =
    _gKRTexture2DDrawData[batchPos+3].colors[0] =
    _gKRTexture2DDrawData[batchPos+4].colors[0] =
    _gKRTexture2DDrawData[batchPos+5].colors[0] =
        (GLubyte)(255 * color.r);
    
    _gKRTexture2DDrawData[batchPos].colors[1] =
    _gKRTexture2DDrawData[batchPos+1].colors[1] =
    _gKRTexture2DDrawData[batchPos+2].colors[1] =
    _gKRTexture2DDrawData[batchPos+3].colors[1] =
    _gKRTexture2DDrawData[batchPos+4].colors[1] =
    _gKRTexture2DDrawData[batchPos+5].colors[1] =
        (GLubyte)(255 * color.g);
    
    _gKRTexture2DDrawData[batchPos].colors[2] =
    _gKRTexture2DDrawData[batchPos+1].colors[2] =
    _gKRTexture2DDrawData[batchPos+2].colors[2] =
    _gKRTexture2DDrawData[batchPos+3].colors[2] =
    _gKRTexture2DDrawData[batchPos+4].colors[2] =
    _gKRTexture2DDrawData[batchPos+5].colors[2] =
        (GLubyte)(255 * color.b);
    
    _gKRTexture2DDrawData[batchPos].colors[3] =
    _gKRTexture2DDrawData[batchPos+1].colors[3] =
    _gKRTexture2DDrawData[batchPos+2].colors[3] =
    _gKRTexture2DDrawData[batchPos+3].colors[3] =
    _gKRTexture2DDrawData[batchPos+4].colors[3] =
    _gKRTexture2DDrawData[batchPos+5].colors[3] =
        (GLubyte)(255 * color.a);
    
    _gKRTexture2DBatchCount++;
    
    if (_gKRTexture2DBatchCount >= _gKRTexture2DBatchSize) {
        processBatchedTexture2DDraws();
    }
}

void _KRTexture2D::drawInRect(const KRRect2D& destRect, const KRColor& color)
{
    drawInRect(destRect, KRRect2DZero, color);
}

void _KRTexture2D::drawInRect(const KRRect2D& destRect, const KRRect2D& srcRect, const KRColor& color)
{
    if (_KRTexture2DName != mTextureName) {
        processBatchedTexture2DDraws();
    }
    
    if (!_KRTexture2DEnabled) {
        _KRTexture2DEnabled = true;
        glEnable(GL_TEXTURE_2D);
    }
    if (_KRTexture2DName != mTextureName) {
        _KRTexture2DName = mTextureName;
        glBindTexture(GL_TEXTURE_2D, mTextureName);
        
#if __DEBUG__
        _KRTextureChangeCount++;
#endif
    }
    
    KRRect2D theSrcRect = srcRect;
    if (theSrcRect.width == 0.0 || theSrcRect.height == 0.0) {
        theSrcRect.x = 0.0;
        theSrcRect.y = 0.0;
        theSrcRect.width = mImageSize.x;
        theSrcRect.height = mImageSize.y;
    }
    theSrcRect.y = mImageSize.y - theSrcRect.y;
    
    float texX = (theSrcRect.x / mImageSize.x) * mTextureSize.x;
    float texY = (theSrcRect.y / mImageSize.y) * mTextureSize.y;
    float texWidth = (theSrcRect.width / mImageSize.x) * mTextureSize.x;
    float texHeight = (theSrcRect.height / mImageSize.y) * mTextureSize.y * -1;
    
    short p1_x = destRect.x;
    short p2_x = destRect.x + destRect.width;
    short p3_x = destRect.x;
    short p4_x = destRect.x + destRect.width;
    
    short p1_y = destRect.y + destRect.height;
    short p2_y = destRect.y + destRect.height;
    short p3_y = destRect.y;
    short p4_y = destRect.y;
    
    // Set the vertices into an array
    int batchPos = _gKRTexture2DBatchCount * 6;
    
    _gKRTexture2DDrawData[batchPos].vertex_x = p1_x;    _gKRTexture2DDrawData[batchPos].vertex_y = p1_y;
    _gKRTexture2DDrawData[batchPos+1].vertex_x = p2_x;  _gKRTexture2DDrawData[batchPos+1].vertex_y = p2_y;
    _gKRTexture2DDrawData[batchPos+2].vertex_x = p3_x;  _gKRTexture2DDrawData[batchPos+2].vertex_y = p3_y;
    _gKRTexture2DDrawData[batchPos+3].vertex_x = p2_x;  _gKRTexture2DDrawData[batchPos+3].vertex_y = p2_y;
    _gKRTexture2DDrawData[batchPos+4].vertex_x = p3_x;  _gKRTexture2DDrawData[batchPos+4].vertex_y = p3_y;
    _gKRTexture2DDrawData[batchPos+5].vertex_x = p4_x;  _gKRTexture2DDrawData[batchPos+5].vertex_y = p4_y;
    
    float tx_1 = texX;
    float tx_2 = texX + texWidth;
    float ty_1 = texY;
    float ty_2 = texY + texHeight;
    
    _gKRTexture2DDrawData[batchPos].texCoords_x = tx_1;      _gKRTexture2DDrawData[batchPos].texCoords_y = ty_2;
    _gKRTexture2DDrawData[batchPos+1].texCoords_x = tx_2;    _gKRTexture2DDrawData[batchPos+1].texCoords_y = ty_2;
    _gKRTexture2DDrawData[batchPos+2].texCoords_x = tx_1;    _gKRTexture2DDrawData[batchPos+2].texCoords_y = ty_1;
    _gKRTexture2DDrawData[batchPos+3].texCoords_x = tx_2;    _gKRTexture2DDrawData[batchPos+3].texCoords_y = ty_2;
    _gKRTexture2DDrawData[batchPos+4].texCoords_x = tx_1;    _gKRTexture2DDrawData[batchPos+4].texCoords_y = ty_1;
    _gKRTexture2DDrawData[batchPos+5].texCoords_x = tx_2;    _gKRTexture2DDrawData[batchPos+5].texCoords_y = ty_1;
    
    _gKRTexture2DDrawData[batchPos].colors[0] =
    _gKRTexture2DDrawData[batchPos+1].colors[0] =
    _gKRTexture2DDrawData[batchPos+2].colors[0] =
    _gKRTexture2DDrawData[batchPos+3].colors[0] =
    _gKRTexture2DDrawData[batchPos+4].colors[0] =
    _gKRTexture2DDrawData[batchPos+5].colors[0] =
        (GLubyte)(255 * color.r);
    
    _gKRTexture2DDrawData[batchPos].colors[1] =
    _gKRTexture2DDrawData[batchPos+1].colors[1] =
    _gKRTexture2DDrawData[batchPos+2].colors[1] =
    _gKRTexture2DDrawData[batchPos+3].colors[1] =
    _gKRTexture2DDrawData[batchPos+4].colors[1] =
    _gKRTexture2DDrawData[batchPos+5].colors[1] =
        (GLubyte)(255 * color.g);
    
    _gKRTexture2DDrawData[batchPos].colors[2] =
    _gKRTexture2DDrawData[batchPos+1].colors[2] =
    _gKRTexture2DDrawData[batchPos+2].colors[2] =
    _gKRTexture2DDrawData[batchPos+3].colors[2] =
    _gKRTexture2DDrawData[batchPos+4].colors[2] =
    _gKRTexture2DDrawData[batchPos+5].colors[2] =
        (GLubyte)(255 * color.b);
    
    _gKRTexture2DDrawData[batchPos].colors[3] =
    _gKRTexture2DDrawData[batchPos+1].colors[3] =
    _gKRTexture2DDrawData[batchPos+2].colors[3] =
    _gKRTexture2DDrawData[batchPos+3].colors[3] =
    _gKRTexture2DDrawData[batchPos+4].colors[3] =
    _gKRTexture2DDrawData[batchPos+5].colors[3] =
        (GLubyte)(255 * color.a);
    
    _gKRTexture2DBatchCount++;
    
    if (_gKRTexture2DBatchCount >= _gKRTexture2DBatchSize) {
        processBatchedTexture2DDraws();
    }    
}


#pragma mark -

void _KRTexture2D::set()
{
    if (!_KRTexture2DEnabled) {
        _KRTexture2DEnabled = true;
        glEnable(GL_TEXTURE_2D);
    }
    if (_KRTexture2DName != mTextureName) {
        _KRTexture2DName = mTextureName;
        glBindTexture(GL_TEXTURE_2D, mTextureName);
        
#if __DEBUG__
        _KRTextureChangeCount++;
#endif
    }
}

#pragma mark -
#pragma mark Exporting Texture Name

GLuint _KRTexture2D::getTextureName() const
{
    return mTextureName;
}


#pragma mark -
#pragma mark Debugging Support

std::string _KRTexture2D::to_s() const
{
    std::string ret = "<tex2>(file=\"" + mFileName + "\", ";
    ret += KRFS("name=%d, image_size=(%3.0f, %3.0f), tex_size=(%3.2f, %3.2f))", mTextureName, mImageSize.x, mImageSize.y, mTextureSize.x, mTextureSize.y);
    return ret;
}

