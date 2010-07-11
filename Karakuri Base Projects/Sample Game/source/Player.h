/*!
    @file   Player.h
    @author numata
    @date   10/02/19
    
    Please write the description of this class.
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

