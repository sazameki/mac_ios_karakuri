/*
 *  KarakuriTypes.h
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/18.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include "KarakuriString.h"

#include <string>


struct KRVector2D;


/*!
    @class KRObject
    @group Game Foundation
    @abstract Karakuri Framework 内のすべてのクラスの基底クラスとなるクラスです。
 */
typedef struct KRObject {
    KRObject();
    
    /*!
        @task デバッグのサポート
     */
    
    /*!
        @method c_str
        このクラスの内容を表すC言語文字列をリターンします。
     */
    const char *c_str() const;

    /*!
        @method to_s
        このクラスの内容を表す C++ 文字列をリターンします。
     */
    virtual std::string to_s() const;
} KRObject;


/*!
    @struct KRRect2D
    @group  Game Foundation
    @abstract 位置およびサイズで定義される矩形を表すための構造体です。
 */
typedef struct KRRect2D : public KRObject {
    
    /*!
        @var x
        矩形の位置のX座標です。
     */
    double x;

    /*!
        @var y
        矩形の位置のY座標です。
     */
    double y;

    /*!
        @var width
        矩形の横幅です。
     */
    double width;

    /*!
        @var height
        矩形の高さです。
     */
    double height;
    
    /*!
        @task コンストラクタ
     */
    
    /*!
        @method KRRect2D
        位置が (0, 0) であり、幅と高さが両方とも 0 の矩形を作成します。
     */
    KRRect2D();

    /*!
        @method KRRect2D
        位置と幅と高さを指定してこの矩形を作成します。
     */
    KRRect2D(double _x, double _y, double _width, double _height);
    
    /*!
        @method KRRect2D
        位置とサイズを指定してこの矩形を作成します。
     */
    KRRect2D(const KRVector2D& _origin, const KRVector2D& _size);
    
    /*!
        @method KRRect2D
        与えられた矩形をコピーして、この矩形を作成します。
     */
    KRRect2D(const KRRect2D& _rect);

    
    /*!
        @task 重なり判定のための関数
     */
    
    /*!
        @method contains
        この矩形が与えられた座標を含むかどうかをリターンします。
     */
    bool    contains(double _x, double _y) const;

    /*!
        @method contains
        この矩形が与えられた座標を含むかどうかをリターンします。
     */
    bool    contains(const KRVector2D& pos) const;
    
    /*!
        @method contains
        この矩形が、与えられた位置座標とサイズを元にした矩形を完全に含むかどうかをリターンします。
     */
    bool    contains(double _x, double _y, double _width, double _height) const;

    /*!
        @method contains
        この矩形が与えられた矩形を完全に含むかどうかをリターンします。
     */
    bool    contains(const KRRect2D& rect) const;    
    
    /*!
        @method intersects
        与えられた位置座標とサイズを元にした矩形とこの矩形が重なっているかどうかをリターンします。
     */
    bool    intersects(double _x, double _y, double _width, double _height) const;
    
    /*!
        @method intersects
        与えられた矩形とこの矩形が重なっているかどうかをリターンします。
     */
    bool    intersects(const KRRect2D& rect) const;

    
    /*!
        @task ジオメトリ計算のための関数
     */
    
    /*!
        @method getCenterPos
        この矩形の中心位置の座標をリターンします。
     */
    KRVector2D getCenterPos() const;

    /*!
        @method getIntersection
        この矩形と与えられた矩形との共通部分を表す矩形をリターンします。
     */
    KRRect2D    getIntersection(const KRRect2D& rect) const;

    /*!
        @method getMaxX
        この矩形を構成する最大のX座標をリターンします。
     */
    double getMaxX() const;
    
    /*!
        @method getMaxY
        この矩形を構成する最大のY座標をリターンします。
     */
    double getMaxY() const;

    /*!
        @method getMinX
        この矩形を構成する最小のX座標をリターンします。
     */
    double getMinX() const;

    /*!
        @method getMinY
        この矩形を構成する最小のY座標をリターンします。
     */
    double getMinY() const;
    
    /*!
        @method getOrigin
        X座標・Y座標がともに最小となるこの矩形上の座標をリターンします。
     */
    KRVector2D getOrigin() const;

    /*!
        @method getSize
        この矩形のサイズをリターンします。
     */
    KRVector2D getSize() const;
    
    /*!
        @method getUnion
        この矩形と与えられた矩形との結合部分を表す矩形をリターンします。
     */
    KRRect2D    getUnion(const KRRect2D& rect) const;    
    
    /*!
        @task 演算子のオーバーライド
     */
    
    /*!
        @method operator==
     */
    bool    operator==(const KRRect2D& rect) const;

    /*!
        @method operator!=
     */
    bool    operator!=(const KRRect2D& rect) const;
    
    static KRRect2D makeIntersection(const KRRect2D& src1, const KRRect2D& src2);
    static KRRect2D makeUnion(const KRRect2D& src1, const KRRect2D& src2);
    
    virtual std::string to_s() const;
    
} KRRect2D;


