/*!
    @file   PlayWorld.cpp
    @author ___FULLUSERNAME___
    @date   ___DATE___
 */

#include "PlayWorld.h"


/*
std::string PlayWorld::getLoadingScreenWorldName() const
{
    return "";
}
*/

void PlayWorld::becameActive()
{
    mTex = new KRTexture2D("chara.png");

    mPos = gKRScreenSize / 2;
    
#if KR_IPHONE
    gKRInputInst->enableAccelerometer(true);
#endif
}

void PlayWorld::resignedActive()
{
    delete mTex;
    
#if KR_IPHONE
    gKRInputInst->enableAccelerometer(false);
#endif
}

void PlayWorld::updateModel(KRInput *input)
{
#if KR_MACOSX
    KRKeyState keyState = input->getKeyState();

    if (keyState & KRInput::KeyUp) {
        mPos.y += 2;
    }
    if (keyState & KRInput::KeyDown) {
        mPos.y -= 2;
    }
    if (keyState & KRInput::KeyLeft) {
        mPos.x -= 2;
    }
    if (keyState & KRInput::KeyRight) {
        mPos.x += 2;
    }
    
    if (input->getMouseState() & KRInput::MouseButtonAny) {
        mPos = input->getMouseLocation();
    }
#endif
    
#if KR_IPHONE
    KRVector3D acc = input->getAcceleration();
    mPos.x += acc.x * 8;
    mPos.y += acc.y * 8;
#endif
    
    if (mPos.x < mTex->getWidth() / 2) {
        mPos.x = mTex->getWidth() / 2;
    } else if (mPos.x >= gKRScreenSize.x - mTex->getWidth() / 2) {
        mPos.x = gKRScreenSize.x - 1.0 - mTex->getWidth() / 2;
    }

    if (mPos.y < mTex->getWidth() / 2) {
        mPos.y = mTex->getWidth() / 2;
    } else if (mPos.y >= gKRScreenSize.y - mTex->getHeight() / 2) {
        mPos.y = gKRScreenSize.y - 1.0 - mTex->getHeight() / 2;
    }
}

void PlayWorld::drawView(KRGraphics *g)
{
    g->clear(KRColor::CornflowerBlue);
    
    mTex->drawAtPointCenter(mPos);
}


