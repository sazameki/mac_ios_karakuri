/*
 *  KRTexture2D.mm
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/18.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#include "KRTexture2D.h"
#include "KRTexture2DLoader.h"
#include "KRFont.h"
#include "KRColor.h"
#include "KRPNGLoader.h"


static const int KRTexture2DBatchSize = 1024;    // KRTexture2DBatchSize * 16 bytes will be used.


struct KRTexture2DDrawData {
    GLshort vertex_x, vertex_y;
    GLfloat texCoords_x, texCoords_y;
    GLubyte colors[4];
};


static KRTexture2DDrawData  sTexture2DDrawData[KRTexture2DBatchSize*6];
static int                  sTexture2DBatchCount = 0;


void KRTexture2D::processBatchedTexture2DDraws()
{
    if (sTexture2DBatchCount == 0) {
        return;
    }

    glVertexPointer(2, GL_SHORT, sizeof(KRTexture2DDrawData), sTexture2DDrawData);
	glTexCoordPointer(2, GL_FLOAT, sizeof(KRTexture2DDrawData), ((GLshort *)sTexture2DDrawData)+2);
    glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(KRTexture2DDrawData), ((GLfloat *)(((GLshort *)sTexture2DDrawData)+2))+2);

	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
    
    glDrawArrays(GL_TRIANGLES, 0, sTexture2DBatchCount*6);
    
    sTexture2DBatchCount = 0;
    
#if __DEBUG__
    _KRTextureBatchProcessCount++;
#endif    
}


#pragma mark Constructor / Destructor

KRTexture2D::KRTexture2D(const std::string& filename)
{
    if (sTexture2DBatchCount > 0) {
        KRTexture2D::processBatchedTexture2DDraws();
    }

    mFileName = filename;
    NSString *filenameStr = [[NSString alloc] initWithCString:filename.c_str() encoding:NSUTF8StringEncoding];
    mTextureName = KRCreateGLTextureFromImageWithName(filenameStr, &mTextureTarget, &mImageSize, &mTextureSize);
    [filenameStr release];
    if (mTextureName == GL_INVALID_VALUE || mTextureName == GL_INVALID_OPERATION) {
        const char *errorFormat = "Failed to load \"%s\". Please confirm that the image file exists.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "\"%s\" の読み込みに失敗しました。画像ファイルが存在することを確認してください。";
        }
        throw KRRuntimeError(errorFormat, filename.c_str());
    }
    _KRTexture2DName = GL_INVALID_VALUE;
}

KRTexture2D::KRTexture2D(const std::string& str, KRFont *font)
{
    if (sTexture2DBatchCount > 0) {
        KRTexture2D::processBatchedTexture2DDraws();
    }

    NSString *strStr = [[NSString alloc] initWithCString:str.c_str() encoding:NSUTF8StringEncoding];
    mTextureName = KRCreateGLTextureFromString(strStr, font->getFontObject(), KRColor::White, &mTextureTarget, &mImageSize, &mTextureSize);
    [strStr release];
    if (mTextureName == GL_INVALID_VALUE || mTextureName == GL_INVALID_OPERATION) {
        const char *errorFormat = "Failed to create a texture for a string: \"%s\"";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "文字列テクスチャの生成に失敗しました。\"%s\"";
        }
        throw KRRuntimeError(errorFormat, str.c_str());
    }
    _KRTexture2DName = GL_INVALID_VALUE;
}

KRTexture2D::~KRTexture2D()
{
    if (_KRTexture2DName == mTextureName) {
        _KRTexture2DName = GL_INVALID_VALUE;
    }
    glDeleteTextures(1, &mTextureName);
}


#pragma mark -
#pragma mark Status Getting Functions

float KRTexture2D::getWidth() const
{
    return mImageSize.x;
}

float KRTexture2D::getHeight() const
{
    return mImageSize.y;
}

KRVector2D KRTexture2D::getSize() const
{
    return mImageSize;
}

KRVector2D KRTexture2D::getCenterPos() const
{
    return KRVector2D(mImageSize.x / 2, mImageSize.y / 2);
}


#pragma mark -
#pragma mark Drawing Functions

void KRTexture2D::draw(float x, float y, float alpha)
{
    draw(KRRect2D(KRVector2D(x, y), mImageSize), alpha);
}

void KRTexture2D::draw(float x, float y, const KRColor& color)
{
    draw(KRRect2D(KRVector2D(x, y), mImageSize), color);
}

void KRTexture2D::draw(const KRVector2D& pos, float alpha)
{
    draw(KRRect2D(pos, mImageSize), alpha);
}

void KRTexture2D::draw(const KRVector2D& pos, const KRColor& color)
{
    draw(pos, KRRect2DZero, 0.0f, KRVector2DZero, KRVector2D(1.0f, 1.0f), color);
}

void KRTexture2D::draw(const KRRect2D& rect, float alpha)
{
    KRVector2D scale(rect.width / mImageSize.x, rect.height / mImageSize.y);
    draw(rect.getOrigin(), KRRect2DZero, 0.0f, KRVector2DZero, scale, KRColor(1.0f, 1.0f, 1.0f, alpha));
}

void KRTexture2D::draw(const KRRect2D& rect, const KRColor& color)
{
    draw(rect.getOrigin(), KRRect2DZero, 0.0f, KRVector2DZero, KRVector2D(rect.width / mImageSize.x, rect.height / mImageSize.y), color);
}

void KRTexture2D::draw(const KRVector2D& pos, const KRRect2D& srcRect, float alpha)
{
    draw(pos, srcRect, 0.0f, KRVector2DZero, KRVector2D(1.0f, 1.0f), KRColor(1.0f, 1.0f, 1.0f, alpha));
}

void KRTexture2D::draw(const KRVector2D& pos, const KRRect2D& srcRect, const KRColor& color)
{
    draw(pos, srcRect, 0.0f, KRVector2DZero, KRVector2D(1.0f, 1.0f), color);
}

void KRTexture2D::draw(const KRVector2D& centerPos, const KRRect2D& srcRect, float rotation, const KRVector2D& origin, float scale, float alpha)
{
    draw(centerPos, srcRect, rotation, origin, KRVector2D(scale, scale), KRColor(1.0f, 1.0f, 1.0f, alpha));
}

void KRTexture2D::draw(const KRVector2D& centerPos, const KRRect2D& srcRect, float rotation, const KRVector2D& origin, float scale, const KRColor& color)
{
    draw(centerPos, srcRect, rotation, origin, KRVector2D(scale, scale), color);
}

void KRTexture2D::draw(const KRRect2D& destRect, const KRRect2D& srcRect, float alpha)
{
    KRRect2D theSrcRect = srcRect;
    if (srcRect.width == 0.0f && srcRect.height == 0.0f) {
        theSrcRect.x = 0.0f;
        theSrcRect.y = 0.0f;
        theSrcRect.width = mImageSize.x;
        theSrcRect.height = mImageSize.y;
    }
    
    KRVector2D scale(destRect.width / theSrcRect.width, destRect.height / theSrcRect.height);
    draw(destRect.getOrigin(), srcRect, 0.0f, KRVector2DZero, scale, KRColor(1.0f, 1.0f, 1.0f, alpha));
}

void KRTexture2D::draw(const KRRect2D& destRect, const KRRect2D& srcRect, const KRColor& color)
{
    KRRect2D theSrcRect = srcRect;
    if (srcRect.width == 0.0f && srcRect.height == 0.0f) {
        theSrcRect.x = 0.0f;
        theSrcRect.y = 0.0f;
        theSrcRect.width = mImageSize.x;
        theSrcRect.height = mImageSize.y;
    }
    
    KRVector2D scale(destRect.width / theSrcRect.width, destRect.height / theSrcRect.height);
    draw(destRect.getOrigin(), srcRect, 0.0f, KRVector2DZero, scale, color);
}

void KRTexture2D::draw(const KRVector2D& centerPos, const KRRect2D& srcRect, float rotation, const KRVector2D &origin, const KRVector2D &scale, float alpha)
{
    draw(centerPos, srcRect, rotation, origin, scale, KRColor(1.0f, 1.0f, 1.0f, alpha));
}

void KRTexture2D::draw(const KRVector2D& centerPos, const KRRect2D& srcRect, float rotation, const KRVector2D &origin, const KRVector2D &scale, const KRColor& color)
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
    if (srcRect.width == 0.0f && srcRect.height == 0.0f) {
        theSrcRect.x = 0.0f;
        theSrcRect.y = 0.0f;
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

    // Translate the 4 coord points according to the origin
    if (origin.x != 0.0f) {
        p1_x -= origin.x;
        p2_x -= origin.x;
        p3_x -= origin.x;
        p4_x -= origin.x;
    }
    if (origin.y != 0.0f) {
        p1_y -= origin.y;
        p2_y -= origin.y;
        p3_y -= origin.y;
        p4_y -= origin.y;
    }

    // Scale the 4 coord points
    if (scale.x != 1.0f) {
        p1_x *= scale.x;
        p2_x *= scale.x;
        p3_x *= scale.x;
        p4_x *= scale.x;
    }
    if (scale.y != 1.0f) {
        p1_y *= scale.y;
        p2_y *= scale.y;
        p3_y *= scale.y;
        p4_y *= scale.y;
    }
    
    // Rotate the 4 coord points
    if (rotation != 0.0f) {
        float cos_value = cosf(rotation);
        float sin_value = sinf(rotation);
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

    // Translate the center point to the appropriate location
    p1_x += centerPos.x;
    p2_x += centerPos.x;
    p3_x += centerPos.x;
    p4_x += centerPos.x;
    
    p1_y += centerPos.y;
    p2_y += centerPos.y;
    p3_y += centerPos.y;
    p4_y += centerPos.y;

    // Set the vertices into an array
    int batchPos = sTexture2DBatchCount*6;
    
    sTexture2DDrawData[batchPos].vertex_x = (GLfloat)p1_x;    sTexture2DDrawData[batchPos].vertex_y = (GLfloat)p1_y;
    sTexture2DDrawData[batchPos+1].vertex_x = (GLfloat)p2_x;  sTexture2DDrawData[batchPos+1].vertex_y = (GLfloat)p2_y;
    sTexture2DDrawData[batchPos+2].vertex_x = (GLfloat)p3_x;  sTexture2DDrawData[batchPos+2].vertex_y = (GLfloat)p3_y;
    sTexture2DDrawData[batchPos+3].vertex_x = (GLfloat)p2_x;  sTexture2DDrawData[batchPos+3].vertex_y = (GLfloat)p2_y;
    sTexture2DDrawData[batchPos+4].vertex_x = (GLfloat)p3_x;  sTexture2DDrawData[batchPos+4].vertex_y = (GLfloat)p3_y;
    sTexture2DDrawData[batchPos+5].vertex_x = (GLfloat)p4_x;  sTexture2DDrawData[batchPos+5].vertex_y = (GLfloat)p4_y;

    float tx_1 = texX;
    float tx_2 = texX + texWidth;
    float ty_1 = texY;
    float ty_2 = texY + texHeight;
    
    sTexture2DDrawData[batchPos].texCoords_x = tx_1;      sTexture2DDrawData[batchPos].texCoords_y = ty_2;
    sTexture2DDrawData[batchPos+1].texCoords_x = tx_2;    sTexture2DDrawData[batchPos+1].texCoords_y = ty_2;
    sTexture2DDrawData[batchPos+2].texCoords_x = tx_1;    sTexture2DDrawData[batchPos+2].texCoords_y = ty_1;
    sTexture2DDrawData[batchPos+3].texCoords_x = tx_2;    sTexture2DDrawData[batchPos+3].texCoords_y = ty_2;
    sTexture2DDrawData[batchPos+4].texCoords_x = tx_1;    sTexture2DDrawData[batchPos+4].texCoords_y = ty_1;
    sTexture2DDrawData[batchPos+5].texCoords_x = tx_2;    sTexture2DDrawData[batchPos+5].texCoords_y = ty_1;

    sTexture2DDrawData[batchPos].colors[0] =
        sTexture2DDrawData[batchPos+1].colors[0] =
        sTexture2DDrawData[batchPos+2].colors[0] =
        sTexture2DDrawData[batchPos+3].colors[0] =
        sTexture2DDrawData[batchPos+4].colors[0] =
        sTexture2DDrawData[batchPos+5].colors[0] =
            (GLubyte)(255 * color.r);

    sTexture2DDrawData[batchPos].colors[1] =
        sTexture2DDrawData[batchPos+1].colors[1] =
        sTexture2DDrawData[batchPos+2].colors[1] =
        sTexture2DDrawData[batchPos+3].colors[1] =
        sTexture2DDrawData[batchPos+4].colors[1] =
        sTexture2DDrawData[batchPos+5].colors[1] =
            (GLubyte)(255 * color.g);

    sTexture2DDrawData[batchPos].colors[2] =
        sTexture2DDrawData[batchPos+1].colors[2] =
        sTexture2DDrawData[batchPos+2].colors[2] =
        sTexture2DDrawData[batchPos+3].colors[2] =
        sTexture2DDrawData[batchPos+4].colors[2] =
        sTexture2DDrawData[batchPos+5].colors[2] =
            (GLubyte)(255 * color.b);

    sTexture2DDrawData[batchPos].colors[3] =
        sTexture2DDrawData[batchPos+1].colors[3] =
        sTexture2DDrawData[batchPos+2].colors[3] =
        sTexture2DDrawData[batchPos+3].colors[3] =
        sTexture2DDrawData[batchPos+4].colors[3] =
        sTexture2DDrawData[batchPos+5].colors[3] =
            (GLubyte)(255 * color.a);
    
    sTexture2DBatchCount++;
    
    if (sTexture2DBatchCount >= KRTexture2DBatchSize) {
        processBatchedTexture2DDraws();
    }
}

void KRTexture2D::set()
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

GLuint KRTexture2D::getTextureName() const
{
    return mTextureName;
}


#pragma mark -
#pragma mark Debugging Support

std::string KRTexture2D::to_s() const
{
    std::string ret = "<tex2>(file=\"" + mFileName + "\", ";
    ret += KRFS("name=%d, image_size=(%3.0f, %3.0f), tex_size=(%3.2f, %3.2f))", mTextureName, mImageSize.x, mImageSize.y, mTextureSize.x, mTextureSize.y);
    return ret;
}

