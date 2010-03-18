/*!
    @file   PlayWorld.cpp
    @author numata
    @date   10/02/13
 */

#include "PlayWorld.h"
#include "Globals.h"


void PlayWorld::becameActive()
{
    if (!hasLoadedResourceGroup(2)) {
        startLoadingWorld("load", 2.0);
        loadResourceGroup(2);
        finishLoadingWorld();
    }

    mPlayer = new Player();
    
#if KR_IPHONE
    gKRInputInst->enableAccelerometer(true);
#endif
}

void PlayWorld::resignedActive()
{
    delete mPlayer;
    
#if KR_IPHONE
    gKRInputInst->enableAccelerometer(false);
#endif
}

void PlayWorld::updateModel(KRInput* input)
{
    mPlayer->move(input);
}

void PlayWorld::drawView(KRGraphics* g)
{
    g->clear(KRColor::CornflowerBlue);
    
    gKRAnime2DMan->draw();
}


