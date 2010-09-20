/*
 *  KRTexture2D_old.h
 *  Karakuri Library
 *
 *  Created by numata on 10/09/20.
 *  Copyright 2010 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include <Karakuri/KRColor.h>
#include <Karakuri/KarakuriTypes.h>
#include <AvailabilityMacros.h>


class KRFont;


/*!
    @enum   KRTexture2DScaleMode
    @group  Game Graphics
    @constant   KRTexture2DScaleModeNearest     ニアレストネイバー法による画像補完を表す定数です。
    @constant   KRTexture2DScaleModeLinear      バイリニア法による画像補完を表す定数です。
    @abstract   画像補間法を表すための型です。
 */
typedef enum {
    KRTexture2DScaleModeNearest,
    KRTexture2DScaleModeLinear,
} KRTexture2DScaleMode;


/*
    @class KRTexture2D
    @group Game Graphics
    @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
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
    
    void*       mTexture2DImpl;
    void*       mAtlas;
    KRVector2D  mAtlasSize;
    
    KRVector2DInt   mAtlasDiv;
    bool        mIsAtlasFlipped;

public:
    static int  getResourceSize(const std::string& filename);

public:
    /*!
        @task コンストラクタ
     */
    
    /*!
        @method KRTexture2D
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        <p>画像ファイルの名前（拡張子を含む）を指定してテクスチャを生成します。</p>
        <p>画像の補完方法として、KRTexture2DScaleModeNearest, KRTexture2DScaleModeLinear のいずれかを指定します。</p>
     */
    KRTexture2D(const std::string& filename, KRTexture2DScaleMode scaleMode) DEPRECATED_ATTRIBUTE;

    /*!
        @method KRTexture2D
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        <p>画像ファイルの名前（拡張子を含む）を指定してテクスチャを生成します。</p>
        <p>第2引数でアトラスのサイズを設定することで、簡単に部分描画を行なうことができます。</p>
     */
    KRTexture2D(const std::string& filename, const KRVector2D& atlasSize=KRVector2DZero) DEPRECATED_ATTRIBUTE;

    KRTexture2D(const std::string& str, KRFont* font) DEPRECATED_ATTRIBUTE;
    ~KRTexture2D() DEPRECATED_ATTRIBUTE;
    
public:
    /*!
        @task 状態取得のための関数
     */

    /*!
        @method getAtlasSize
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        アトラス機能を使用する際の各部品のサイズを取得します。
     */
    KRVector2D  getAtlasSize() const DEPRECATED_ATTRIBUTE;

    /*!
        @method getCenterPos
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        テクスチャの中心点をリターンします（ピクセル単位）。
     */
    KRVector2D  getCenterPos() const DEPRECATED_ATTRIBUTE;    
    
    /*!
        @method getHeight
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        テクスチャの高さをリターンします（ピクセル単位）。
     */
    double      getHeight() const DEPRECATED_ATTRIBUTE;
    
    /*!
        @method getSize
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        テクスチャのサイズをリターンします（ピクセル単位）。
     */
    KRVector2D  getSize() const DEPRECATED_ATTRIBUTE;
    
    /*!
        @method getWidth
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        テクスチャの横幅をリターンします（ピクセル単位）。
     */
    double      getWidth() const DEPRECATED_ATTRIBUTE;
    
    int         getDivX() DEPRECATED_ATTRIBUTE;
    int         getDivY() DEPRECATED_ATTRIBUTE;
    bool        isAtlasFlipped() DEPRECATED_ATTRIBUTE;
    
    
public:
    void    setTextureAtlasSize(const KRVector2D& size) DEPRECATED_ATTRIBUTE;
    void    setTextureOrigin(const KRVector2D& origin) DEPRECATED_ATTRIBUTE;    
    
