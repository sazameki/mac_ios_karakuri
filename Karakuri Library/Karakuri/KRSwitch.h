/*!
    @file   KRSwitch.h
    @author numata
    @date   09/08/28
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/KRControl.h>
#include <Karakuri/KRTexture2D.h>


/*!
    @class KRSwitch
    @group Game Controls
 */
class KRSwitch : public KRControl {
    
protected:
    bool    mIsOn;

    std::string     mBackTextureName;
    KRTexture2D     *mBackTexture;

    std::string     mThumbTextureName;
    KRTexture2D     *mThumbTexture;

    float           mTextureEdgeSize;
    float           mTextureThumbX;
    
public:
	KRSwitch(const KRRect2D& frame);
	virtual ~KRSwitch();
    
public:
    virtual bool    update(KRInput *input);
    virtual void    draw(KRGraphics *g);

public:
    bool    isOn() const;
    void    setOn(bool flag);
    
    void    setTextureNames(const std::string& backName, float edgeSize, const std::string& thumbName, float thumbX);

};