/*!
    @struct KRVector2D
    @group  Game Foundation
    @abstract double 型の2次元ベクトルを表すための構造体です。
    点情報、サイズ情報を表すためにも使われます。
 */
typedef struct KRVector2D : public KRObject {
    
    /*!
        @var    x
        @abstract   このベクトルのX成分を表す数値です。
     */
    double   x;

    /*!
        @var    y
        @abstract   このベクトルのY成分を表す数値です。
     */
    double   y;

    /*!
        @task コンストラクタ
     */
    
    /*!
        @method KRVector2D
        このベクトルを、x=0.0, y=0.0 で初期化します。
     */
    KRVector2D();

    /*!
        @method KRVector2D
        @param _x   X成分
        @param _y   Y成分
        このベクトルを、与えられた2つの数値で初期化します。
     */
    KRVector2D(double _x, double _y);
    
    /*!
        @method KRVector2D
        与えられたベクトルをコピーして、このベクトルを初期化します。
     */
    KRVector2D(const KRVector2D& vec);
    
    /*!
        @task 幾何計算のための関数
     */
    
    /*!
        @method angle
        このベクトルと与えられたベクトルが成す角度をリターンします。
     */
    double   angle(const KRVector2D &vec) const;    
    
    /*!
        @method innerProduct
        与えられたベクトルを右辺値として、このベクトルとの内積を計算します。
     */
    double innerProduct(const KRVector2D& vec) const;

    /*!
        @method length
        このベクトルの長さをリターンします。
     */
    double   length() const;

    /*!
        @method lengthSq
        このベクトルの長さの2乗をリターンします。
     */
    double   lengthSq() const;
    
    /*!
        @method normalize
        このベクトルを、長さ1のベクトルに正規化します。
     */
    KRVector2D &normalize();
    
    /*!
        @method outerProduct
        与えられたベクトルを右辺値として、このベクトルとの外積を計算します。
     */
    double outerProduct(const KRVector2D& vec) const;
    
    
    /*!
        @task 演算子のオーバーライド
     */
    
    /*!
        @method operator+
     */
    KRVector2D operator+(const KRVector2D& vec) const;

    /*!
        @method operator+=
     */
    KRVector2D& operator+=(const KRVector2D& vec);

    /*!
        @method operator-
     */
    KRVector2D operator-(const KRVector2D& vec) const;

    /*!
        @method operator-=
     */
    KRVector2D& operator-=(const KRVector2D& vec);

    /*!
        @method operator/
     */
    KRVector2D operator/(double value) const;

    /*!
        @method operator/=
     */
    KRVector2D& operator/=(double value);

    /*!
        @method operator*
     */
    KRVector2D operator*(double value) const;

    /*!
        @method operator*=
     */
    KRVector2D& operator*=(double value);
    
    /*!
        @method operator==
     */
    bool operator==(const KRVector2D& vec) const;

    /*!
        @method operator!=
     */
    bool operator!=(const KRVector2D& vec) const;
    
    bool operator<(const KRVector2D& vec) const;
    
    /*!
        @method operator-
     */
    KRVector2D operator-() const;

    virtual std::string to_s() const;

} KRVector2D;


/*!
    @struct KRVector2DInt
    @group  Game Foundation
    @abstract int 型の2次元ベクトルを表すための構造体です。
    点情報、サイズ情報を表すためにも使われます。
 */
