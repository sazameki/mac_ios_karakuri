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

void KRControl::setHidden(bool flag)
{
    mIsHidden = flag;
}

void KRControl::setWorld(KRWorld *aWorld)
{
    mWorld = aWorld;
}


