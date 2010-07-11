/*!
    @file   Enemy2.cpp
    @author numata
    @date   10/02/19
 */

#include "Enemy2.h"
#include "Globals.h"


Enemy2::Enemy2()
    : Enemy(CharaID::Enemy2)
{
    mDirection = 1;
}

Enemy2::~Enemy2()
{
}

void Enemy2::move()
{
    KRVector2D pos = getPos();
    
    pos.y += 0.2 * mDirection;
    
    if (pos.y < 20) {
        mDirection *= -1;
        pos.y = 20;
    }
    else if (pos.y > 300) {
        mDirection *= -1;
        pos.y = 300;
    }
    
    setPos(pos);
}



