/*!
    @file   KRPrimitive2D.h
    @author numata
    @date   09/07/31
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/Karakuri.h>


class KRPrimitive2D {

private:
	KRPrimitive2D() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
	virtual ~KRPrimitive2D() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    
public:
    
#pragma mark ---- 線 ----
    static void drawLine(const KRVector2D& p1, const KRVector2D& p2, const KRColor& color, float width = 1.0f);
    static void drawLine(const KRVector2D& p1, const KRVector2D& p2, const KRColor& c1, const KRColor& c2, float width = 1.0f);    
    
#pragma mark ---- 四角形 ----
    static void fillQuad(const KRRect2D& rect, const KRColor& color);
    static void fillQuad(const KRRect2D& rect, const KRColor& c1, const KRColor& c2, const KRColor& c3, const KRColor& c4);
    static void fillQuad(const KRVector2D& p1, const KRVector2D& p2, const KRVector2D& p3, const KRVector2D& p4, const KRColor& color);
    static void fillQuad(const KRVector2D& p1, const KRVector2D& p2, const KRVector2D& p3, const KRVector2D& p4,
                         const KRColor& c1, const KRColor& c2, const KRColor& c3, const KRColor& c4);
    
};

