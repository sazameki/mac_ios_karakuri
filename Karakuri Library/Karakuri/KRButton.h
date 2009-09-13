/*!
    @file   KRButton.h
    @author numata
    @date   09/08/28
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/KRControl.h>
#include <Karakuri/KRLabel.h>


/*!
    @class KRButton
    @group Game Controls
 */
class KRButton : public KRControl {

protected:
    KRLabel     *mLabel;

    KRColor     mTitleColorNormal;
    KRColor     mTitleColorHighlighted;
    
    std::string mTextureNameNormal;
    KRTexture2D *mTextureNormal;
    
    std::string mTextureNameHighlighted;
    KRTexture2D *mTextureHighlighted;
    
    float       mTextureEdgeSize;

public:
	KRButton(const KRRect2D& frame);
	virtual ~KRButton();

public:
    virtual bool    update(KRInput *input);
    virtual void    draw(KRGraphics *g);
    
public:
    std::string getTitle() const;
    void        setTitle(const std::string& text);
    
    void        setTextureNames(const std::string& normalName, const std::string& highlightedName, float textureEdgeSize);
    void        setTitleColors(const KRColor& normalColor, const KRColor& hilightedColor);
    
};

