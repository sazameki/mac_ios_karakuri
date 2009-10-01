/*!
    @file   KRSwitch.cpp
    @author numata
    @date   09/08/28
 */

#include "KRSwitch.h"
#include "KRPrimitive2D.h"


/*!
    @method KRSwitch
    Constructor
 */
KRSwitch::KRSwitch(const KRRect2D& frame)
    : KRControl(frame), mIsOn(true)
{
    mBackTextureName = "";
    mBackTexture = NULL;
    
    mThumbTextureName = "";
    mThumbTexture = NULL;
}

/*!
    @method ~KRSwitch
    Destructor
 */
KRSwitch::~KRSwitch()
{
    if (mBackTexture != NULL) {
        delete mBackTexture;
    }
}


#pragma mark -
#pragma mark Control Implementation

bool KRSwitch::update(KRInput *input)
{
    if (!mSelected) {
        mSelected = true;
        mIsOn = !mIsOn;
        mWorld->switchStateChanged(this);
        return true;
    } else {
#if KR_MACOSX
        bool inputOn = (input->getMouseState() & KRInput::MouseButtonAny)? true: false;
#endif
#if KR_IPHONE
        bool inputOn = input->getTouch();
#endif
        
        if (!inputOn) {
            mSelected = false;
            return false;
        } else {
            return true;
        }
    }
}

void KRSwitch::draw(KRGraphics *g)
{
    if (mBackTexture == NULL && mBackTextureName.length() > 0 && mThumbTextureName.length() > 0) {
        mBackTexture = new KRTexture2D(mBackTextureName);
        mThumbTexture = new KRTexture2D(mThumbTextureName);
    }
    
    if (mBackTexture != NULL) {
        double indicatorWidth = mFrame.width - mTextureEdgeSize * 2;
        double indicatorX = (mIsOn? 0.0: mTextureThumbX) + mTextureEdgeSize;
        
        // Indicator
        mBackTexture->draw(KRRect2D(mFrame.x+mTextureEdgeSize, mFrame.y, indicatorWidth, mBackTexture->getHeight()),
                           KRRect2D(indicatorX, 0, indicatorWidth, mBackTexture->getHeight()));
        
        // Left Edge
        mBackTexture->draw(KRVector2D(mFrame.x, mFrame.y), KRRect2D(0, 0, mTextureEdgeSize, mFrame.height));

        // Right Edge
        mBackTexture->draw(KRVector2D(mFrame.x+mFrame.width-mTextureEdgeSize, mFrame.y),
                       KRRect2D(mBackTexture->getWidth()-mTextureEdgeSize, 0, mTextureEdgeSize, mFrame.height));

        // Thumb
        mThumbTexture->draw((mIsOn? mFrame.x+mTextureThumbX:mFrame.x), mFrame.y);
    } else {
        if (mSelected) {
            KRPrimitive2D::fillQuad(mFrame, KRColor::Red);
        } else {
            KRPrimitive2D::fillQuad(mFrame, KRColor::Blue);
        }
    }
}


#pragma mark -
#pragma mark Switch Implementation

bool KRSwitch::isOn() const
{
    return mIsOn;
}

void KRSwitch::setOn(bool flag)
{
    mIsOn = flag;
}

void KRSwitch::setTextureNames(const std::string& backName, double edgeSize, const std::string& thumbName, double thumbX)
{
    mBackTextureName = backName;
    mTextureEdgeSize = edgeSize;

    mThumbTextureName = thumbName;
    mTextureThumbX = thumbX;
}


