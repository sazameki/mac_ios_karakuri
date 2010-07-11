/*!
    @file   Enemy.h
    @author numata
    @date   10/02/19
 
    Please write the description of this class.
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

