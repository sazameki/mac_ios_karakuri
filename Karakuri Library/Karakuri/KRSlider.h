/*!
    @file   KRSlider.h
    @author numata
    @date   09/08/28
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/KRControl.h>
#include <Karakuri/KRTexture2D.h>


/*!
    @class KRSlider
    @group Game Controls
 */
class KRSlider : public KRControl {

protected:
    float   mMaxValue;
    float   mMinValue;
    float   mValue;
    
    std::string     mThumbTextureName;
    KRTexture2D     *mThumbTexture;

    std::string     mBackTextureName;
    KRTexture2D     *mBackTexture;
    float           mBackTextureEdgeSize;

public:
	KRSlider(const KRRect2D& frame);
	virtual ~KRSlider();

public:
    virtual bool    update(KRInput *input);
    virtual void    draw(KRGraphics *g);
    
public:
    float   getMaxValue() const;
    float   getMinValue() const;
    float   getValue() const;

    void    setMaxValue(float value);
    void    setMinValue(float value);
    void    setValue(float value);
    
    void    setTextureNames(const std::string& backName, float edgeSize, const std::string& thumbName);

};

