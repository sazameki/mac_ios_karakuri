/*!
    @file   KRPrimitive2D.h
    @author numata
    @date   09/07/31
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/Karakuri.h>


/*!
    @class  KRPrimitive2D
    @group  Game 2D Graphics
 */
class KRPrimitive2D {

private:
	KRPrimitive2D() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
	virtual ~KRPrimitive2D() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    
public:
    
#pragma mark ---- 線 ----
    /*!
        @method drawLine
     */
    static void drawLine(const KRVector2D& p1, const KRVector2D& p2, const KRColor& color, float width = 1.0f);

    /*!
        @method drawLine
     */
    static void drawLine(const KRVector2D& p1, const KRVector2D& p2, const KRColor& c1, const KRColor& c2, float width = 1.0f);    
    
#pragma mark ---- 四角形 ----
    /*!
        @method fillQuad
     */
    static void fillQuad(const KRRect2D& rect, const KRColor& color);

    /*!
        @method fillQuad
     */
    static void fillQuad(const KRRect2D& rect, const KRColor& c1, const KRColor& c2, const KRColor& c3, const KRColor& c4);

    /*!
        @method fillQuad
     */
    static void fillQuad(const KRVector2D& p1, const KRVector2D& p2, const KRVector2D& p3, const KRVector2D& p4, const KRColor& color);

    /*!
        @method fillQuad
     */
    static void fillQuad(const KRVector2D& p1, const KRVector2D& p2, const KRVector2D& p3, const KRVector2D& p4,
                         const KRColor& c1, const KRColor& c2, const KRColor& c3, const KRColor& c4);
    
};