typedef struct KRVector2DInt : public KRObject {
    
    /*!
        @var    x
        @abstract   このベクトルのX成分を表す数値です。
     */
    int     x;

    /*!
        @var    y
        @abstract   このベクトルのY成分を表す数値です。
     */
    int     y;

    /*!
        @task コンストラクタ
     */
    
    /*!
        @method KRVector2DInt
        このベクトルを、x=0, y=0 で初期化します。
     */
    KRVector2DInt();

    /*!
        @method KRVector2DInt
        @param _x   X成分
        @param _y   Y成分
        このベクトルを、与えられた2つの数値で初期化します。
     */
    KRVector2DInt(int _x, int _y);
    
    /*!
        @method KRVector2DInt
        与えられたベクトルをコピーして、このベクトルを初期化します。
     */
    KRVector2DInt(const KRVector2DInt& vec);
    
    /*!
        @task 幾何計算のための関数
     */
    
    /*!
        @method angle
        このベクトルと与えられたベクトルが成す角度をリターンします。
     */
    double   angle(const KRVector2DInt &vec) const;    
    
    /*!
        @method innerProduct
        与えられたベクトルを右辺値として、このベクトルとの内積を計算します。
     */
    int innerProduct(const KRVector2DInt& vec) const;

    /*!
        @method length
        このベクトルの長さをリターンします。
     */
    double   length() const;

    /*!
        @method lengthSq
        このベクトルの長さの2乗をリターンします。
     */
    int     lengthSq() const;
    
    /*!
        @method normalize
        @abstract このベクトルを、長さ1のベクトルに正規化したベクトルを生成します。
        正規化したベクトルは、KRVector2D 型になります。
     */
    KRVector2D normalize() const;
    
    /*!
        @method outerProduct
        与えられたベクトルを右辺値として、このベクトルとの外積を計算します。
     */
    int outerProduct(const KRVector2DInt& vec) const;
    
    
    /*!
        @task 演算子のオーバーライド
     */
    
    /*!
        @method operator+
     */
    KRVector2DInt operator+(const KRVector2DInt& vec) const;

    /*!
        @method operator+=
     */
    KRVector2DInt& operator+=(const KRVector2DInt& vec);

    /*!
        @method operator-
     */
    KRVector2DInt operator-(const KRVector2DInt& vec) const;

    /*!
        @method operator-=
     */
    KRVector2DInt& operator-=(const KRVector2DInt& vec);

    /*!
        @method operator/
     */
    KRVector2DInt operator/(int value) const;

    /*!
        @method operator/=
     */
    KRVector2DInt& operator/=(int value);

    /*!
        @method operator*
     */
    KRVector2DInt operator*(int value) const;

    /*!
        @method operator*=
     */
    KRVector2DInt& operator*=(int value);
    
    /*!
        @method operator==
     */
    bool operator==(const KRVector2DInt& vec) const;

    /*!
        @method operator!=
     */
    bool operator!=(const KRVector2DInt& vec) const;
    
    bool operator<(const KRVector2DInt& vec) const;

    /*!
        @method operator-
     */
    KRVector2DInt operator-() const;

    virtual std::string to_s() const;

} KRVector2DInt;


/*!
    @struct KRVector3D
    @group  Game Foundation
    @abstract double 型の3次元ベクトルを表すための構造体です。
    点情報、サイズ情報を表すためにも使われます。
 */
