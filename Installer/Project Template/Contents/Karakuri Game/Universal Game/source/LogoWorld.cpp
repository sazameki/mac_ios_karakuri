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
        gKRGameInst->changeWorld("play");
    }
}

void LogoWorld::drawView(KRGraphics *g)
{
    g->clear(KRColor::White);
    
    double alpha = (double)mCount / 100;
    if (alpha > 1.0) {
        alpha = 1.0;
    }
    double angle = 0.0;
    if (gKRScreenSize.x > gKRScreenSize.y) {
        angle = M_PI / 2;
    }
    mTex->draw(gKRScreenSize/2, KRRect2DZero, angle, mTex->getCenterPos(), KRVector2DOne, alpha);
}


