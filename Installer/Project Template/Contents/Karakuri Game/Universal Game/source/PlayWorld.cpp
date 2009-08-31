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

    mPos = (KRScreenSize - mTex->getSize()) / 2;
    
#if KR_IPHONE
    KRInputInst->enableAccelerometer(true);
#endif
}

void PlayWorld::resignedActive()
{
    delete mTex;
    
#if KR_IPHONE
    KRInputInst->enableAccelerometer(false);
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
        mPos = input->getMouseLocation() - mTex->getCenterPos();
    }
#endif
    
#if KR_IPHONE
    KRVector3D acc = input->getAcceleration();
    mPos.x += acc.x * 8;
    mPos.y += acc.y * 8;
#endif
    
    if (mPos.x < 0.0f) {
        mPos.x = 0.0f;
    } else if (mPos.x >= KRScreenSize.x - mTex->getWidth()) {
        mPos.x = KRScreenSize.x - 1.0f - mTex->getWidth();
    }

    if (mPos.y < 0.0f) {
        mPos.y = 0.0f;
    } else if (mPos.y >= KRScreenSize.y - mTex->getHeight()) {
        mPos.y = KRScreenSize.y - 1.0f - mTex->getHeight();
    }
}

void PlayWorld::drawView(KRGraphics *g)
{
    g->clear(KRColor::CornflowerBlue);
    
    mTex->draw(mPos);
}


