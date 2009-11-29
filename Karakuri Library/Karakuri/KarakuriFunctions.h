//
//  KarakuriFunctions.h
//  Karakuri Prototype
//
//  Created by numata on 09/07/22.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#pragma once

#include <Karakuri/KarakuriLibrary.h>

#include <Karakuri/Karakuri_Globals.h>


struct KRVector2D;


/*!
    @function   KRMin
    @group      Game Foundation
    @abstract   与えられた2数の最小値を求めます。
    マクロ関数なので、任意の型に対して使用できます。
 */
#define KRMin(a, b)  (((a) < (b))? (a): (b));

/*!
    @function   KRMax
    @group      Game Foundation
    @abstract   与えられた2数の最大値を求めます。
    マクロ関数なので、任意の型に対して使用できます。
 */
#define KRMax(a, b)  (((a) > (b))? (a): (b));

/*!
    @function   KRPushMatrix
    @group      Game 2D Graphics
    @abstract   行列スタックの最上部の変換行列を複製します。
    この関数を呼び出した後は、必ず KRPopMatrix() 関数を呼び出してください。KRPushMatrix() 関数の呼び出し回数と KRPopMatrix() 関数の呼び出し回数が合わない場合には、実行時エラーがスローされます。
 */
#define KRPushMatrix()\
    _KRMatrixPushCount++;\
    glPushMatrix();

/*!
    @function   KRPopMatrix
    @group      Game 2D Graphics
    @abstract   行列スタックの最上部の変換行列を破棄します。
 */
#define KRPopMatrix()\
    KRTexture2D::processBatchedTexture2DDraws();\
    _KRMatrixPushCount--;\
    glPopMatrix();

/*!
    @function   KRRotate2D
    @group      Game 2D Graphics
    @abstract   2次元的に（Z軸を中心として）画面を回転させます。
 */
inline void KRRotate2D(double angle);

/*!
    @function   KRRotate2D
    @group      Game 2D Graphics
    @abstract   中心点と角度を指定して、2次元的に（Z軸を中心として）画面を回転させます。
 */
inline void KRRotate2D(double angle, const KRVector2D& centerPos);

/*!
    @function   KRScale2D
    @group      Game 2D Graphics
    @abstract   2次元的に（Z軸を中心として）画面をスケーリングさせます。
 */
inline void KRScale2D(double x, double y);

/*!
    @function   KRScale2D
    @group      Game 2D Graphics
    @abstract   2次元的に（Z軸を中心として）画面をスケーリングさせます。
 */
inline void KRScale2D(const KRVector2D& scale);

/*!
    @function   KRTranslate2D
    @group      Game 2D Graphics
    @abstract   2次元的に（Z軸を中心として）画面を平行移動させます。
 */
inline void KRTranslate2D(double x, double y);

/*!
    @function   KRTranslate2D
    @group      Game 2D Graphics
    @abstract   2次元的に（Z軸を中心として）画面を平行移動させます。
 */
inline void KRTranslate2D(const KRVector2D& size);

/*!
    @function   KRSleep
    @group      Game Foundation
    @abstract   一定時間スリープさせます。
    @param  interval    スリープさせる時間（秒単位）。
 */
void    KRSleep(double interval);

/*!
    @function   KRCurrentTime
    @group      Game Foundation
    @abstract   現在時刻を秒単位で表す数値をリターンします。
    @return     現在時刻
    @discussion この数値は2001年1月1日 0時00分00秒からの経過時間（秒）となっていますが、基本的には差分をとって利用してください。
 */
double  KRCurrentTime();

/*!
    @function   KRGetKarakuriVersion
    @group      Game Foundation
    @abstract   Karakuri Framework の現在のバージョンを取得します。
 */
std::string KRGetKarakuriVersion();

/*!
    @function   KRChangeWorld
    @group      Game Foundation
    @abstract   ワールドを切り替えます。
 */
void    KRChangeWorld(const std::string& worldName);

bool    KRCheckOpenGLExtensionSupported(const std::string& extensionName);



