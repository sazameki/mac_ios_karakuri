/*!
    @file   LogoWorld.cpp
    @author ___FULLUSERNAME___
    @date   ___DATE___
 */

#include "LogoWorld.h"


/*
std::string LogoWorld::getLoadingScreenWorldName() const
{
    return "";
}
*/

void LogoWorld::becameActive()
{
    mCount = 120;

#if KR_MACOSX
    mCount += 100;
#endif
    
    mTex = new KRTexture2D("Default.png");
}

void LogoWorld::resignedActive()
{
    delete mTex;
}

void LogoWorld::updateModel(KRInput *input)
{
    mCount--;
    if (mCount == 0) {
        KRGame->changeWorld("play");
    }
}

void LogoWorld::drawView(KRGraphics *g)
{
    g->clear(KRColor::White);
    
    float alpha = (float)mCount / 100;
    if (alpha > 1.0f) {
        alpha = 1.0f;
    }
    float angle = 0.0f;
    if (KRScreenSize.x > KRScreenSize.y) {
        angle = M_PI / 2;
    }
    mTex->draw(KRScreenSize/2, KRRect2DZero, angle, mTex->getCenterPos(), 1.0f, alpha);
}


