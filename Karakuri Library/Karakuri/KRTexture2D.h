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
#include <Karakuri/KarakuriTypes.h>


class KRFont;


typedef enum {
    KRTexture2DScaleModeNearest,
    KRTexture2DScaleModeLinear,
} KRTexture2DScaleMode;


/*!
    @-class KRTexture2D
    @group Game 2D Graphics
    <p>2次元のテクスチャを表すためのクラスです。</p>
    <p>テクスチャのサイズは、横幅・高さともに1024ピクセル以内である必要があります。このサイズを超えている画像が指定された場合には、実行時例外が発生してゲームが強制終了します。</p>
    <p><a href="../../../../guide/index.html">開発ガイド</a>の「<a href="../../../../guide/texture.html">テクスチャについて</a>」も参照してください。</p>
 */
class KRTexture2D : public KRObject {
    
private:
    std::string mFileName;
    GLuint      mTextureName;
    GLenum      mTextureTarget;
    KRVector2D  mImageSize;         //!< The actual size of the image.
    KRVector2D  mTextureSize;       //!< Full size of the area used as a texture.
    
    KRVector2D  mOrigin;
    
    void        *mTexture2DImpl;
    void        *mAtlas;
    KRVector2D  mAtlasSize;

public:
    static int  getResourceSize(const std::string& filename);

public:
    /*!
        @task コンストラクタ
     */
    
    KRTexture2D(const std::string& filename, KRTexture2DScaleMode scaleMode);

    /*!
        @method KRTexture2D
        @abstract 画像ファイルの名前（拡張子を含む）を指定してテクスチャを生成します。
        第2引数でアトラスのサイズを設定することで、簡単に部分描画を行なうことができます。
     */
    KRTexture2D(const std::string& filename, const KRVector2D& atlasSize=KRVector2DZero);

    KRTexture2D(const std::string& str, KRFont *font);
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
    void    drawAtPoint_(const KRVector2D& pos, const KRColor& color);
    void    drawAtPointEx_(const KRVector2D& pos, const KRRect2D& srcRect, double rotate, const KRVector2D& origin, const KRVector2D& scale, const KRColor& color);
    
    void    drawAtPointCenter_(const KRVector2D& centerPos, const KRColor& color);
    void    drawAtPointCenterEx_(const KRVector2D& centerPos, const KRRect2D& srcRect, double rotate, const KRVector2D& origin, const KRVector2D& scale, const KRColor& color);

    void    drawInRect_(const KRRect2D& destRect, const KRColor& color);
    void    drawInRect_(const KRRect2D& destRect, const KRRect2D& srcRect, const KRColor& color);

    
    /*!
        @task 描画のための関数（1.0.0 より前のバージョン用の互換性維持）
     */

    /*!
        @method draw
        指定された座標を中心点として、指定された領域を描画します（透明度 alpha）。この際、テクスチャの origin を中心として、ラジアン単位で rotation だけ回転させ、縦横に scale 倍して描画を行います。
     */
    void    draw(const KRVector2D& centerPos, const KRRect2D& srcRect, double rotation, const KRVector2D &origin, const KRVector2D &scale=KRVector2DOne, double alpha=1.0);
    
    /*!
        @method drawAtPoint
        @param x    X座標
        @param y    Y座標
        @param alpha    アルファ値
        指定された座標にこのテクスチャを描画します。透明度も指定できます。
     */
    void    drawAtPoint(double x, double y, double alpha=1.0);
    
    /*!
        @method drawAtPoint
        @param pos  座標
        @param alpha    アルファ値
        指定された座標にこのテクスチャを描画します。透明度も指定できます。
     */
    void    drawAtPoint(const KRVector2D& pos, double alpha=1.0);

    /*!
        @method drawAtPoint
        @param centerPos  座標
        @param alpha    アルファ値
        指定された座標を中心点としてこのテクスチャを描画します。透明度も指定できます。
     */    
    void    drawAtPointCenter(const KRVector2D& centerPos, double alpha=1.0);

    /*!
        @method drawAtPoint
        @param pos  描画先の座標
        @param src  描画元の矩形。KRRect2DZero を指定した場合には、テクスチャ全体が描画対象となります。
        @param alpha    アルファ値
        指定された領域を、指定された座標に描画します（透明度 alpha）。
     */
    void    drawAtPoint(const KRVector2D& pos, const KRRect2D& srcRect, double alpha=1.0);
    
    /*!
        @method drawInRect
        @param rect  描画先の矩形
        @param alpha    アルファ値
        指定された矩形内にこのテクスチャを描画します（透明度 alpha）。
     */
    void    drawInRect(const KRRect2D& rect, double alpha=1.0);

    
    /*!
        @method drawInRect
     */
    void    drawInRect(const KRRect2D& destRect, const KRRect2D& srcRect, double alpha=1.0);
    
    
    /*!
        @task 描画のための関数（色付き）
     */

