/*!
    @file   KRControl.cpp
    @author numata
    @date   09/08/28
 */

#include "KRControl.h"


/*!
    @method KRControl
    Constructor
 */
KRControl::KRControl(const KRRect2D& frame)
    : mWorld(NULL), mFrame(frame), mEnabled(true), mSelected(false)
{
}

/*!
    @method ~KRControl
    Destructor
 */
KRControl::~KRControl()
{
}

bool KRControl::contains(const KRVector2D& pos)
{
    return mFrame.contains(pos);
}

void KRControl::setWorld(KRWorld *aWorld)
{
    mWorld = aWorld;
}


