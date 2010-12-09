//
//  KarakuriFunctions.h
//  Karakuri Prototype
//
//  Created by numata on 09/07/22.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#pragma once

#include <Karakuri/KarakuriLibrary.h>

#include <Karakuri/KarakuriGlobals.h>
#include <AvailabilityMacros.h>


struct KRVector2D;


/*!
    @function   KRMin
    @group      Game Type
    @abstract   与えられた2数の最小値を求めます。
    マクロ関数なので、任意の型に対して使用できます。
 */
#define KRMin(a, b)  (((a) < (b))? (a): (b));

/*!
    @function   KRMax
    @group      Game Type
    @abstract   与えられた2数の最大値を求めます。
    マクロ関数なので、任意の型に対して使用できます。
 */
#define KRMax(a, b)  (((a) > (b))? (a): (b));

/*!
    @function   KRPushMatrix
    @group      Game Graphics
    @abstract   行列スタックの最上部の変換行列を複製します。
    この関数を呼び出した後は、必ず KRPopMatrix() 関数を呼び出してください。KRPushMatrix() 関数の呼び出し回数と KRPopMatrix() 関数の呼び出し回数が合わない場合には、実行時エラーがスローされます。
 */
#define KRPushMatrix()\
    _KRMatrixPushCount++;\
    glPushMatrix();

/*!
    @function   KRPopMatrix
    @group      Game Graphics
    @abstract   行列スタックの最上部の変換行列を破棄します。
 */
#define KRPopMatrix()\
    _KRTexture2D::processBatchedTexture2DDraws();\
    _KRMatrixPushCount--;\
    glPopMatrix();

/*!
    @function   KRRotate2D
    @group      Game Graphics
    @abstract   2次元的に（Z軸を中心として）画面を回転させます。
 */
void    KRRotate2D(double angle);

/*!
    @function   KRRotate2D
    @group      Game Graphics
    @abstract   中心点と角度を指定して、2次元的に（Z軸を中心として）画面を回転させます。
 */
void    KRRotate2D(double angle, const KRVector2D& centerPos);

/*!
    @function   KRScale2D
    @group      Game Graphics
    @abstract   2次元的に（Z軸を中心として）画面をスケーリングさせます。
 */
void    KRScale2D(double x, double y);

/*!
    @function   KRScale2D
    @group      Game Graphics
    @abstract   2次元的に（Z軸を中心として）画面をスケーリングさせます。
 */
void    KRScale2D(const KRVector2D& scale);

/*!
    @function   KRTranslate2D
    @group      Game Graphics
    @abstract   2次元的に（Z軸を中心として）画面を平行移動させます。
 */
void    KRTranslate2D(double x, double y);

/*!
    @function   KRTranslate2D
    @group      Game Graphics
    @abstract   2次元的に（Z軸を中心として）画面を平行移動させます。
 */
void    KRTranslate2D(const KRVector2D& size);

/*!
    @function   KRSleep
    @group      Game System
    @param  interval    スリープさせる時間（秒単位）。
    @abstract   <strong class="warning">(Deprecated) 現在、この関数の利用は推奨されません。代わりに gKRGameMan->sleep() を利用してください。</strong>
    <p>一定時間スリープさせます。</p>
 */
void    KRSleep(double interval)    DEPRECATED_ATTRIBUTE;

/*!
    @function   KRCurrentTime
    @group      Game System
    @abstract   <strong class="warning">(Deprecated) 現在、この関数の利用は推奨されません。代わりに gKRGameMan->getCurrentTime() を利用してください。</strong>
    @return     現在時刻
    @discussion この数値は2001年1月1日 0時00分00秒からの経過時間（秒）となっていますが、基本的には差分をとって利用してください。
    <p>現在時刻を秒単位で表す数値をリターンします。</p>
 */
double  KRCurrentTime() DEPRECATED_ATTRIBUTE;

/*!
    @function   KRGetKarakuriVersion
    @group      Game System
    @abstract   Karakuri Framework の現在のバージョンを取得します。
 */
std::string KRGetKarakuriVersion();

/*!
    @function   KRChangeWorld
    @group      Game System
    @abstract   <strong class="warning">(Deprecated) 現在、この関数の利用は推奨されません。代わりに gKRGameMan->changeWorld() を利用してください。</strong>
    <p>ワールドを切り替えます。</p>
 */
void    KRChangeWorld(const std::string& worldName) DEPRECATED_ATTRIBUTE;

/*!
    @function   KRCheckDeviceType
    @group      Game System
    @abstract   現在ゲームを実行している環境が、引数で与えられた環境かどうかをチェックします。
 */
bool    KRCheckDeviceType(KRDeviceType deviceType);

bool    _KRCheckOpenGLExtensionSupported(const std::string& extensionName);



