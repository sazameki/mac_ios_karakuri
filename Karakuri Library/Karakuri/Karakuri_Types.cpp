/*
 *  Karakuri_Types.cpp
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/18.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#include "Karakuri_Types.h"


#define KR_MATH_DIFF   0.0000001


const KRRect2D      KRRect2DZero    = KRRect2D(0.0, 0.0, 0.0, 0.0);
const KRVector2D    KRVector2DZero  = KRVector2D(0.0, 0.0);
const KRVector2D    KRVector2DOne   = KRVector2D(1.0, 1.0);
const KRVector3D    KRVector3DZero   = KRVector3D(0.0, 0.0, 0.0);


KRLanguageType gKRLanguage   = KRLanguageEnglish;


#pragma mark -

KRObject::KRObject()
{
    // Nothing to do
}

const char *KRObject::c_str() const
{
    return to_s().c_str();
}

std::string KRObject::to_s() const
{
    return KRFS("KRObject(%p)", this);
}


#pragma mark -
#pragma mark KRRect2D Class Implementation

KRRect2D::KRRect2D()
: x(0.0), y(0.0), width(0.0), height(0.0)
{
}

KRRect2D::KRRect2D(double _x, double _y, double _width, double _height)
: x(_x), y(_y), width(_width), height(_height)
{
}

KRRect2D::KRRect2D(const KRVector2D& _origin, const KRVector2D& _size)
: x(_origin.x), y(_origin.y), width(_size.x), height(_size.y)
{
}

KRRect2D::KRRect2D(const KRRect2D& _rect)
: x(_rect.x), y(_rect.y), width(_rect.width), height(_rect.height)
{
}

double KRRect2D::getMinX() const
{
    return x;
}

double KRRect2D::getMinY() const
{
    return y;
}

double KRRect2D::getMaxX() const
{
    return x + width;
}

double KRRect2D::getMaxY() const
{
    return y + height;
}

KRVector2D KRRect2D::getOrigin() const
{
    return KRVector2D(x, y);
}

KRVector2D KRRect2D::getSize() const
{
    return KRVector2D(width, height);
}

KRVector2D KRRect2D::getCenterPos() const
{
    return KRVector2D(x + width / 2, y + height / 2);
}

KRRect2D KRRect2D::getIntersection(const KRRect2D& rect) const
{
    return KRRect2D::makeIntersection(*this, rect);
}

KRRect2D KRRect2D::getUnion(const KRRect2D& rect) const
{
    return KRRect2D::makeUnion(*this, rect);
}

bool KRRect2D::contains(double _x, double _y) const
{
    return (_x >= x &&
            _y >= y &&
            _x < x + width &&
            _y < y + height);
}

bool KRRect2D::contains(const KRVector2D& pos) const
{
    return contains(pos.x, pos.y);
}

bool KRRect2D::contains(double _x, double _y, double _width, double _height) const
{
    if (width <= 0.0 || height <= 0.0 || _width <= 0.0 || height <= 0.0) {
        return false;
    }
    
    return (_x >= x &&
            _y >= y &&
            (_x + _width) <= (x + width) &&
            (_y + _height) <= (y + height));
}

bool KRRect2D::contains(const KRRect2D& rect) const
{
    return contains(rect.x, rect.y, rect.width, rect.height);
}

bool KRRect2D::intersects(double _x, double _y, double _width, double _height) const
{
    if (width <= 0.0 || height <= 0.0 || _width <= 0.0 || height <= 0.0) {
        return false;
    }
    
    return ((_x + _width) > x &&
            (_y + _height) > y &&
            _x < (x + width) &&
            _y < (y + height));
}

bool KRRect2D::intersects(const KRRect2D& rect) const
{
    return intersects(rect.x, rect.y, rect.width, rect.height);
}

bool KRRect2D::operator==(const KRRect2D& rect) const
{
    return (fabs(x - rect.x) < KR_MATH_DIFF &&
            fabs(y - rect.y) < KR_MATH_DIFF &&
            fabs(width - rect.width) < KR_MATH_DIFF &&
            fabs(height - rect.height) < KR_MATH_DIFF);
}

bool KRRect2D::operator!=(const KRRect2D& rect) const
{
    return (fabs(x - rect.x) >= KR_MATH_DIFF ||
            fabs(y - rect.y) >= KR_MATH_DIFF ||
            fabs(width - rect.width) >= KR_MATH_DIFF ||
            fabs(height - rect.height) >= KR_MATH_DIFF);
}

KRRect2D KRRect2D::makeIntersection(const KRRect2D& src1, const KRRect2D& src2)
{
    double x1 = std::max(src1.getMinX(), src2.getMinX());
	double y1 = std::max(src1.getMinY(), src2.getMinY());
	double x2 = std::min(src1.getMaxX(), src2.getMaxX());
	double y2 = std::min(src1.getMaxY(), src2.getMaxY());
    
    return KRRect2D(x1, y1, x2 - x1, y2 - y1);
}

KRRect2D KRRect2D::makeUnion(const KRRect2D& src1, const KRRect2D& src2)
{
    double x1 = std::min(src1.getMinX(), src2.getMinX());
	double y1 = std::min(src1.getMinY(), src2.getMinY());
	double x2 = std::max(src1.getMaxX(), src2.getMaxX());
	double y2 = std::max(src1.getMaxY(), src2.getMaxY());
    
    if (x2 < x1) {
	    double t = x1;
	    x1 = x2;
	    x2 = t;
	}
	if (y2 < y1) {
	    double t = y1;
	    y1 = y2;
	    y2 = t;
	}
    
    return KRRect2D(x1, y1, x2 - x1, y2 - y1);
}

std::string KRRect2D::to_s() const
{
    return KRFS("<rect2>(x=%3.2f, y=%3.2f, width=%3.2f, height=%3.2f)", x, y);
}


#pragma mark -
#pragma mark KRVector2D Class Implementation

KRVector2D::KRVector2D()
    : x(0.0), y(0.0)
{
}

KRVector2D::KRVector2D(double _x, double _y)
    : x(_x), y(_y)
{
}

KRVector2D::KRVector2D(const KRVector2D &vec)
    : x(vec.x), y(vec.y)
{
}

KRVector2D KRVector2D::operator+(const KRVector2D &vec) const
{
    return KRVector2D(x + vec.x, y + vec.y);
}

KRVector2D& KRVector2D::operator+=(const KRVector2D &vec)
{
    x += vec.x;
    y += vec.y;
    return *this;
}

KRVector2D KRVector2D::operator-(const KRVector2D &vec) const
{
    return KRVector2D(x - vec.x, y - vec.y);
}

KRVector2D& KRVector2D::operator-=(const KRVector2D &vec)
{
    x -= vec.x;
    y -= vec.y;
    return *this;
}

KRVector2D KRVector2D::operator*(double value) const
{
    return KRVector2D(x * value, y * value);
}

KRVector2D& KRVector2D::operator*=(double value)
{
    x *= value;
    y *= value;
    return *this;
}

KRVector2D KRVector2D::operator/(double value) const
{
    return KRVector2D(x / value, y / value);
}

KRVector2D& KRVector2D::operator/=(double value)
{
    x /= value;
    y /= value;
    return *this;
}

bool KRVector2D::operator==(const KRVector2D &vec) const
{
    return (fabs(x - vec.x) < KR_MATH_DIFF &&
            fabs(y - vec.y) < KR_MATH_DIFF);
}

bool KRVector2D::operator!=(const KRVector2D &vec) const
{
    return (fabs(x - vec.x) >= KR_MATH_DIFF ||
            fabs(y - vec.y) >= KR_MATH_DIFF);
}

KRVector2D KRVector2D::operator-() const
{
    return KRVector2D(-x, -y);
}

double KRVector2D::length() const
{
    return sqrt(x * x + y * y);
}

double KRVector2D::lengthSq() const
{
    return (x * x + y * y);
}

KRVector2D &KRVector2D::normalize()
{
    double theLength = sqrt(x * x + y * y);
    x /= theLength;
    y /= theLength;
    return *this;
}

double KRVector2D::angle(const KRVector2D &vec) const
{
    return atan2(vec.y - y, vec.x - x);
}

double KRVector2D::innerProduct(const KRVector2D &vec) const
{
    return x * vec.x + y * vec.y;
}

double KRVector2D::outerProduct(const KRVector2D &vec) const
{
    return x * vec.y - y * vec.x;
}

std::string KRVector2D::to_s() const
{
    return KRFS("<vec2>(x=%3.2f, y=%3.2f)", x, y);
}



#pragma mark -
#pragma mark KRVector3D Class Implementation

KRVector3D::KRVector3D()
    : x(0.0), y(0.0), z(0.0)
{
}

KRVector3D::KRVector3D(double _x, double _y, double _z)
    : x(_x), y(_y), z(_z)
{
}

KRVector3D::KRVector3D(const KRVector3D& vec)
    : x(vec.x), y(vec.y), z(vec.z)
{
}

KRVector3D KRVector3D::operator+(const KRVector3D &vec) const
{
    return KRVector3D(x + vec.x, y + vec.y, z + vec.z);
}

KRVector3D& KRVector3D::operator+=(const KRVector3D &vec)
{
    x += vec.x;
    y += vec.y;
    z += vec.z;
    return *this;
}

KRVector3D KRVector3D::operator-(const KRVector3D &vec) const
{
    return KRVector3D(x - vec.x, y - vec.y, z - vec.z);
}

KRVector3D& KRVector3D::operator-=(const KRVector3D &vec)
{
    x -= vec.x;
    y -= vec.y;
    z -= vec.z;
    return *this;
}

KRVector3D KRVector3D::operator*(double value) const
{
    return KRVector3D(x * value, y * value, z * value);
}

KRVector3D& KRVector3D::operator*=(double value)
{
    x *= value;
    y *= value;
    z *= value;
    return *this;
}

KRVector3D KRVector3D::operator/(double value) const
{
    return KRVector3D(x / value, y / value, z / value);
}

KRVector3D& KRVector3D::operator/=(double value)
{
    x /= value;
    y /= value;
    z /= value;
    return *this;
}

bool KRVector3D::operator==(const KRVector3D &vec) const
{
    return (fabs(x - vec.x) < KR_MATH_DIFF &&
            fabs(y - vec.y) < KR_MATH_DIFF &&
            fabs(z - vec.z) < KR_MATH_DIFF);
}

bool KRVector3D::operator!=(const KRVector3D &vec) const
{
    return (fabs(x - vec.x) >= KR_MATH_DIFF ||
            fabs(y - vec.y) >= KR_MATH_DIFF ||
            fabs(z - vec.z) >= KR_MATH_DIFF);
}

KRVector3D KRVector3D::operator-() const
{
    return KRVector3D(-x, -y, -z);
}

double KRVector3D::length() const
{
    return sqrt(x * x + y * y + z * z);
}

double KRVector3D::lengthSq() const
{
    return (x * x + y * y + z * z);
}

KRVector3D &KRVector3D::normalize()
{
    double theLength = sqrt(x * x + y * y + z * z);
    x /= theLength;
    y /= theLength;
    z /= theLength;
    return *this;
}

double KRVector3D::innerProduct(const KRVector3D& vec) const
{
    return (x * vec.x + y * vec.y + z * vec.z);
}

KRVector3D KRVector3D::outerProduct(const KRVector3D& vec) const
{
    return KRVector3D(y * vec.z - z * vec.y,
                      z * vec.x - x * vec.z,
                      x * vec.y - y * vec.x);
}

std::string KRVector3D::to_s() const
{
    return KRFS("<vec3>(x=%3.2f, y=%3.2f, z=%3.2f)", x, y, z);
}


