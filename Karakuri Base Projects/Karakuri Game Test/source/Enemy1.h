/*
 *  Enemy1.h
 *  Karakuri Game Test
 *
 *  Created by numata on 10/07/09.
 *  Copyright 2010 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include "Enemy.h"


class Enemy1 : public Enemy {
    
public:
    Enemy1();
    virtual ~Enemy1();

public:
    virtual void    move();

};

