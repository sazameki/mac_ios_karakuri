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
    if (!mIsEnabled) {
        return false;
    }
    
    if (!mIsSelected) {
        mIsSelected = true;
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
            mIsSelected = false;
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
    
    double alpha = (mIsEnabled? 1.0: _gKRControlDisabledAlpha);

    if (mBackTexture != NULL) {
        double indicatorWidth = mFrame.width - mTextureEdgeSize * 2;
        double indicatorX = (mIsOn? 0.0: mTextureThumbX) + mTextureEdgeSize;        
        
        // Indicator
        mBackTexture->drawInRect(KRRect2D(mFrame.x+mTextureEdgeSize, mFrame.y, indicatorWidth, mBackTexture->getHeight()),
                                 KRRect2D(indicatorX, 0, indicatorWidth, mBackTexture->getHeight()), alpha);
        
        // Left Edge
        mBackTexture->drawAtPoint(KRVector2D(mFrame.x, mFrame.y), KRRect2D(0, 0, mTextureEdgeSize, mFrame.height), alpha);

        // Right Edge
        mBackTexture->drawAtPoint(KRVector2D(mFrame.x+mFrame.width-mTextureEdgeSize, mFrame.y),
                                  KRRect2D(mBackTexture->getWidth()-mTextureEdgeSize, 0, mTextureEdgeSize, mFrame.height), alpha);

        // Thumb
        mThumbTexture->drawAtPoint((mIsOn? mFrame.x+mTextureThumbX:mFrame.x), mFrame.y, alpha);
    } else {
        KRColor drawColor = (mIsOn? KRColor::Blue: KRColor::Red);
        drawColor.a = alpha;
        KRPrimitive2D::fillQuad(mFrame, drawColor);
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


