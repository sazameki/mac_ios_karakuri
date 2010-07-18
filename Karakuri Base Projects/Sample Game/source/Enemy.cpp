/*!
    @file   Enemy.cpp
    @author ___FULLUSERNAME___
    @date   ___DATE___
 */

#include "Enemy.h"
#include "Globals.h"


Enemy::Enemy(int charaSpecID)
    : KRChara2D(charaSpecID, CharaType::Enemy)
{
    // Make this character visible (initial state = -1)
    changeMotion(0);
}

Enemy::~Enemy()
{
    // Do nothing
}


