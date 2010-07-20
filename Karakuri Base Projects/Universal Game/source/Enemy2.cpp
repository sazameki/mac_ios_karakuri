/*!
    @file   Enemy2.cpp
    @author ___FULLUSERNAME___
    @date   ___DATE___
 */

#include "Enemy2.h"
#include "Globals.h"


Enemy2::Enemy2()
    : Enemy(CharaID::EnemyIce)
{
    // Z-Order is very important for effective drawing.
    // It is recommended that the same type of character has the same Z-Order.
    setZOrder(2);

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
    else if (pos.y > gKRScreenSize.y-20) {
        mDirection *= -1;
        pos.y = gKRScreenSize.y-20;
    }
    
    setPos(pos);
}



