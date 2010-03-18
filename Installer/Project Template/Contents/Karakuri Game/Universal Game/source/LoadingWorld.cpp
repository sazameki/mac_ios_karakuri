/*!
    @file   LoadingWorld.cpp
    @author ___FULLUSERNAME___
    @date   ___DATE___
 */

#include "LoadingWorld.h"
#include "Globals.h"


void LoadingWorld::becameActive()
{
    mDirection = 1;
}

void LoadingWorld::resignedActive()
{
    // Do nothing
}

void LoadingWorld::updateModel(KRInput* input)
{
    mCount += mDirection;
    if (mCount == 60 || mCount == 0) {
        mDirection *= -1;
    }
}

void LoadingWorld::drawView(KRGraphics* g)
{
    double progress = getLoadingProgress();
    
    g->clear(KRColor(1.0, 0, 0, 1));
    
    gKRTex2DMan->drawAtPointCenter(gTex_LoadingChara, KRVector2D(progress*gKRScreenSize.x, 100));
}


