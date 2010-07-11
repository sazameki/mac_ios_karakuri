/*!
    @file   Enemy1.h
    @author numata
    @date   10/02/19
 
    Please write the description of this class.
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