    /*!
        @method drawC
        指定された座標を中心点として、指定された領域を描画します。この際、テクスチャの origin を中心として、ラジアン単位で rotation だけ回転させ、縦横に scale 倍して描画を行います。色の指定ができます。
     */
    void    drawC(const KRVector2D& centerPos, const KRRect2D& srcRect, double rotation, const KRVector2D &origin, const KRVector2D &scale=KRVector2DOne, const KRColor& color=KRColor::White);
    
    /*!
        @method drawAtPointC
        @param x    X座標
        @param y    Y座標
        @param alpha    アルファ値
        指定された座標にこのテクスチャを描画します。色の指定ができます。
     */
    void    drawAtPointC(double x, double y, const KRColor& color=KRColor::White);
    
    /*!
        @method drawAtPointC
        @param pos  座標
        @param alpha    アルファ値
        指定された座標にこのテクスチャを描画します。色の指定ができます。
     */
    void    drawAtPointC(const KRVector2D& pos, const KRColor& color=KRColor::White);

    /*!
        @method drawAtPointCenterC
        @param pos  座標
        @param alpha    アルファ値
        指定された座標を中心点としてこのテクスチャを描画します。色の指定ができます。
     */
    void    drawAtPointCenterC(const KRVector2D& centerPos, const KRColor& color=KRColor::White);

    /*!
        @method drawAtPoint
        @param pos  描画先の座標
        @param src  描画元の矩形。KRRect2DZero を指定した場合には、テクスチャ全体が描画対象となります。
        @param alpha    アルファ値
        指定された領域を、指定された座標に描画します。色の指定ができます。
     */
    void    drawAtPointC(const KRVector2D& pos, const KRRect2D& srcRect, const KRColor& color=KRColor::White);
    
    /*!
        @method drawInRectC
        @param rect  描画先の矩形
        @param alpha    アルファ値
        指定された矩形内にこのテクスチャを描画します。色の指定ができます。
     */
    void    drawInRectC(const KRRect2D& rect, const KRColor& color=KRColor::White);

    
    /*!
        @method drawInRectC
        指定された矩形内にこのテクスチャを描画します。色の指定ができます。
     */
    void    drawInRectC(const KRRect2D& destRect, const KRRect2D& srcRect, const KRColor& color=KRColor::White);

public:
    /*!
        @task アトラス描画のための関数
     */

    /*!
        @method drawAtlas
        部品の列 (row) を指定して、column 番目の部品を座標 centerPos を中心点として描画します（透明度 alpha）。この際、部品の origin を中心として、ラジアン単位で rotation だけ回転させ、縦横に scale 倍して描画を行います。
     */
    void    drawAtlas(int row, int column, const KRVector2D& centerPos, double rotation, const KRVector2D &origin, const KRVector2D &scale=KRVector2DOne, double alpha=1.0);

    /*!
        @method drawAtlasAtPoint
        部品の列 (row) を指定して、column 番目の部品を座標 pos に描画します（透明度 alpha）。
     */
    void    drawAtlasAtPoint(int row, int column, const KRVector2D& pos, double alpha=1.0);
    
    /*!
        @method drawAtlasAtPointCenter
        部品の列 (row) を指定して、column 番目の部品を座標 centerPos を中心点として描画します（透明度 alpha）。
     */
    void    drawAtlasAtPointCenter(int row, int column, const KRVector2D& pos, double alpha=1.0);
    
    /*!
        @method drawAtlasInRect
        部品の列 (row) を指定して、column 番目の部品を矩形 rect の中に描画します（透明度 alpha）。
     */
    void    drawAtlasInRect(int row, int column, const KRRect2D& rect, double alpha=1.0);
    

public:
    /*!
        @task アトラス描画のための関数（色付き）
     */
    
    /*!
        @method drawAtlasC
        部品の列 (row) を指定して、column 番目の部品を座標 centerPos を中心点として描画します。この際、部品の origin を中心として、ラジアン単位で rotation だけ回転させ、縦横に scale 倍して描画を行います。色の指定ができます。
     */
    void    drawAtlasC(int row, int column, const KRVector2D& centerPos, double rotation, const KRVector2D &origin, const KRVector2D &scale=KRVector2DOne, const KRColor& color=KRColor::White);

    /*!
        @method drawAtlasAtPointC
        部品の列 (row) を指定して、column 番目の部品を座標 pos に描画します。色の指定ができます。
     */
    void    drawAtlasAtPointC(int row, int column, const KRVector2D& centerPos, const KRColor& color=KRColor::White);

    /*!
        @method drawAtlasAtPointCenterC
        部品の列 (row) を指定して、column 番目の部品を座標 centerPos を中心点として描画します。色の指定ができます。
     */
    void    drawAtlasAtPointCenterC(int row, int column, const KRVector2D& centerPos, const KRColor& color=KRColor::White);

    /*!
        @method drawAtlasInRectC
        部品の列 (row) を指定して、column 番目の部品を矩形 rect の中に描画します。色の指定ができます。
     */
    void    drawAtlasInRectC(int row, int column, const KRRect2D& rect, const KRColor& color=KRColor::White);

    
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

