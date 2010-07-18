/*!
    @file   KRSlider.cpp
    @author numata
    @date   09/08/28
 */

#include "KRSlider.h"
#include "KRPrimitive2D.h"


/*!
    @method KRSlider
    Constructor
 */
KRSlider::KRSlider(const KRRect2D& frame)
    : KRControl(frame), mValue(0.0), mMinValue(0.0), mMaxValue(1.0)
{
    mThumbTexture = NULL;
    mThumbTextureName = "";
    
    mBackTexture = NULL;
    mBackTextureName = "";
}

/*!
    @method ~KRSlider
    Destructor
 */
KRSlider::~KRSlider()
{
    if (mThumbTexture != NULL) {
        delete mThumbTexture;
    }
    if (mBackTexture != NULL) {
        delete mBackTexture;
    }
}

#pragma mark -
#pragma mark Control Implementation

bool KRSlider::update(KRInput *input)
{
    if (!mIsEnabled) {
        return false;
    }
    
    if (!mIsSelected) {
        mIsSelected = true;
        return true;
    } else {
#if KR_MACOSX
        bool inputOn = input->isMouseDown();
#endif
#if KR_IPHONE
        bool inputOn = input->getTouch();
#endif
        
        if (!inputOn) {
            mIsSelected = false;
            return false;
        } else {
#if KR_MACOSX
            KRVector2D pos = input->getMouseLocation();
#endif
#if KR_IPHONE
            KRVector2D pos = input->getTouchLocation();
#endif
            double thumbWidth = 20.0;

            double value = (pos.x - mFrame.x - thumbWidth/2) / (mFrame.width - thumbWidth);
            if (value < mMinValue) {
                value = mMinValue;
            } else if (value > mMaxValue) {
                value = mMaxValue;
            }
            if (mValue != value) {
                mValue = value;
                mWorld->sliderValueChanged(this);
            }
            return true;
        }
    }        
}

void KRSlider::draw(KRGraphics *g)
{
    if (mThumbTexture == NULL && mThumbTextureName.length() > 0) {
        mThumbTexture = new _KRTexture2D(mThumbTextureName);
    }
    
    if (mBackTexture == NULL && mBackTextureName.length() > 0) {
        mBackTexture = new _KRTexture2D(mBackTextureName);
    }
    
    double alpha = (mIsEnabled? 1.0: _gKRControlDisabledAlpha);
    
    double thumbWidth = 20.0;

    if (mThumbTexture != NULL) {
        thumbWidth = mThumbTexture->getWidth();
    }
    
    double centerX = mFrame.x + (mFrame.width - thumbWidth) * (mValue / (mMaxValue - mMinValue)) + thumbWidth/2;
    
    if (mBackTexture != NULL) {
        KRColor drawColor(1.0, 1.0, 1.0, alpha);
        
        // Left Edge
        mBackTexture->drawAtPointEx_(KRVector2D(mFrame.x, mFrame.y), KRRect2D(0, 0, mBackTextureEdgeSize, mFrame.height),
                                     0.0, KRVector2DZero, KRVector2DOne, drawColor);
        
        // Left Background
        mBackTexture->drawInRect_(KRRect2D(mFrame.x+mBackTextureEdgeSize, mFrame.y, (centerX-(mFrame.x+mBackTextureEdgeSize)), mFrame.height),
                                  KRRect2D(mBackTexture->getWidth()/2-1, 0, 1, mFrame.height), drawColor);
        
        // Right Background
        mBackTexture->drawInRect_(KRRect2D(centerX, mFrame.y, mFrame.x+mFrame.width-centerX-mBackTextureEdgeSize, mFrame.height),
                                  KRRect2D(mBackTexture->getWidth()/2, 0, 1, mFrame.height), drawColor);
        
        // Right Edge
        mBackTexture->drawAtPointEx_(KRVector2D(mFrame.x+mFrame.width-mBackTextureEdgeSize, mFrame.y),
                                     KRRect2D(mBackTexture->getWidth()-mBackTextureEdgeSize, 0, mBackTextureEdgeSize, mFrame.height),
                                     0.0, KRVector2DZero, KRVector2DOne, drawColor);
    } else {
        KRColor drawColor = (mIsSelected? KRColor::Red: KRColor::Blue);
        drawColor.a = alpha;
        KRPrimitive2D::fillQuad(mFrame, drawColor);
    }
    
    if (mThumbTexture != NULL) {
        mThumbTexture->drawAtPoint_(KRVector2D(centerX-thumbWidth/2, mFrame.y), KRColor(1.0, 1.0, 1.0, alpha));
    } else {
        KRColor drawColor = KRColor::Yellow;
        if (!mIsEnabled) {
            drawColor.a = alpha;
        }
        KRPrimitive2D::fillQuad(KRRect2D(centerX-thumbWidth/2, mFrame.y, thumbWidth, mFrame.height), drawColor);
    }
}


#pragma mark -
#pragma mark Slider Implementation

double KRSlider::getMaxValue() const
{
    return mMaxValue;
}

double KRSlider::getMinValue() const
{
    return mMinValue;
}

double KRSlider::getValue() const
{
    return mValue;
}

void KRSlider::setMaxValue(double value)
{
    mMaxValue = value;
}

void KRSlider::setMinValue(double value)
{
    mMinValue = value;
}

void KRSlider::setValue(double value)
{
    mValue = value;
}

void KRSlider::setTextureNames(const std::string& backName, double edgeSize, const std::string& thumbName)
{
    mBackTextureName = backName;
    mBackTextureEdgeSize = edgeSize;

    mThumbTextureName = thumbName;
}


