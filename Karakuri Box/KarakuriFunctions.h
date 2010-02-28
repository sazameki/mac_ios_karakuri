//
//  KarakuriFunctions.h
//  Karakuri Prototype
//
//  Created by numata on 09/07/22.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#pragma once

#include "KarakuriGlobals.h"
#include "KarakuriTypes.h"


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
void    KRRotate2D(double angle);

/*!
    @function   KRRotate2D
    @group      Game 2D Graphics
    @abstract   中心点と角度を指定して、2次元的に（Z軸を中心として）画面を回転させます。
 */
void    KRRotate2D(double angle, const KRVector2D& centerPos);

/*!
    @function   KRScale2D
    @group      Game 2D Graphics
    @abstract   2次元的に（Z軸を中心として）画面をスケーリングさせます。
 */
void    KRScale2D(double x, double y);

/*!
    @function   KRScale2D
    @group      Game 2D Graphics
    @abstract   2次元的に（Z軸を中心として）画面をスケーリングさせます。
 */
void    KRScale2D(const KRVector2D& scale);

/*!
    @function   KRTranslate2D
    @group      Game 2D Graphics
    @abstract   2次元的に（Z軸を中心として）画面を平行移動させます。
 */
void    KRTranslate2D(double x, double y);

/*!
    @function   KRTranslate2D
    @group      Game 2D Graphics
    @abstract   2次元的に（Z軸を中心として）画面を平行移動させます。
 */
void    KRTranslate2D(const KRVector2D& size);





