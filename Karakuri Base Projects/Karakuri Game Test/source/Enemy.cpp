/*
 *  Enemy.cpp
 *  Karakuri Game Test
 *
 *  Created by numata on 10/07/09.
 *  Copyright 2010 Satoshi Numata. All rights reserved.
 *
 */

#include "Enemy.h"
#include "Globals.h"


Enemy::Enemy(int charaSpecID)
    : KRChara2D(charaSpecID, CharaType::Enemy)
{
    setZOrder(0);

    // Make this character visible (initial state = -1)
    changeState(0);
}

Enemy::~Enemy()
{
    // Do nothing
}


