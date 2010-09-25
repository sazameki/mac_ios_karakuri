/*!
    @file   KRSimulator2DCollision.h
    @author numata
    @date   09/08/17
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>


class KRShape2D;


/*!
    @struct KRCollisionInfo2D
    @group Game 2D Simulator
    KRSimulator2D クラスで衝突が検知された図形の組の情報を格納しておくための構造体です。
 */
typedef struct KRCollisionInfo2D : public KRObject {
    /*!
        @var shape1
        衝突した図形に対応したオブジェクトのポインタです。
     */
    KRShape2D*  shape1;

    /*!
        @var shape2
        衝突した図形に対応したオブジェクトのポインタです。
     */
    KRShape2D*  shape2;
} KRCollisionInfo2D;



