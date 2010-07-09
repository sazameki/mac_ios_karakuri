/*!
    @file   LoadingWorld.cpp
    @author numata
    @date   10/02/13
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
    
    gKRTex2DMan->drawAtPointCenter(TexID::LoadingChara, KRVector2D(progress*gKRScreenSize.x, 100));
}


