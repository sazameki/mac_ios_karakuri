/*!
    @file   KRLabel.cpp
    @author numata
    @date   09/08/29
 */

#include "KRLabel.h"


/*!
    @method KRLabel
    Constructor
 */
KRLabel::KRLabel(const KRRect2D& frame)
    : KRControl(frame)
{
    mHasChangedText = false;
    
    mText = "";
    mTextTexture = NULL;
    
    mFont = new KRFont("Helvetica-Bold", 20);
    
    mTextColor = KRColor::Black;

    mTextAlignment = KRTextAlignmentCenter;
}

/*!
    @method ~KRLabel
    Destructor
 */
KRLabel::~KRLabel()
{
    if (mTextTexture != NULL) {
        delete mTextTexture;
        mTextTexture = NULL;
    }
    
    delete mFont;
}

bool KRLabel::update(KRInput *input)
{
    return false;
}

void KRLabel::draw(KRGraphics *g)
{
    if (mText.length() == 0) {
        return;
    }

    if (mTextTexture == NULL || mHasChangedText) {
        if (mTextTexture != NULL) {
            delete mTextTexture;
        }
        mTextTexture = mFont->createStringTexture(mText);
        mHasChangedText = false;
    }
    if (mTextTexture != NULL) {
        double drawX = mFrame.x;
        if (mTextAlignment == KRTextAlignmentCenter) {
            drawX = mFrame.x + mFrame.width/2 - mTextTexture->getWidth()/2;
        } else if (mTextAlignment == KRTextAlignmentRight) {
            drawX = mFrame.x + mFrame.width - mTextTexture->getWidth();
        }
        mTextTexture->draw(drawX,
                           mFrame.y + mFrame.height/2 - mTextTexture->getHeight()/2,
                           mTextColor);
    }
}

std::string KRLabel::getText() const
{
    return mText;
}

void KRLabel::setFont(const std::string& fontName, double size)
{
    delete mFont;
    mFont = new KRFont(fontName, size);
    mHasChangedText = true;
}

void KRLabel::setText(const std::string& text)
{
    if (mText == text) {
        return;
    }
    mText = text;
    mHasChangedText = true;
}

KRTextAlignment KRLabel::getTextAlignment() const
{
    return mTextAlignment;
}

void KRLabel::setTextAlignment(KRTextAlignment alignment)
{
    if (mTextAlignment == alignment) {
        return;
    }
    mTextAlignment = alignment;
}

void KRLabel::setTextColor(const KRColor& color)
{
    if (mTextColor == color) {
        return;
    }
    mTextColor = color;
}



