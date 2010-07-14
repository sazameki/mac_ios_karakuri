/*!
    @file   Enemy1.h
    @author ___FULLUSERNAME___
    @date   ___DATE___
 
    Enemy class, which moves horizontally.
 */

#pragma once

#include "Enemy.h"


class Enemy1 : public Enemy {
    
    int     mDirection;
    
public:
    Enemy1();
    virtual ~Enemy1();

public:
    virtual void    move();

};

