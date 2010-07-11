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
    unloadResourceGroup(GroupID::Title);
}

void TitleWorld::updateModel(KRInput* input)
{
    bool isTouched = false;
    KRVector2D touchPos;
    
#if KR_MACOSX
    if (input->isMouseDown()) {
        isTouched = true;
        touchPos = input->getMouseLocation();
    }
#endif
    
#if KR_IPHONE
    if (input->getTouch()) {
        isTouched = true;
        touchPos = input->getTouchLocation();
    }
#endif
    
    if (isTouched) {
        //gKRGameMan->changeWorld("play");
        gKRAnime2DMan->generateParticle2D(ParticleID::Particle1, touchPos);
    }    
}

void TitleWorld::drawView(KRGraphics* g)
{
    g->clear(KRColor::GreenYellow);
    
    gKRTex2DMan->drawAtPoint(TexID::Title, KRVector2D(0, 0));
    //gKRTex2DMan->drawAtPointEx(TexID::TitleChara, KRVector2D(100, 0), 0.0, KRVector2DZero, KRVector2D(2.0, 2.0), 1.0);
    gKRTex2DMan->drawAtPointCenter(TexID::TitleChara, gKRScreenSize/2);

    gKRAnime2DMan->draw();
}


