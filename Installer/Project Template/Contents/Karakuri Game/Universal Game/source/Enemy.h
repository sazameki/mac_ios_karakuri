/*!
    @file   Enemy.h
    @author ___FULLUSERNAME___
    @date   ___DATE___
 
    Base class of enemy classes.
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

