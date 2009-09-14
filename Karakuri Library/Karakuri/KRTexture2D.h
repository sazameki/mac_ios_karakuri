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
    <p>2次元のテクスチャを表すためのクラスです。</p>
    <p>テクスチャのサイズは、横幅・高さともに1024ピクセル以内である必要があります。このサイズを超えている画像が指定された場合には、実行時例外が発生してゲームが強制終了します。</p>
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
    /*!
        @task 状態取得のための関数
     */

    /*!
        @method getWidth
        テクスチャの横幅をリターンします（ピクセル単位）。
     */
    float       getWidth() const;
    
    /*!
        @method getHeight
        テクスチャの高さをリターンします（ピクセル単位）。
     */
    float       getHeight() const;
    
    /*!
        @method getSize
        テクスチャのサイズをリターンします（ピクセル単位）。
     */
    KRVector2D  getSize() const;
    
    /*!
        @method getCenterPos
        テクスチャの中心点をリターンします（ピクセル単位）。
     */
    KRVector2D  getCenterPos() const;
    
public:
    /*!
        @task 描画のための関数
     */
    
    /*!
        @method draw
        @param x    X座標
        @param y    Y座標
        @param alpha    アルファ値
        指定された座標にこのテクスチャを描画します。透明度も指定できます。
     */
    void    draw(float x, float y, float alpha=1.0f);
    
    /*!
        @method draw
        @param pos  座標
        @param alpha    アルファ値
        指定された座標にこのテクスチャを描画します。透明度も指定できます。
     */
    void    draw(const KRVector2D& pos, float alpha=1.0f);

    /*!
        @method draw
        @param rect  描画先の矩形
        @param alpha    アルファ値
        指定された矩形内にこのテクスチャを描画します（透明度 alpha）。
     */
    void    draw(const KRRect2D& rect, float alpha=1.0f);

    /*!
        @method draw
        @param pos  描画先の座標
        @param src  描画元の矩形。KRRect2DZero を指定した場合には、テクスチャ全体が描画対象となります。
        @param alpha    アルファ値
        指定された領域を、指定された座標に描画します（透明度 alpha）。
     */
    void    draw(const KRVector2D& pos, const KRRect2D& srcRect, float alpha=1.0f);
    
    /*!
        @method draw
     */
    void    draw(const KRRect2D& destRect, const KRRect2D& srcRect, float alpha=1.0f);
    
    /*!
        @method draw
        指定された座標を中心点として、指定された領域を描画します（透明度 alpha）。この際、テクスチャの origin を中心として、ラジアン単位で rotation だけ回転させ、縦横ともに scale 倍して描画を行います。
     */
    void    draw(const KRVector2D& centerPos, const KRRect2D& srcRect, float rotation, const KRVector2D& origin, float scale=1.0f, float alpha=1.0f);

    /*!
        @method draw
        指定された座標を中心点として、指定された領域を描画します（透明度 alpha）。この際、テクスチャの origin を中心として、ラジアン単位で rotation だけ回転させ、縦横に scale 倍して描画を行います。
     */
    void    draw(const KRVector2D& centerPos, const KRRect2D& srcRect, float rotation, const KRVector2D &origin, const KRVector2D &scale, float alpha = 1.0f);

    
    /*!
        @task 描画のための関数（色付き）
     */
    
    /*!
        @method draw
        指定された座標に指定された色でこのテクスチャを描画します。
     */
    void    draw(float x, float y, const KRColor& color);
    
    /*!
        @method draw
        指定された座標に指定された色でこのテクスチャを描画します。
     */
    void    draw(const KRVector2D& pos, const KRColor& color);
    
    /*!
        @method draw
        指定された矩形内に指定された色でこのテクスチャを描画します。
     */
    void    draw(const KRRect2D& rect, const KRColor& color);
    
    /*!
        @method draw
        指定された領域を、指定された色で指定された座標に描画します。
     */
    void    draw(const KRVector2D& pos, const KRRect2D& srcRect, const KRColor& color);

    /*!
        @method draw
     */
    void    draw(const KRRect2D& destRect, const KRRect2D& srcRect, const KRColor& color);

    /*!
        @method draw
        指定された座標を中心点として、指定された色で指定された領域を描画します。この際、テクスチャの origin を中心として、ラジアン単位で rotation だけ回転させ、縦横ともに scale 倍して描画を行います。
     */
    void    draw(const KRVector2D& centerPos, const KRRect2D& srcRect, float rotation, const KRVector2D& origin, float scale, const KRColor& color);

    /*!
        @method draw
        指定された座標を中心点として、指定された色で指定された領域を描画します。この際、テクスチャの origin を中心として、ラジアン単位で rotation だけ回転させ、縦横に scale 倍して描画を行います。
     */
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

