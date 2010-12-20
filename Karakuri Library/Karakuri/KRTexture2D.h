/*
 *  KRTexture2D.h
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/18.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include <Karakuri/KRTexture2D_old.h>


class _KRFont;


struct _KRTexture2DDrawData {
    GLshort vertex_x, vertex_y;
    GLfloat texCoords_x, texCoords_y;
    GLubyte colors[4];
};


/*
    @-class _KRTexture2D
    @group Game Graphics
    <p>2次元のテクスチャを表すためのクラスです。</p>
    <p>テクスチャのサイズは、横幅・高さともに1024ピクセル以内である必要があります。このサイズを超えている画像が指定された場合には、実行時例外が発生してゲームが強制終了します。</p>
    <p><a href="../../../../guide/index.html">開発ガイド</a>の「<a href="../../../../guide/texture.html">テクスチャについて</a>」も参照してください。</p>
 */
class _KRTexture2D : public KRObject {
    
private:
    std::string mFileName;
    GLuint      mTextureName;
    GLenum      mTextureTarget;
    KRVector2D  mImageSize;         //!< The actual size of the image.
    KRVector2D  mTextureSize;       //!< Full size of the area used as a texture. （サイズが2の乗数になっていない場合のサイズ割合）
    
public:
    static int  getResourceSize(const std::string& filename);

public:
    /*!
        @task コンストラクタ
     */
    
    /*!
        @method _KRTexture2D
        @abstract 画像ファイルの名前（拡張子を含む）を指定してテクスチャを生成します。
        画像の補完方法として、KRTexture2DScaleModeNearest, KRTexture2DScaleModeLinear のいずれかを指定します。
     */
    _KRTexture2D(const std::string& filename, KRTexture2DScaleMode scaleMode=KRTexture2DScaleModeLinear);
    
    /*!
        @method _KRTexture2D
        @abstract リソースファイルの名前（拡張子 .krrs を含む）、画像データの開始位置、サイズを指定してテクスチャを生成します。
        画像の補完方法として、KRTexture2DScaleModeNearest, KRTexture2DScaleModeLinear のいずれかを指定します。
     */
    _KRTexture2D(const std::string& resourceFileName, unsigned startPos, unsigned length, KRTexture2DScaleMode scaleMode);    

    _KRTexture2D(const std::string& str, _KRFont* font);
    ~_KRTexture2D();
    
public:
    /*!
        @task 状態取得のための関数
     */

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
    /*!
        @-task 描画のための関数（1.0.0 で導入した新バージョン）
     */
    void    drawAtPoint(const KRVector2D& pos, const KRColor& color);
    void    drawAtPointEx(const KRVector2D& pos, const KRRect2D& srcRect, double rotate, const KRVector2D& origin, const KRVector2D& scale, const KRColor& color);
    
    void    drawAtPointCenter(const KRVector2D& centerPos, const KRColor& color);
    void    drawAtPointCenterEx(const KRVector2D& centerPos, const KRRect2D& srcRect, double rotate, const KRVector2D& scale, const KRColor& color);

    void    drawInRect(const KRRect2D& destRect, const KRColor& color);
    void    drawInRect(const KRRect2D& destRect, const KRRect2D& srcRect, const KRColor& color);
    
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

