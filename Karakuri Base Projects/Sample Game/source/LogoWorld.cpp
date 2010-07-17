/*!
    @file   LogoWorld.cpp
    @author ___FULLUSERNAME___
    @date   ___DATE___
 */

#include "LogoWorld.h"
#include "Globals.h"


void LogoWorld::becameActive()
{
    mCount = 150;
}

void LogoWorld::resignedActive()
{
    // Do nothing
}

void LogoWorld::updateModel(KRInput* input)
{
    mCount--;
    if (mCount == 0) {
        gKRGameMan->changeWorld("title");
    }
}

void LogoWorld::drawView(KRGraphics* g)
{
    g->clear(KRColor::White);
    
    double alpha = (double)mCount / 100;
    if (alpha > 1.0) {
        alpha = 1.0;
    }

    if (KRCheckDeviceType(KRDeviceTypeIPad)) {
        gKRTex2DMan->drawAtPoint(TexID::Logo, KRVector2DZero, alpha);
    } else {
        double angle = 0;
        if (gKRScreenSize.x > gKRScreenSize.y) {
            angle = M_PI_2;
        }
        
        gKRTex2DMan->drawAtPointCenterEx(TexID::Logo, gKRScreenSize/2, angle, KRVector2DOne, alpha);
    }

    // We don't use animation mechanism at the logo world.
    gKRAnime2DMan->draw();
}