public:
    /*!
        @task 描画のための関数
     */
    
    /*!
        @method draw
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        指定された座標を中心点として、指定された領域を描画します（透明度 alpha）。この際、テクスチャの origin を中心として、ラジアン単位で rotation だけ回転させ、縦横に scale 倍して描画を行います。
     */
    void    draw(const KRVector2D& centerPos, const KRRect2D& srcRect, double rotation, const KRVector2D &origin, const KRVector2D &scale=KRVector2DOne, double alpha=1.0) DEPRECATED_ATTRIBUTE;
    
    /*!
        @method drawAtPoint
        @param x    X座標
        @param y    Y座標
        @param alpha    アルファ値
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        指定された座標にこのテクスチャを描画します。透明度も指定できます。
     */
    void    drawAtPoint(double x, double y, double alpha=1.0) DEPRECATED_ATTRIBUTE;
    
    /*!
        @method drawAtPoint
        @param pos  座標
        @param alpha    アルファ値
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        指定された座標にこのテクスチャを描画します。透明度も指定できます。
     */
    void    drawAtPoint(const KRVector2D& pos, double alpha=1.0) DEPRECATED_ATTRIBUTE;
    
    /*!
        @method drawAtPoint
        @param centerPos  座標
        @param alpha    アルファ値
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        指定された座標を中心点としてこのテクスチャを描画します。透明度も指定できます。
     */    
    void    drawAtPointCenter(const KRVector2D& centerPos, double alpha=1.0) DEPRECATED_ATTRIBUTE;
    
    /*!
        @method drawAtPoint
        @param pos  描画先の座標
        @param src  描画元の矩形。KRRect2DZero を指定した場合には、テクスチャ全体が描画対象となります。
        @param alpha    アルファ値
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        指定された領域を、指定された座標に描画します（透明度 alpha）。
     */
    void    drawAtPoint(const KRVector2D& pos, const KRRect2D& srcRect, double alpha=1.0) DEPRECATED_ATTRIBUTE;
    
    /*!
        @method drawInRect
        @param rect  描画先の矩形
        @param alpha    アルファ値
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        指定された矩形内にこのテクスチャを描画します（透明度 alpha）。
     */
    void    drawInRect(const KRRect2D& rect, double alpha=1.0) DEPRECATED_ATTRIBUTE;
    
    
    /*!
        @method drawInRect
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        指定された矩形内にこのテクスチャの一部を描画します（透明度 alpha）。
     */
    void    drawInRect(const KRRect2D& destRect, const KRRect2D& srcRect, double alpha=1.0) DEPRECATED_ATTRIBUTE;
    
    
    /*!
        @task 描画のための関数（色付き）
     */
    
    /*!
        @method drawC
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        指定された座標を中心点として、指定された領域を描画します。この際、テクスチャの origin を中心として、ラジアン単位で rotation だけ回転させ、縦横に scale 倍して描画を行います。色の指定ができます。
     */
    void    drawC(const KRVector2D& centerPos, const KRRect2D& srcRect, double rotation, const KRVector2D &origin, const KRVector2D &scale=KRVector2DOne, const KRColor& color=KRColor::White) DEPRECATED_ATTRIBUTE;
    
    /*!
        @method drawAtPointC
        @param x    X座標
        @param y    Y座標
        @param alpha    アルファ値
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        指定された座標にこのテクスチャを描画します。色の指定ができます。
     */
    void    drawAtPointC(double x, double y, const KRColor& color=KRColor::White) DEPRECATED_ATTRIBUTE;
    
    /*!
        @method drawAtPointC
        @param pos  座標
        @param alpha    アルファ値
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        指定された座標にこのテクスチャを描画します。色の指定ができます。
     */
    void    drawAtPointC(const KRVector2D& pos, const KRColor& color=KRColor::White) DEPRECATED_ATTRIBUTE;
    
    /*!
        @method drawAtPointCenterC
        @param pos  座標
        @param alpha    アルファ値
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        指定された座標を中心点としてこのテクスチャを描画します。色の指定ができます。
     */
    void    drawAtPointCenterC(const KRVector2D& centerPos, const KRColor& color=KRColor::White) DEPRECATED_ATTRIBUTE;
    
    /*!
        @method drawAtPoint
        @param pos  描画先の座標
        @param src  描画元の矩形。KRRect2DZero を指定した場合には、テクスチャ全体が描画対象となります。
        @param alpha    アルファ値
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        指定された領域を、指定された座標に描画します。色の指定ができます。
     */
    void    drawAtPointC(const KRVector2D& pos, const KRRect2D& srcRect, const KRColor& color=KRColor::White) DEPRECATED_ATTRIBUTE;
    
    /*!
        @method drawInRectC
        @param rect  描画先の矩形
        @param alpha    アルファ値
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        指定された矩形内にこのテクスチャを描画します。色の指定ができます。
     */
    void    drawInRectC(const KRRect2D& rect, const KRColor& color=KRColor::White) DEPRECATED_ATTRIBUTE;
    
    
    /*!
        @method drawInRectC
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        指定された矩形内にこのテクスチャを描画します。色の指定ができます。
     */
    void    drawInRectC(const KRRect2D& destRect, const KRRect2D& srcRect, const KRColor& color=KRColor::White) DEPRECATED_ATTRIBUTE;
    
