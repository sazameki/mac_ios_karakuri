/*!
    @file   KRButton.cpp
    @author numata
    @date   09/08/28
 */

#include "KRButton.h"
#include "KRPrimitive2D.h"


/*!
    @method KRButton
    Constructor
 */
KRButton::KRButton(const KRRect2D& frame)
    : KRControl(frame)
{
    mLabel = new KRLabel(frame);
    mLabel->setTextAlignment(KRTextAlignmentCenter);
    
    mTitleColorNormal = KRColor(0x324f85);
    mTitleColorHighlighted = KRColor::White;
    
    mTextureNameNormal = "";
    mTextureNameHighlighted = "";
    
    mTextureNormal = NULL;
    mTextureHighlighted = NULL;
}

/*!
    @method ~KRButton
    Destructor
 */
KRButton::~KRButton()
{
    if (mTextureNormal != NULL) {
        delete mTextureNormal;
        mTextureNormal = NULL;
    }

    if (mTextureHighlighted != NULL) {
        delete mTextureHighlighted;
        mTextureHighlighted = NULL;
    }
    
    delete mLabel;
}


#pragma mark -
#pragma mark Control Implementation

bool KRButton::update(KRInput *input)
{
    if (!mSelected) {
        mSelected = true;
        return true;
    } else {
#if KR_MACOSX
        bool inputOn = (input->getMouseState() & KRInput::MouseButtonAny)? true: false;
#endif
#if KR_IPHONE
        bool inputOn = input->getTouch();
#endif
        if (!inputOn) {
            mWorld->buttonPressed(this);
            mSelected = false;
            return false;
        }
        return true;
    }
}

void KRButton::draw(KRGraphics *g)
{
    if (mTextureNormal == NULL && mTextureNameNormal.length() > 0 && mTextureNameHighlighted.length() > 0) {
        mTextureNormal = new KRTexture2D(mTextureNameNormal);
        mTextureHighlighted = new KRTexture2D(mTextureNameHighlighted);
    }

    if (mTextureNormal == NULL) {
        if (mSelected) {
            KRPrimitive2D::fillQuad(mFrame, KRColor::Red);
        } else {
            KRPrimitive2D::fillQuad(mFrame, KRColor::Blue);
        }
    } else {
        KRTexture2D *tex = mSelected? mTextureHighlighted: mTextureNormal;
        
        // Body
        tex->drawInRect(KRRect2D(mFrame.x+mTextureEdgeSize, mFrame.y, mFrame.width-mTextureEdgeSize*2, mFrame.height), KRRect2D(mTextureEdgeSize, 0, 1, tex->getHeight()));
        
        // Left Edge
        tex->drawAtPoint(KRVector2D(mFrame.x, mFrame.y), KRRect2D(0, 0, mTextureEdgeSize, tex->getHeight()));

        // Right Edge
        tex->drawAtPoint(KRVector2D(mFrame.x+mFrame.width-mTextureEdgeSize, mFrame.y), KRRect2D(tex->getWidth()-mTextureEdgeSize, 0, mTextureEdgeSize, tex->getHeight()));
    }
    
    if (mSelected) {
        mLabel->setTextColor(mTitleColorHighlighted);
    } else {
        mLabel->setTextColor(mTitleColorNormal);
    }
    mLabel->draw(g);
}


#pragma mark -
#pragma mark Text Implementation

std::string KRButton::getTitle() const
{
    return mLabel->getText();
}

void KRButton::setTitle(const std::string& text)
{
    mLabel->setText(text);
}

void KRButton::setTextureNames(const std::string& normalName, const std::string& highlightedName, double textureEdgeSize)
{
    mTextureNameNormal = normalName;
    mTextureNameHighlighted = highlightedName;
    mTextureEdgeSize = textureEdgeSize;
}

void KRButton::setTitleColors(const KRColor& normalColor, const KRColor& hilightedColor)
{
    mTitleColorNormal = normalColor;
    mTitleColorHighlighted = hilightedColor;
}





