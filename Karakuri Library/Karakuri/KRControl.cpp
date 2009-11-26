/*!
    @file   KRControl.cpp
    @author numata
    @date   09/08/28
 */

#include "KRControl.h"


KRControl::KRControl(const KRRect2D& frame)
    : mWorld(NULL), mFrame(frame), mIsEnabled(true), mIsSelected(false), mIsHidden(false)
{
}

KRControl::~KRControl()
{
}

bool KRControl::contains(const KRVector2D& pos)
{
    if (mIsHidden || !mIsEnabled) {
        return false;
    }
    return mFrame.contains(pos);
}

KRRect2D KRControl::getFrame() const
{
    return mFrame;
}

bool KRControl::isEnabled() const
{
    return mIsEnabled;
}

bool KRControl::isHidden() const
{
    return mIsHidden;
}

void KRControl::setEnabled(bool flag)
{
    mIsEnabled = flag;
}

void KRControl::setFrame(const KRRect2D& rect)
{
    mFrame = rect;
}

void KRControl::setFrameOrigin(const KRVector2D& pos)
{
    mFrame.x = pos.x;
    mFrame.y = pos.y;
}

void KRControl::setFrameSize(const KRVector2D& size)
{
    mFrame.width  = size.x;
    mFrame.height  = size.y;
}

void KRControl::setHidden(bool flag)
{
    mIsHidden = flag;
}

void KRControl::setWorld(KRWorld *aWorld)
{
    mWorld = aWorld;
}


