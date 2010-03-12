/*
 *  KRTexture2D.h
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


typedef enum {
    KRTexture2DScaleModeNearest,
    KRTexture2DScaleModeLinear,
} KRTexture2DScaleMode;


@class BXChara2DImage;


/*!
    @-class KRTexture2D
    @group Game 2D Graphics
    <p>2次元のテクスチャを表すためのクラスです。</p>
    <p>テクスチャのサイズは、横幅・高さともに1024ピクセル以内である必要があります。このサイズを超えている画像が指定された場合には、実行時例外が発生してゲームが強制終了します。</p>
    <p><a href="../../../../guide/index.html">開発ガイド</a>の「<a href="../../../../guide/texture.html">テクスチャについて</a>」も参照してください。</p>
 */
class KRTexture2D {
    
private:
    std::string mFileName;
    GLuint      mTextureName;
    GLenum      mTextureTarget;
    KRVector2D  mImageSize;         //!< The actual size of the image.
    KRVector2D  mTextureSize;       //!< Full size of the area used as a texture.
    
    KRVector2D  mOrigin;
    
    KRVector2D  mAtlasSize;

public:
    static int  getResourceSize(const std::string& filename);

public:
    /*!
        @task コンストラクタ
     */
    
    KRTexture2D(const std::string& filename, KRTexture2DScaleMode scaleMode=KRTexture2DScaleModeLinear);
    KRTexture2D(int imageTag, KRTexture2DScaleMode scaleMode=KRTexture2DScaleModeLinear);
    KRTexture2D(BXChara2DImage* charaImage, int index);

    ~KRTexture2D();
    
public:
    /*!
        @task 状態取得のための関数
     */

    /*!
        @method getAtlasSize
        アトラス機能を使用する際の各部品のサイズを取得します。
     */
    KRVector2D  getAtlasSize() const;

    /*!
        @method getCenterPos
        テクスチャの中心点をリターンします（ピクセル単位）。
     */
    KRVector2D  getCenterPos() const;    
    
    /*!
        @method getHeight
        テクスチャの高さをリターンします（ピクセル単位）。
     */
    double      getHeight() const;
    
    /*!
        @method getSize
        テクスチャのサイズをリターンします（ピクセル単位）。
     */
    KRVector2D  getSize() const;
    
    /*!
        @method getWidth
        テクスチャの横幅をリターンします（ピクセル単位）。
     */
    double      getWidth() const;
    
    
public:
    void    setTextureAtlasSize(const KRVector2D& size);
    void    setTextureOrigin(const KRVector2D& origin);    
    
public:
    /*!
        @task 描画のための関数（1.0.0 で導入した新バージョン）
     */
    void    drawAtPoint(const KRVector2D& pos, const KRColor& color);
    void    drawAtPointEx(const KRVector2D& pos, const KRRect2D& srcRect, double rotate, const KRVector2D& origin, const KRVector2D& scale, const KRColor& color);
    
    void    drawAtPointCenter(const KRVector2D& centerPos, const KRColor& color);
    void    drawAtPointCenterEx(const KRVector2D& centerPos, const KRRect2D& srcRect, double rotate, const KRVector2D& origin, const KRVector2D& scale, const KRColor& color);

    void    drawInRect(const KRRect2D& destRect, const KRColor& color);
    void    drawInRect(const KRRect2D& destRect, const KRRect2D& srcRect, const KRColor& color);
    
public:
    GLuint  getTextureName() const;
    void    set();

public:
    static void initBatchedTexture2DDraws();
    static void processBatchedTexture2DDraws();

};

