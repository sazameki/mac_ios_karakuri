/*!
    @file   KRSimulator2DCollision.h
    @author numata
    @date   09/08/17
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>


class KRShape2D;


typedef struct KRCollisionInfo2D {
    KRShape2D   *shape1;
    KRShape2D   *shape2;
} KRCollisionInfo2D;

