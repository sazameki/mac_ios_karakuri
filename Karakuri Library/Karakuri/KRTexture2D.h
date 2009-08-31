/*
 *  KRTexture2D.h
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/18.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include <Karakuri/KRColor.h>
#include <Karakuri/Karakuri_Types.h>


class KRFont;


class KRTexture2D : public KRObject {
    
private:
    std::string mFileName;
    GLuint      mTextureName;
    GLenum      mTextureTarget;
    KRVector2D  mImageSize;         //!< The actual size of the image.
    KRVector2D  mTextureSize;       //!< Full size of the area used as a texture.
    
    void        *mTexture2DImpl;
    
public:
    KRTexture2D(const std::string& filename);
    KRTexture2D(const std::string& str, KRFont *font, const KRColor& color);
    ~KRTexture2D();
    
public:
    float       getWidth() const;
    float       getHeight() const;
    KRVector2D  getSize() const;
    KRVector2D  getCenterPos() const;
    
public:
    void    draw(float x, float y, float alpha=1.0f);
    void    draw(const KRVector2D& pos, float alpha=1.0f);
    void    draw(const KRRect2D& rect, float alpha=1.0f);
    void    draw(const KRVector2D& pos, const KRRect2D& srcRect, float alpha=1.0f);
    void    draw(const KRRect2D& destRect, const KRRect2D& srcRect, float alpha=1.0f);
    void    draw(const KRVector2D& centerPos, const KRRect2D& srcRect, float rotation, const KRVector2D& origin, float scale=1.0f, float alpha=1.0f);
    void    draw(const KRVector2D& centerPos, const KRRect2D& srcRect, float rotation, const KRVector2D &origin, const KRVector2D &scale, float alpha = 1.0f);

    void    draw(float x, float y, const KRColor& color);
    void    draw(const KRVector2D& pos, const KRColor& color);
    void    draw(const KRRect2D& rect, const KRColor& color);
    void    draw(const KRVector2D& pos, const KRRect2D& srcRect, const KRColor& color);
    void    draw(const KRRect2D& destRect, const KRRect2D& srcRect, const KRColor& color);
    void    draw(const KRVector2D& centerPos, const KRRect2D& srcRect, float rotation, const KRVector2D& origin, float scale, const KRColor& color);
    void    draw(const KRVector2D& centerPos, const KRRect2D& srcRect, float rotation, const KRVector2D &origin, const KRVector2D &scale, const KRColor& color);
    
public:
    GLuint  getTextureName() const KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    set() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

public:
    static void processBatchedTexture2DDraws() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

#pragma mark -
#pragma mark Debug Support

public:
    std::string to_s() const;
    
};

