/*
 *  Enemy.h
 *  Karakuri Game Test
 *
 *  Created by numata on 10/07/09.
 *  Copyright 2010 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include <Karakuri/Karakuri.h>


class Enemy : public KRChara2D {

public:
	Enemy(int charaSpecID);
	virtual ~Enemy();
    
public:
    virtual void    move() = 0;

};

