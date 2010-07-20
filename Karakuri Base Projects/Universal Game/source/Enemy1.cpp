/*!
    @file   Enemy1.cpp
    @author ___FULLUSERNAME___
    @date   ___DATE___
 */

#include "Enemy1.h"
#include "Globals.h"


Enemy1::Enemy1()
    : Enemy(CharaID::EnemyThunder)
{
    // Z-Order is very important for effective drawing.
    // It is recommended that the same type of character has the same Z-Order.
    setZOrder(1);

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
    else if (pos.x > gKRScreenSize.x-20) {
        mDirection *= -1;
        pos.x = gKRScreenSize.x-20;
    }
    
    setPos(pos);
}


