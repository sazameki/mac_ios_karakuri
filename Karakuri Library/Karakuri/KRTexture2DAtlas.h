/*
    @file   KRTexture2DAtlas.h
    @author numata
    @date   09/07/29
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/Karakuri.h>
#include <AvailabilityMacros.h>


/*!
    @class KRTexture2DAtlas
    @group Game Graphics
    @deprecated
    @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
    <p>テクスチャの一部分を切り取って描画するためのクラスです。</p>
    <p><a href="../../../../guide/index.html">開発ガイド</a>の「<a href="../../../../guide/texture.html">テクスチャについて</a>」も参照してください。</p>
 */
class KRTexture2DAtlas : public KRObject {
    
    KRTexture2D*    mTexture;
    KRVector2D      mLeftBottomPos;
    KRVector2D      mOneSize;
    KRVector2D      mCenterPos;

public:
    /*!
        @task コンストラクタ
     */
    
    /*!
        @method KRTexture2DAtlas
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        2次元テクスチャ、部品の開始点（左下）、各部品のサイズ（ピクセル単位）を指定して、このクラスのインスタンスを生成します。
     */
	KRTexture2DAtlas(KRTexture2D* tex, const KRVector2D& leftBottomPos, const KRVector2D& oneSize) DEPRECATED_ATTRIBUTE;
	virtual ~KRTexture2DAtlas() DEPRECATED_ATTRIBUTE;
    
public:
    /*!
        @task 状態取得のための関数
     */
    
    /*!
        @method getCenterPos
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        ひとつの部品を描画する際の中心点（原点を (0, 0) として）の座標をリターンします。
     */
    KRVector2D  getCenterPos() const DEPRECATED_ATTRIBUTE;

    /*!
        @method getLeftBottomPos
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        このマップで描画する部品の、テクスチャ内の開始点（左下）を取得します（ピクセル単位）。
     */
    KRVector2D  getLeftBottomPos() const DEPRECATED_ATTRIBUTE;

    /*!
        @method getOneSize
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        このマップで描画する部品のサイズを取得します（ピクセル単位）。
     */
    KRVector2D  getOneSize() const DEPRECATED_ATTRIBUTE;
    
public:
    /*!
        =======================================================
        @task 描画に関する関数
        =======================================================
     */

    /*!
        @method drawAtPoint
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        部品の列 (row) を指定して、column 番目の部品を座標 pos に描画します（透明度 alpha）。
     */
    void    drawAtPoint(int row, int column, const KRVector2D& pos, double alpha = 1.0) DEPRECATED_ATTRIBUTE;

    /*!
        @method drawInRect
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        部品の列 (row) を指定して、column 番目の部品を矩形 rect の中に描画します（透明度 alpha）。
     */
    void    drawInRect(int row, int column, const KRRect2D& rect, double alpha = 1.0) DEPRECATED_ATTRIBUTE;

    /*!
        @method draw
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        部品の列 (row) を指定して、column 番目の部品を座標 centerPos を中心点として描画します（透明度 alpha）。この際、部品の origin を中心として、ラジアン単位で rotation だけ回転させ、縦横に scale 倍して描画を行います。
     */
    void    draw(int row, int column, const KRVector2D& centerPos, double rotation, const KRVector2D& origin, const KRVector2D &scale, double alpha = 1.0) DEPRECATED_ATTRIBUTE;

public:
    /*!
        =======================================================
        @task 描画に関する関数（色付き）
        =======================================================
     */

    /*!
        @method drawAtPointC
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        部品の列 (row) を指定して、column 番目の部品を座標 pos に、指定された色で描画します。
     */
    void    drawAtPointC(int row, int column, const KRVector2D& pos, const KRColor& color) DEPRECATED_ATTRIBUTE;

    /*!
        @method drawInRectC
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        部品の列 (row) を指定して、column 番目の部品を矩形 rect の中に、指定された色で描画します。
     */
    void    drawInRectC(int row, int column, const KRRect2D& rect, const KRColor& color) DEPRECATED_ATTRIBUTE;

    /*!
        @method drawC
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRTexture2DManager を使用してください。</strong>
        部品の列 (row) を指定して、column 番目の部品を座標 centerPos を中心点として、指定された色で描画します。この際、部品の origin を中心として、ラジアン単位で rotation だけ回転させ、縦横に scale 倍して描画を行います。
     */
    void    drawC(int row, int column, const KRVector2D& centerPos, double rotation, const KRVector2D& origin, const KRVector2D &scale=KRVector2DOne, const KRColor& color=KRColor::White) DEPRECATED_ATTRIBUTE;
    
public:
    virtual std::string to_s() const DEPRECATED_ATTRIBUTE;

};

