/*!
    @file   Player.cpp
    @author numata
    @date   10/02/19
 */

#include "Player.h"


Player::Player()
{
    mChara = gKRAnime2DMan->createChara2D(10, KRVector2D(0, 0), 1, 0, this);
}

Player::~Player()
{
    gKRAnime2DMan->removeChara2D(mChara);
}

void Player::move(KRInput* input)
{
#if KR_MACOSX
    if (input->isMouseDown()) {
        mChara->pos = input->getMouseLocation();
    }
#endif

#if KR_IPHONE
    KRVector3D acc = input->getAcceleration();
    mChara->pos.x += acc.x * 8;
    mChara->pos.y += acc.y * 8;
    
    if (input->getTouch()) {
        mChara->pos = input->getLocation();
    }
#endif    
}


