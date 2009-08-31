/*!
    @file   KRTexture2DAtlas.cpp
    @author numata
    @date   09/07/29
 */

#include "KRTexture2DAtlas.h"


/*!
    @method KRTexture2DAtlas
    Constructor
 */
KRTexture2DAtlas::KRTexture2DAtlas(KRTexture2D *tex, const KRVector2D& leftBottomPos, const KRVector2D& oneSize)
{
    mTexture = tex;
    mLeftBottomPos = leftBottomPos;
    mOneSize = oneSize;
    
    mCenterPos = mOneSize / 2;
}

/*!
    @method ~KRTexture2DAtlas
    Destructor
 */
KRTexture2DAtlas::~KRTexture2DAtlas()
{
}

KRVector2D KRTexture2DAtlas::getLeftBottomPos() const
{
    return mLeftBottomPos;
}

KRVector2D KRTexture2DAtlas::getOneSize() const
{
    return mOneSize;
}

KRVector2D KRTexture2DAtlas::getCenterPos() const
{
    return mCenterPos;
}


void KRTexture2DAtlas::draw(int row, int column, const KRVector2D& pos, float alpha)
{
    draw(row, column, pos, 0.0f, KRVector2DZero, KRVector2DOne, alpha);
}

void KRTexture2DAtlas::draw(int row, int column, const KRRect2D& rect, float alpha)
{
    KRVector2D scale(rect.width / mOneSize.x, rect.height / mOneSize.y);
    draw(row, column, rect.getOrigin(), 0.0f, KRVector2DZero, scale, alpha);
}

void KRTexture2DAtlas::draw(int row, int column, const KRVector2D& centerPos, float rotation, const KRVector2D& origin, float scale, float alpha)
{
    draw(row, column, centerPos, rotation, origin, KRVector2D(scale, scale), alpha);
}

void KRTexture2DAtlas::draw(int row, int column, const KRVector2D& centerPos, float rotation, const KRVector2D& origin, const KRVector2D &scale, float alpha)
{
    KRRect2D srcRect(mLeftBottomPos.x + mOneSize.x * column, mLeftBottomPos.y + mOneSize.y * row, mOneSize.x, mOneSize.y);
    mTexture->draw(centerPos, srcRect, rotation, origin, scale, alpha);
}

void KRTexture2DAtlas::draw(int row, int column, const KRVector2D& pos, const KRColor& color)
{
    draw(row, column, pos, 0.0f, KRVector2DZero, KRVector2DOne, color);
}

void KRTexture2DAtlas::draw(int row, int column, const KRRect2D& rect, const KRColor& color)
{
    KRVector2D scale(rect.width / mOneSize.x, rect.height / mOneSize.y);
    draw(row, column, rect.getOrigin(), 0.0f, KRVector2DZero, scale, color);
}

void KRTexture2DAtlas::draw(int row, int column, const KRVector2D& centerPos, float rotation, const KRVector2D& origin, float scale, const KRColor& color)
{
    draw(row, column, centerPos, rotation, origin, KRVector2D(scale, scale), color);
}

void KRTexture2DAtlas::draw(int row, int column, const KRVector2D& centerPos, float rotation, const KRVector2D& origin, const KRVector2D &scale, const KRColor& color)
{
    KRRect2D srcRect(mLeftBottomPos.x + mOneSize.x * column, mLeftBottomPos.y + mOneSize.y * row, mOneSize.x, mOneSize.y);
    mTexture->draw(centerPos, srcRect, rotation, origin, scale, color);
}

std::string KRTexture2DAtlas::to_s() const
{
    return KRFS("<tex2_atlas>(left_bottom=(%3.1f,%3.1f), size=(%3.1f,%3.1f), tex=%s)", mLeftBottomPos.x, mLeftBottomPos.y, mOneSize.x, mOneSize.y, mTexture->c_str());
}