public:
    /*!
        @task アトラス描画のための関数
     */
    
    /*!
        @method drawAtlas
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        部品の列 (row) を指定して、column 番目の部品を座標 centerPos を中心点として描画します（透明度 alpha）。この際、部品の origin を中心として、ラジアン単位で rotation だけ回転させ、縦横に scale 倍して描画を行います。
     */
    void    drawAtlas(int row, int column, const KRVector2D& centerPos, double rotation, const KRVector2D &origin, const KRVector2D &scale=KRVector2DOne, double alpha=1.0) DEPRECATED_ATTRIBUTE;
    
    /*!
        @method drawAtlasAtPoint
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        部品の列 (row) を指定して、column 番目の部品を座標 pos に描画します（透明度 alpha）。
     */
    void    drawAtlasAtPoint(int row, int column, const KRVector2D& pos, double alpha=1.0) DEPRECATED_ATTRIBUTE;
    
    /*!
        @method drawAtlasAtPointCenter
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        部品の列 (row) を指定して、column 番目の部品を座標 centerPos を中心点として描画します（透明度 alpha）。
     */
    void    drawAtlasAtPointCenter(int row, int column, const KRVector2D& pos, double alpha=1.0) DEPRECATED_ATTRIBUTE;
    
    /*!
        @method drawAtlasInRect
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        部品の列 (row) を指定して、column 番目の部品を矩形 rect の中に描画します（透明度 alpha）。
     */
    void    drawAtlasInRect(int row, int column, const KRRect2D& rect, double alpha=1.0) DEPRECATED_ATTRIBUTE;
    
    
public:
    /*!
        @task アトラス描画のための関数（色付き）
     */
    
    /*!
        @method drawAtlasC
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        部品の列 (row) を指定して、column 番目の部品を座標 centerPos を中心点として描画します。この際、部品の origin を中心として、ラジアン単位で rotation だけ回転させ、縦横に scale 倍して描画を行います。色の指定ができます。
     */
    void    drawAtlasC(int row, int column, const KRVector2D& centerPos, double rotation, const KRVector2D &origin, const KRVector2D &scale=KRVector2DOne, const KRColor& color=KRColor::White) DEPRECATED_ATTRIBUTE;
    
    /*!
        @method drawAtlasAtPointC
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        部品の列 (row) を指定して、column 番目の部品を座標 pos に描画します。色の指定ができます。
     */
    void    drawAtlasAtPointC(int row, int column, const KRVector2D& centerPos, const KRColor& color=KRColor::White) DEPRECATED_ATTRIBUTE;
    
    /*!
        @method drawAtlasAtPointCenterC
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        部品の列 (row) を指定して、column 番目の部品を座標 centerPos を中心点として描画します。色の指定ができます。
     */
    void    drawAtlasAtPointCenterC(int row, int column, const KRVector2D& centerPos, const KRColor& color=KRColor::White) DEPRECATED_ATTRIBUTE;
    
    /*!
        @method drawAtlasInRectC
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        部品の列 (row) を指定して、column 番目の部品を矩形 rect の中に描画します。色の指定ができます。
     */
    void    drawAtlasInRectC(int row, int column, const KRRect2D& rect, const KRColor& color=KRColor::White) DEPRECATED_ATTRIBUTE;
    
    
public:
    GLuint  getTextureName() const KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY DEPRECATED_ATTRIBUTE;
    void    set() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY DEPRECATED_ATTRIBUTE;

#pragma mark -
#pragma mark Debug Support

public:
    std::string to_s() const DEPRECATED_ATTRIBUTE;
    
};

