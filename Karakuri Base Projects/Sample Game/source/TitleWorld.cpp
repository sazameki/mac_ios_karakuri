/*!
    @file   TitleWorld.cpp
    @author numata
    @date   10/02/13
 */

#include "TitleWorld.h"
#include "Globals.h"


void TitleWorld::becameActive()
{
    // It is very light weight, so we don't use the loading screen for this resource.
    loadResourceGroup(GroupID::Title);

    // Play BGM for title
    gKRAudioMan->playBGM(BGM_ID::Title);
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
        gKRGameMan->changeWorld("play");
    }    
}

void TitleWorld::drawView(KRGraphics* g)
{
    g->clear(KRColor::GreenYellow);
    
    gKRTex2DMan->drawAtPoint(TexID::Title, KRVector2D(0, 0));

    gKRAnime2DMan->draw();
}


/*void TitleWorld::buttonPressed(KRButton* aButton)
{
}*/

/*void TitleWorld::sliderValueChanged(KRSlider* slider)
{
}*/

/*void TitleWorld::switchStateChanged(KRSwitch* switcher)
{
}*/


