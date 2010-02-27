/*!
    @file   TitleWorld.cpp
    @author numata
    @date   10/02/13
 */

#include "TitleWorld.h"
#include "Globals.h"


void TitleWorld::becameActive()
{
    if (!hasLoadedResourceGroup(0)) {
//        startLoadingWorld("load");
        loadResourceGroup(0);
//        finishLoadingWorld();
    }

    //gKRAudioMan->playBGM(gBGM_Op, 0.5);
    //gKRAudioMan->setSEListenerPos(KRVector3D(0, 0, 0));
}

void TitleWorld::resignedActive()
{
    gKRAudioMan->unloadAudioFiles(0);
}

void TitleWorld::updateModel(KRInput* input)
{
#if KR_MACOSX
    if (input->isKeyDownOnce(KRInput::KeySpace)) {
        gKRAudioMan->playSE(gSE_Hit);
        gKRGameMan->changeWorld("play");
    }
    
    if (input->isMouseDown()) {
        gKRAudioMan->playSE(gSE_Hit, 0.8);
        gKRAnime2DMan->generateParticles(gParticle1, input->getMouseLocation());
    }
#else
    if (input->getTouchOnce()) {
        gKRAudioMan->playSE(gSE_Hit);
        gKRGameMan->changeWorld("play");
    }    
#endif
}

void TitleWorld::drawView(KRGraphics* g)
{
    g->clear(KRColor::GreenYellow);
    
    //double angle = M_PI_4;
    //gKRTex2DMan->drawAtPoint(gTex_Test, KRVector2D(0, 0), 1.0);
    //gKRTex2DMan->drawAtPointEx(gTex_Test, KRVector2D(0, 0), 0.5, KRVector2D(2, 1.2), 1.0);
    //gKRTex2DMan->drawAtPointCenterEx(gTex_Test, KRVector2D(0, 0), 0.5, KRVector2D(2, 1), 1.0);

    gKRTex2DMan->drawAtPointEx2(gTex_Test, KRVector2D(0, 0), KRRect2D(0, 0, 100, 100), 0.0, KRVector2D(50, 50), KRVector2D(1, 1), 1.0);

    /*
    gKRTex2DMan->drawAtPointEx2(gTex_Test, KRVector2D(100, 100), KRRect2D(0, 0, 100, 100), 0.1, KRVector2D(50, 50), KRVector2D(2, 1), 1.0);
    gKRTex2DMan->drawAtPointEx2(gTex_Test, KRVector2D(100, 100), KRRect2D(0, 0, 100, 100), 0.25, KRVector2D(50, 50), KRVector2D(2, 1), 1.0);
    gKRTex2DMan->drawAtPointEx2(gTex_Test, KRVector2D(100, 100), KRRect2D(0, 0, 100, 100), 0.5, KRVector2D(50, 50), KRVector2D(2, 1), 1.0);
     */
    //gKRTex2DMan->drawAtPointEx2(gTex_Test, KRVector2D(100, 100), KRRect2D(0, 0, 100, 100), 0.5, KRVector2D(2, 1), 1.0);

    gKRTex2DMan->drawInRect(gTex_Test, KRRect2D(100, 100, 300, 300), KRRect2D(0, 0, 200, 200), KRColor(1, 1, 1, 1));
    
    gKRTex2DMan->drawAtPointCenterEx2(gTex_Test, KRVector2D(100, 100), KRRect2D(0, 0, 100, 100), 0.1, KRVector2D(50, 50), KRVector2D(1, 1), 0.2);
    gKRTex2DMan->drawAtPointCenterEx2(gTex_Test, KRVector2D(100, 100), KRRect2D(0, 0, 100, 100), 0.25, KRVector2D(50, 50), KRVector2D(1, 1), 0.2);
    gKRTex2DMan->drawAtPointCenterEx2(gTex_Test, KRVector2D(100, 100), KRRect2D(0, 0, 100, 100), 0.5, KRVector2D(50, 50), KRVector2D(1, 1), 0.2);    
    gKRTex2DMan->drawAtPointCenterEx2(gTex_Test, KRVector2D(100, 100), KRRect2D(0, 0, 100, 100), 0.75, KRVector2D(50, 50), KRVector2D(1, 1), 0.2);
    
    gKRAnime2DMan->draw();
}


