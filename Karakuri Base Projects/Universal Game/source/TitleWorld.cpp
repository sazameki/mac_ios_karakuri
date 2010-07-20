/*!
    @file   TitleWorld.cpp
    @author ___FULLUSERNAME___
    @date   ___DATE___
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
    // Clearing screen should be omitted because the title image fully covers the screen.
    //g->clear(KRColor::GreenYellow);
    
    gKRTex2DMan->drawInRect(TexID::Title, KRRect2D(0, 0, gKRScreenSize.x, gKRScreenSize.y));

    // We don't use animation mechanism at the title world.
    //gKRAnime2DMan->draw();
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


