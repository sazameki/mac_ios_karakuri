/*
 *  Enemy1.cpp
 *  Karakuri Game Test
 *
 *  Created by numata on 10/07/09.
 *  Copyright 2010 Satoshi Numata. All rights reserved.
 *
 */

#include "Enemy1.h"
#include "Globals.h"


Enemy1::Enemy1()
    : Enemy(CharaID::Enemy1)
{
}

Enemy1::~Enemy1()
{
}

void Enemy1::move()
{
    KRVector2D pos = getPos();
    
    pos.x += 0.1;
    
    setPos(pos);
}


