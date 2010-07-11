/*!
    @file   Enemy2.h
    @author ___FULLUSERNAME___
    @date   ___DATE___
 
    Enemy class, which moves vertically.
 */

#pragma once

#include "Enemy.h"


class Enemy2 : public Enemy {
    
    int     mDirection;
    
public:
    Enemy2();
    virtual ~Enemy2();
    
public:
    virtual void    move();
    
};

