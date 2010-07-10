/*
    @file   KRTexture2DAtlas.h
    @author numata
    @date   09/07/29
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/Karakuri.h>


/*
    @!class _KRTexture2DAtlas
    @!group Game 2D Graphics
    @!abstract テクスチャの一部分を切り取って描画するためのクラスです。
    <p><a href="../../../../guide/index.html">開発ガイド</a>の「<a href="../../../../guide/texture.html">テクスチャについて</a>」も参照してください。</p>
 */
class _KRTexture2DAtlas : public KRObject {
    
    _KRTexture2D*   mTexture;
    KRVector2D      mLeftBottomPos;
    KRVector2D      mOneSize;
    KRVector2D      mCenterPos;

public:
    /*
        @task コンストラクタ
     */
    
    /*
        @method _KRTexture2DAtlas
        @abstract コンストラクタ
        2次元テクスチャ、部品の開始点（左下）、各部品のサイズ（ピクセル単位）を指定して、このクラスのインスタンスを生成します。
     */
	_KRTexture2DAtlas(_KRTexture2D *tex, const KRVector2D& leftBottomPos, const KRVector2D& oneSize);
	virtual ~_KRTexture2DAtlas();
    
public:
    /*
        @task 状態取得のための関数
     */
    
    /*
        @method getCenterPos
        ひとつの部品を描画する際の中心点（原点を (0, 0) として）の座標をリターンします。
     */
    KRVector2D  getCenterPos() const;

    /*
        @method getLeftBottomPos
        このマップで描画する部品の、テクスチャ内の開始点（左下）を取得します（ピクセル単位）。
     */
    KRVector2D  getLeftBottomPos() const;

    /*
        @method getOneSize
        このマップで描画する部品のサイズを取得します（ピクセル単位）。
     */
    KRVector2D  getOneSize() const;
    
public:
    /*
        =======================================================
        @task 描画に関する関数
        =======================================================
     */

    /*
        @method drawAtPoint
        部品の列 (row) を指定して、column 番目の部品を座標 pos に描画します（透明度 alpha）。
     */
    void    drawAtPoint(int row, int column, const KRVector2D& pos, double alpha = 1.0);

    /*
        @method drawInRect
        部品の列 (row) を指定して、column 番目の部品を矩形 rect の中に描画します（透明度 alpha）。
     */
    void    drawInRect(int row, int column, const KRRect2D& rect, double alpha = 1.0);

    /*
        @method draw
        部品の列 (row) を指定して、column 番目の部品を座標 centerPos を中心点として描画します（透明度 alpha）。この際、部品の origin を中心として、ラジアン単位で rotation だけ回転させ、縦横に scale 倍して描画を行います。
     */
    void    draw(int row, int column, const KRVector2D& centerPos, double rotation, const KRVector2D& origin, const KRVector2D &scale, double alpha = 1.0);

public:
    /*
        =======================================================
        @task 描画に関する関数（色付き）
        =======================================================
     */

    /*
        @method drawAtPointC
        部品の列 (row) を指定して、column 番目の部品を座標 pos に、指定された色で描画します。
     */
    void    drawAtPointC(int row, int column, const KRVector2D& pos, const KRColor& color);

    /*
        @method drawInRectC
        部品の列 (row) を指定して、column 番目の部品を矩形 rect の中に、指定された色で描画します。
     */
    void    drawInRectC(int row, int column, const KRRect2D& rect, const KRColor& color);

    /*
        @method drawC
        部品の列 (row) を指定して、column 番目の部品を座標 centerPos を中心点として、指定された色で描画します。この際、部品の origin を中心として、ラジアン単位で rotation だけ回転させ、縦横に scale 倍して描画を行います。
     */
    void    drawC(int row, int column, const KRVector2D& centerPos, double rotation, const KRVector2D& origin, const KRVector2D &scale=KRVector2DOne, const KRColor& color=KRColor::White);
    
public:
    virtual std::string to_s() const;

};