typedef struct KRVector3D : public KRObject {
    
    /*!
        @var x
        このベクトルのX成分を表す数値です。
     */
    double   x;
    
    /*!
        @var y
        このベクトルのY成分を表す数値です。
     */    
    double   y;

    /*!
        @var z
        このベクトルのZ成分を表す数値です。
     */    
    double   z;
    
    /*!
        @task コンストラクタ
     */
    
    /*!
        @method KRVector3D
        このベクトルを、x=0.0, y=0.0, z=0.0 で初期化します。
     */
    KRVector3D();

    /*!
        @method KRVector3D
        このベクトルを、与えられた3つの数値で初期化します。
     */
    KRVector3D(double _x, double _y, double _z);

    /*!
        @method KRVector3D
        与えられたベクトルをコピーして、このベクトルを初期化します。
     */
    KRVector3D(const KRVector3D& vec);
    
    /*!
        @task 幾何計算のための関数
     */    
    
    /*!
        @method innerProduct
        与えられたベクトルを右辺値として、このベクトルとの内積を計算します。
     */
    double innerProduct(const KRVector3D& vec) const;

    /*!
        @method length
        このベクトルの長さをリターンします。
     */
    double  length() const;
    
    /*!
        @method lengthSq
        このベクトルの長さの2乗をリターンします。
     */
    double  lengthSq() const;
    
    /*!
        @method normalize
        このベクトルを、長さ1のベクトルに正規化します。
     */
    KRVector3D &normalize();
    
    /*!
        @method outerProduct
        与えられたベクトルを右辺値として、このベクトルとの外積を計算します。
     */
    KRVector3D outerProduct(const KRVector3D& vec) const;
    
    
    /*!
        @task 演算子のオーバーライド
     */
    
    /*!
        @method operator+
     */
    KRVector3D operator+(const KRVector3D& vec) const;

    /*!
        @method operator+=
     */
    KRVector3D& operator+=(const KRVector3D& vec);
    
    /*!
        @method operator-
     */
    KRVector3D operator-(const KRVector3D& vec) const;

    /*!
        @method operator-=
     */
    KRVector3D& operator-=(const KRVector3D& vec);
    
    /*!
        @method operator/
     */
    KRVector3D operator/(double value) const;

    /*!
        @method operator/=
     */
    KRVector3D& operator/=(double value);
    
    /*!
        @method operator*
     */
    KRVector3D operator*(double value) const;

    /*!
        @method operator*=
     */
    KRVector3D& operator*=(double value);
    
    /*!
        @method operator==
     */
    bool operator==(const KRVector3D& vec) const;

    /*!
        @method operator!=
     */
    bool operator!=(const KRVector3D& vec) const;
    
    bool operator<(const KRVector3D& vec) const;

    /*!
        @method operator-
     */
    KRVector3D operator-() const;
    
    virtual std::string to_s() const;

} KRVector3D;


/*!
    @struct KRVector3DInt
    @group  Game Foundation
    @abstract int 型の3次元ベクトルを表すための構造体です。
    点情報、サイズ情報を表すためにも使われます。
 */
typedef struct KRVector3DInt : public KRObject {
    
    /*!
        @var x
        このベクトルのX成分を表す数値です。
     */
    int     x;
    
    /*!
        @var y
        このベクトルのY成分を表す数値です。
     */    
    int     y;

    /*!
        @var z
        このベクトルのZ成分を表す数値です。
     */    
    int     z;
    
    /*!
        @task コンストラクタ
     */
    
    /*!
        @method KRVector3DInt
        このベクトルを、x=0, y=0, z=0 で初期化します。
     */
    KRVector3DInt();

    /*!
        @method KRVector3DInt
        このベクトルを、与えられた3つの数値で初期化します。
     */
    KRVector3DInt(int _x, int _y, int _z);

    /*!
        @method KRVector3DInt
        与えられたベクトルをコピーして、このベクトルを初期化します。
     */
    KRVector3DInt(const KRVector3D& vec);
    
    /*!
        @task 幾何計算のための関数
     */    
    
    /*!
        @method innerProduct
        与えられたベクトルを右辺値として、このベクトルとの内積を計算します。
     */
    int innerProduct(const KRVector3DInt& vec) const;

    /*!
        @method length
        このベクトルの長さをリターンします。
     */
    double  length() const;
    
    /*!
        @method lengthSq
        このベクトルの長さの2乗をリターンします。
     */
    int     lengthSq() const;
    
    /*!
        @method normalize
        @abstract このベクトルを、長さ1のベクトルに正規化したベクトルを生成します。
        生成されるベクトルは、KRVector3D 型になります。
     */
    KRVector3D normalize() const;
    
    /*!
        @method outerProduct
        与えられたベクトルを右辺値として、このベクトルとの外積を計算します。
     */
    KRVector3DInt outerProduct(const KRVector3D& vec) const;
    
    
    /*!
        @task 演算子のオーバーライド
     */
    
    /*!
        @method operator+
     */
    KRVector3DInt operator+(const KRVector3DInt& vec) const;

    /*!
        @method operator+=
     */
    KRVector3DInt& operator+=(const KRVector3DInt& vec);
    
    /*!
        @method operator-
     */
    KRVector3DInt operator-(const KRVector3DInt& vec) const;

    /*!
        @method operator-=
     */
    KRVector3DInt& operator-=(const KRVector3DInt& vec);
    
    /*!
        @method operator/
     */
    KRVector3DInt operator/(int value) const;

    /*!
        @method operator/=
     */
    KRVector3DInt& operator/=(int value);
    
    /*!
        @method operator*
     */
    KRVector3DInt operator*(int value) const;

    /*!
        @method operator*=
     */
    KRVector3DInt& operator*=(int value);
    
    /*!
        @method operator==
     */
    bool operator==(const KRVector3DInt& vec) const;

    /*!
        @method operator!=
     */
    bool operator!=(const KRVector3DInt& vec) const;
    
    bool operator<(const KRVector3DInt& vec) const;

    /*!
        @method operator-
     */
    KRVector3DInt operator-() const;
    
    virtual std::string to_s() const;

} KRVector3DInt;


