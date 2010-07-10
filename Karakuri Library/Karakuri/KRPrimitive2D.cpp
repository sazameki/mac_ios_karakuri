/*!
    @file   KRPrimitive2D.cpp
    @author numata
    @date   09/07/31
 */

#include "KRPrimitive2D.h"


void KRPrimitive2D::drawLine(const KRVector2D& p1, const KRVector2D& p2, const KRColor& color, double width)
{
    drawLine(p1, p2, color, color, width);
}

void KRPrimitive2D::drawLine(const KRVector2D& p1, const KRVector2D& p2, const KRColor& c1, const KRColor& c2, double width)
{
    _KRTexture2D::processBatchedTexture2DDraws();

    if (_KRTexture2DEnabled) {
        _KRTexture2DEnabled = false;
        glDisable(GL_TEXTURE_2D);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    }
    
    GLshort vertices[] = {
        p1.x,   p1.y,
        p2.x,   p2.y,
    };
    
    GLfloat colors[] = {
        c1.r, c1.g, c1.b, c1.a,
        c2.r, c2.g, c2.b, c2.a,
    };
        
    glVertexPointer(2, GL_SHORT, 0, vertices);
    glColorPointer(4, GL_FLOAT, 0, colors);

    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);

    glLineWidth(width);
	glDrawArrays(GL_LINES, 0, 2);
}

void KRPrimitive2D::fillQuad(const KRRect2D& rect, const KRColor& color)
{
    fillQuad(rect, color, color, color, color);
}

void KRPrimitive2D::fillQuad(const KRRect2D& rect, const KRColor& c1, const KRColor& c2, const KRColor& c3, const KRColor& c4)
{
    float x1 = rect.x;
    float x2 = rect.x + rect.width;
    float y1 = rect.y;
    float y2 = rect.y + rect.height;
    fillQuad(KRVector2D(x1, y1), KRVector2D(x2, y1), KRVector2D(x2, y2), KRVector2D(x1, y2),
             c1, c2, c3, c4);
}

void KRPrimitive2D::fillQuad(const KRVector2D& p1, const KRVector2D& p2, const KRVector2D& p3, const KRVector2D& p4, const KRColor& color)
{
    fillQuad(p1, p2, p3, p4, color, color, color, color);
}

void KRPrimitive2D::fillQuad(const KRVector2D& p1, const KRVector2D& p2, const KRVector2D& p3, const KRVector2D& p4,
                     const KRColor& c1, const KRColor& c2, const KRColor& c3, const KRColor& c4)
{
    _KRTexture2D::processBatchedTexture2DDraws();

    if (_KRTexture2DEnabled) {
        _KRTexture2DEnabled = false;
        glDisable(GL_TEXTURE_2D);
    }
    
    GLshort vertices[] = {
        p1.x,   p1.y,
        p2.x,   p2.y,
        p3.x,   p3.y,
        p1.x,   p1.y,
        p3.x,   p3.y,
        p4.x,   p4.y,
    };
    
    GLfloat colors[] = {
        (GLfloat)c1.r, (GLfloat)c1.g, (GLfloat)c1.b, (GLfloat)c1.a,
        (GLfloat)c2.r, (GLfloat)c2.g, (GLfloat)c2.b, (GLfloat)c2.a,
        (GLfloat)c3.r, (GLfloat)c3.g, (GLfloat)c3.b, (GLfloat)c3.a,
        (GLfloat)c1.r, (GLfloat)c1.g, (GLfloat)c1.b, (GLfloat)c1.a,
        (GLfloat)c3.r, (GLfloat)c3.g, (GLfloat)c3.b, (GLfloat)c3.a,
        (GLfloat)c4.r, (GLfloat)c4.g, (GLfloat)c4.b, (GLfloat)c4.a,
    };
    
    glVertexPointer(2, GL_SHORT, 0, vertices);
    glColorPointer(4, GL_FLOAT, 0, colors);

    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);

	glDrawArrays(GL_TRIANGLES, 0, 6);
}




