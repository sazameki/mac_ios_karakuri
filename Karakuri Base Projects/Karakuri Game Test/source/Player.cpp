/*!
    @file   Player.cpp
    @author numata
    @date   10/02/19
 */

#include "Player.h"


Player::Player()
{
    mChara = gKRAnime2DMan->createChara2D(0, KRVector2D(0, 0), 0, 0, this);
}

Player::~Player()
{
    gKRAnime2DMan->removeChara2D(mChara);
}

void Player::move(KRInput* input)
{
#if KR_MACOSX
    if (input->isKeyDown(KRInput::KeyLeft)) {
        mChara->pos.x -= 2;
    }
    if (input->isKeyDown(KRInput::KeyRight)) {
        mChara->pos.x += 2;
    }
    
    bool keyUp = input->isKeyDown(KRInput::KeyUp);
    bool keyDown = input->isKeyDown(KRInput::KeyDown);
    
    if (keyUp && !keyDown) {
        mChara->changeState(1);
        mChara->pos.y += 2;
    } else if (keyDown && !keyUp) {
        mChara->changeState(2);
        mChara->pos.y -= 2;
    } else if (!keyDown && !keyUp) {
        mChara->changeState(0);
    }
    
    if (input->isKeyDown(KRInput::KeyA)) {
        mChara->scale -= 0.1;
    }

    if (input->isKeyDown(KRInput::KeyS)) {
        mChara->scale += 0.1;
    }
#endif

#if KR_IPHONE
    KRVector3D acc = input->getAcceleration();
    mPos.x += acc.x * 8;
    mPos.y += acc.y * 8;
#endif    
}