/*!
    @const  KRRect2DZero
    @group  Game Foundation
    @abstract x, y, width, height のすべての成分が 0.0 となっている KRRect2D 構造体の定数です。
 */
extern const KRRect2D       KRRect2DZero;

/*!
    @const  KRVector2DOne
    @group  Game Foundation
    @abstract x成分とy成分がどちらも 1.0 となっている KRVector2D 構造体の定数です。
 */
extern const KRVector2D     KRVector2DOne;

/*!
    @const  KRVector2DZero
    @group  Game Foundation
    @abstract x成分とy成分がどちらも 0.0 となっている KRVector2D 構造体の定数です。
 */
extern const KRVector2D     KRVector2DZero;

/*!
    @const  KRVector2DIntZero
    @group  Game Foundation
    @abstract x成分とy成分がどちらも 0 となっている KRVector2DInt 構造体の定数です。
 */
extern const KRVector2DInt  KRVector2DIntZero;

/*!
    @const  KRVector3DOne
    @group  Game Foundation
    @abstract x成分、y成分、z成分がすべて 1.0 となっている KRVector3D 構造体の定数です。
 */
extern const KRVector3D     KRVector3DOne;

/*!
    @const  KRVector3DZero
    @group  Game Foundation
    @abstract x成分、y成分、z成分がすべて 0.0 となっている KRVector3D 構造体の定数です。
 */
extern const KRVector3D     KRVector3DZero;

/*!
    @const  KRVector3DIntZero
    @group  Game Foundation
    @abstract x成分、y成分、z成分がすべて 0 となっている KRVector3DInt 構造体の定数です。
 */
extern const KRVector2DInt  KRVector2DIntZero;


/*!
    @enum   KRLanguageType
    @group  Game Foundation
    @constant   KRLanguageEnglish   英語環境を表す定数です。
    @constant   KRLanguageJapanese  日本語環境を表す定数です。
    @abstract   言語環境を表すための型です。
    グローバル変数 KRLanguage で、ゲームが実行されている言語環境を表すために使われます。
 */
typedef enum KRLanguageType {
    KRLanguageEnglish,
    KRLanguageJapanese
} KRLanguageType;

/*!
    @var    gKRLanguage
    @group  Game Foundation
    @abstract 現在の言語環境を表す変数です。
    <p>該当する環境定数が KRLanguageType 列挙型に見つからない場合には、自動的に KRLanguageEnglish が設定されます。</p>
    <p>以下のようにして利用します。</p>
    <blockquote class="code"><pre>std::string text = "English Text";<br />
    if (gKRLanguage == KRLanguageJapanese) {<br />
    &nbsp;&nbsp;&nbsp;&nbsp;text = "日本語のテキスト";<br />
    }</pre></blockquote>
 */
extern KRLanguageType   gKRLanguage;



