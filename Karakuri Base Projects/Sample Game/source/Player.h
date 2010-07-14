/*!
    @file   Player.h
    @author ___FULLUSERNAME___
    @date   ___DATE___
    
    Player class, which attacks enemies.
 */

#pragma once

#include <Karakuri/Karakuri.h>


/*
    Please notice that KRChara2D should not be deleted manually.
 */
class Player : public KRChara2D {
    
public:
	Player();
	virtual ~Player();
    
public:
    void    grab(bool flag);
    
};

