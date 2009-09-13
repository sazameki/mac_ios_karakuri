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


/*!
    @class KRTexture2D
    @group Game 2D Graphics
 */
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
    KRTexture2D(const std::string& str, KRFont *font);
    ~KRTexture2D();
    
public:
    float       getWidth() const;
    float       getHeight() const;
    KRVector2D  getSize() const;
    KRVector2D  getCenterPos() const;
    
public:

    /*!
        @method draw
        @param x    X座標
        @param y    Y座標
        @param alpha    アルファ値
     */
    void    draw(float x, float y, float alpha=1.0f);
    
    /*!
        @method draw
        @param pos  座標
        @param alpha    アルファ値
     */
    void    draw(const KRVector2D& pos, float alpha=1.0f);

    /*!
        @method draw
        @param rect  描画先の矩形
        @param alpha    アルファ値
     */
    void    draw(const KRRect2D& rect, float alpha=1.0f);

    /*!
        @method draw
        @param pos  描画先の座標
        @param src  描画元の矩形。KRRect2DZero を指定した場合には、テクスチャ全体が描画対象となります。
        @param alpha    アルファ値
     */
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

