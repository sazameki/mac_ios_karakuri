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


/*!
    @function   KRMin
    @group      Game Foundation
    @abstract   与えられた2数の最小値を求めます。
    マクロ関数なので、任意の型に対して使用できます。
 */
#define KRMin(a, b)  ((a) < (b))? (a): (b);

/*!
    @function   KRMax
    @group      Game Foundation
    @abstract   与えられた2数の最大値を求めます。
    マクロ関数なので、任意の型に対して使用できます。
 */
#define KRMax(a, b)  ((a) > (b))? (a): (b);

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
    @function   KRRotateScreen2D
    @group      Game 2D Graphics
 */
#define KRRotateScreen2D(angle, centerPos)     glTranslatef(((centerPos).x), ((centerPos).y), 0.0f);glRotatef(((angle)*180)/M_PI, 0.0f, 0.0f, 1.0f);glTranslatef(-((centerPos).x), -((centerPos).y), 0.0f);

/*!
    @function   KRRotate2D
    @group      Game 2D Graphics
 */
#define KRRotate2D(angle)       glRotatef(((angle)*180)/M_PI, 0.0f, 0.0f, 1.0f);

/*!
    @function   KRTranslate2D
    @group      Game 2D Graphics
 */
#define KRTranslate2D(x, y)     glTranslatef((x), (y), 0.0f);

/*!
    @function   KRScale2D
    @group      Game 2D Graphics
 */
#define KRScale2D(x, y)         glScalef((x), (y), 1.0f);


/*!
    @function   KRSleep
    @group      Game Foundation
    @abstract   一定時間スリープします。
    @param  interval    スリープする時間（秒単位）。
 */
void    KRSleep(float interval);

/*!
    @function   KRCurrentTime
    @group      Game Foundation
    @abstract   現在時刻を取得します。
    @return     現在時刻
 */
float   KRCurrentTime();

bool    KRCheckOpenGLExtensionSupported(const std::string& extensionName);

/*!
    @function   KRGetKarakuriVersion
    @group      Game Foundation
 */
std::string KRGetKarakuriVersion();

