/*!
    @file   KRTexture2DAtlas.h
    @author numata
    @date   09/07/29
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/Karakuri.h>


/*!
    @class KRTexture2DAtlas
    @group Game 2D Graphics
 */
class KRTexture2DAtlas : public KRObject {
    
    KRTexture2D     *mTexture;
    KRVector2D      mLeftBottomPos;
    KRVector2D      mOneSize;
    KRVector2D      mCenterPos;

public:
	KRTexture2DAtlas(KRTexture2D *tex, const KRVector2D& leftBottomPos, const KRVector2D& oneSize);
	virtual ~KRTexture2DAtlas();
    
public:
    KRVector2D  getLeftBottomPos() const;
    KRVector2D  getOneSize() const;
    KRVector2D  getCenterPos() const;
    
public:
    void    draw(int row, int column, const KRVector2D& pos, float alpha = 1.0f);
    void    draw(int row, int column, const KRRect2D& rect, float alpha = 1.0f);
    void    draw(int row, int column, const KRVector2D& centerPos, float rotation, const KRVector2D& origin, float scale=1.0f, float alpha=1.0f);
    void    draw(int row, int column, const KRVector2D& centerPos, float rotation, const KRVector2D& origin, const KRVector2D &scale, float alpha = 1.0f);

    void    draw(int row, int column, const KRVector2D& pos, const KRColor& color);
    void    draw(int row, int column, const KRRect2D& rect, const KRColor& color);
    void    draw(int row, int column, const KRVector2D& centerPos, float rotation, const KRVector2D& origin, float scale, const KRColor& color);
    void    draw(int row, int column, const KRVector2D& centerPos, float rotation, const KRVector2D& origin, const KRVector2D &scale, const KRColor& color);
    
public:
    virtual std::string to_s() const;

};

