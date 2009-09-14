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
    <p>単純図形の描画をサポートするためのクラスです。</p>
    <p>このクラスはインスタンスをもちません。インスタンスの生成は禁止されています。</p>
 */
class KRPrimitive2D {

private:
	KRPrimitive2D() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
	virtual ~KRPrimitive2D() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    
public:
    
#pragma mark ---- 線 ----
    /*!
        @task 線の描画
     */
    
    /*!
        @method drawLine
        始点から終点まで、指定された色で線分を描画します。
     */
    static void drawLine(const KRVector2D& p1, const KRVector2D& p2, const KRColor& color, float width = 1.0f);

    /*!
        @method drawLine
        始点から終点まで、指定された2色の色で線分を描画します。
     */
    static void drawLine(const KRVector2D& p1, const KRVector2D& p2, const KRColor& c1, const KRColor& c2, float width = 1.0f);    
    
#pragma mark ---- 四角形 ----
    /*!
        @task 四角形の描画
     */

    /*!
        @method fillQuad
        指定された矩形を、指定された色で塗り潰します。
     */
    static void fillQuad(const KRRect2D& rect, const KRColor& color);

    /*!
        @method fillQuad
        指定された矩形を、指定された4色の色で塗り潰します。
     */
    static void fillQuad(const KRRect2D& rect, const KRColor& c1, const KRColor& c2, const KRColor& c3, const KRColor& c4);

    /*!
        @method fillQuad
        指定された4点を結んでできる四角形を、指定された色で塗り潰します。
     */
    static void fillQuad(const KRVector2D& p1, const KRVector2D& p2, const KRVector2D& p3, const KRVector2D& p4, const KRColor& color);

    /*!
        @method fillQuad
        指定された4点を結んでできる四角形を、指定された4色の色で塗り潰します。
     */
    static void fillQuad(const KRVector2D& p1, const KRVector2D& p2, const KRVector2D& p3, const KRVector2D& p4,
                         const KRColor& c1, const KRColor& c2, const KRColor& c3, const KRColor& c4);
    
};

