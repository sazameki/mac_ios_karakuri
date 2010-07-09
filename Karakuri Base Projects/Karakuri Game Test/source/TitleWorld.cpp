/*!
    @file   TitleWorld.cpp
    @author numata
    @date   10/02/13
 */

#include "TitleWorld.h"
#include "Globals.h"


void TitleWorld::becameActive()
{
    //gKRAudioMan->playBGM(gBGM_Title, 0.5);
    //gKRAudioMan->setSEListenerPos(KRVector3D(0, 0, 0));
}

void TitleWorld::resignedActive()
{
    gKRAudioMan->unloadAudioFiles(0);
}

void TitleWorld::updateModel(KRInput* input)
{
    bool hasTouched = false;
    
#if KR_MACOSX
    if (input->isMouseDown()) {
        hasTouched = true;
    }
#endif
    
#if KR_IPHONE
    if (input->getTouch()) {
        hasTouched = true;
    }    
#endif
    
    if (hasTouched) {
        gKRGameMan->changeWorld("play");
    }
}

void TitleWorld::drawView(KRGraphics* g)
{
    g->clear(KRColor::GreenYellow);
    
    gKRTex2DMan->drawAtPoint(TexID::Title, KRVector2D(0, 0));

    gKRAnime2DMan->draw();
}


