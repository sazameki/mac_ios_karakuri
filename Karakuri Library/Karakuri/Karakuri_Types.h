/*
 *  Karakuri_Types.h
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/18.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include <Karakuri/KarakuriString.h>

#include <string>


struct KRVector2D;
struct KRSize2D;


typedef struct KRObject {
    KRObject();
    const char *c_str() const;
    virtual std::string to_s() const;
} KRObject;


/*!
    @struct KRRect2D
    @group  Game Foundation
 */
typedef struct KRRect2D : public KRObject {
    float x;
    float y;
    float width;
    float height;
    
    KRRect2D();
    KRRect2D(float _x, float _y, float _width, float _height);
    KRRect2D(const KRVector2D& _origin, const KRVector2D& _size);
    KRRect2D(const KRRect2D& _rect);
    
    float getMinX() const;
    float getMinY() const;
    float getMaxX() const;
    float getMaxY() const;
    
    KRVector2D getOrigin() const;
    KRVector2D getSize() const;
    KRVector2D getCenterPos() const;
    
    KRRect2D    getIntersection(const KRRect2D& rect) const;
    KRRect2D    getUnion(const KRRect2D& rect) const;
    
    bool    contains(float _x, float _y) const;
    bool    contains(const KRVector2D& pos) const;
    bool    contains(float _x, float _y, float _width, float _height) const;
    bool    contains(const KRRect2D& rect) const;
    bool    intersects(float _x, float _y, float _width, float _height) const;
    bool    intersects(const KRRect2D& rect) const;
    
    bool    operator==(const KRRect2D& rect) const;
    bool    operator!=(const KRRect2D& rect) const;
    
    static KRRect2D makeIntersection(const KRRect2D& src1, const KRRect2D& src2);
    static KRRect2D makeUnion(const KRRect2D& src1, const KRRect2D& src2);
    
    virtual std::string to_s() const;
    
} KRRect2D;


/*!
    @struct KRVector2D
    @group  Game Foundation
    2次元ベクトルを表すための構造体です。点情報、サイズ情報を表すためにも使われます。
 */
typedef struct KRVector2D : public KRObject {
    
    /*!
        @var    x
        @abstract   X座標
     */
    float   x;

    /*!
        @var    y
        @abstract   Y座標
     */
    float   y;

    /*!
        @method KRVector2D
     */
    KRVector2D();

    /*!
        @method KRVector2D
        @param _x   X座標
        @param _y   Y座標
     */
    KRVector2D(float _x, float _y);
    KRVector2D(const KRVector2D& vec);
    
    KRVector2D operator+(const KRVector2D& vec) const;
    KRVector2D& operator+=(const KRVector2D& vec);

    KRVector2D operator-(const KRVector2D& vec) const;
    KRVector2D& operator-=(const KRVector2D& vec);

    KRVector2D operator/(float value) const;
    KRVector2D& operator/=(float value);

    KRVector2D operator*(float value) const;
    KRVector2D& operator*=(float value);
    
    bool operator==(const KRVector2D& vec) const;
    bool operator!=(const KRVector2D& vec) const;
    
    KRVector2D operator-() const;

    float   length() const;
    float   lengthSq() const;
    KRVector2D &normalize();

    float   angle(const KRVector2D &vec) const;

    float innerProduct(const KRVector2D& vec) const;
    float outerProduct(const KRVector2D& vec) const;

    virtual std::string to_s() const;

} KRVector2D;


/*!
    @struct KRVector3D
    @group  Game Foundation
    3次元ベクトルを表すための構造体です。点情報、サイズ情報を表すためにも使われます。
 */
typedef struct KRVector3D : public KRObject {
    float   x;
    float   y;
    float   z;
    
    KRVector3D();
    KRVector3D(float _x, float _y, float _z);
    KRVector3D(const KRVector3D& vec);
    
    KRVector3D operator+(const KRVector3D& vec) const;
    KRVector3D& operator+=(const KRVector3D& vec);
    
    KRVector3D operator-(const KRVector3D& vec) const;
    KRVector3D& operator-=(const KRVector3D& vec);
    
    KRVector3D operator/(float value) const;
    KRVector3D& operator/=(float value);
    
    KRVector3D operator*(float value) const;
    KRVector3D& operator*=(float value);
    
    bool operator==(const KRVector3D& vec) const;
    bool operator!=(const KRVector3D& vec) const;
    
    KRVector3D operator-() const;
    
    float   length() const;
    float   lengthSq() const;
    KRVector3D &normalize();
    
    float innerProduct(const KRVector3D& vec) const;
    KRVector3D outerProduct(const KRVector3D& vec) const;

    virtual std::string to_s() const;

} KRVector3D;


extern const KRRect2D         KRRect2DZero;
extern const KRVector2D       KRVector2DZero;
extern const KRVector2D       KRVector2DOne;
extern const KRVector3D       KRVector3DZero;


/*!
    @enum   KRLanguageType
    @group  Game Foundation
 */
typedef enum KRLanguageType {
    KRLanguageEnglish,
    KRLanguageJapanese
} KRLanguageType;

/*!
    @var    KRLanguage
    @group  Game Foundation
 */
extern KRLanguageType   KRLanguage;



