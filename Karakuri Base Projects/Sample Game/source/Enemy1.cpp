/*!
    @file   Enemy1.cpp
    @author numata
    @date   10/02/19
 */

#include "Enemy1.h"
#include "Globals.h"


Enemy1::Enemy1()
    : Enemy(CharaID::Enemy1)
{
    mDirection = 1;
}

Enemy1::~Enemy1()
{
}

void Enemy1::move()
{
    KRVector2D pos = getPos();
    
    pos.x += 0.1 * mDirection;
    
    if (pos.x < 20) {
        mDirection *= -1;
        pos.x = 20;
    }
    else if (pos.x > 460) {
        mDirection *= -1;
        pos.x = 460;
    }
    
    setPos(pos);
}


