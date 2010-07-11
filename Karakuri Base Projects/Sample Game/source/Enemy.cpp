/*!
    @file   Enemy.cpp
    @author numata
    @date   10/02/19
 */

#include "Enemy.h"
#include "Globals.h"


Enemy::Enemy(int charaSpecID)
    : KRChara2D(charaSpecID, CharaType::Enemy)
{
    setZOrder(0);

    // Make this character visible (initial state = -1)
    changeMotion(0);
}

Enemy::~Enemy()
{
    // Do nothing
}


