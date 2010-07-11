/*!
    @file   Enemy2.h
    @author numata
    @date   10/02/19
 
    Please write the description of this class.
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

