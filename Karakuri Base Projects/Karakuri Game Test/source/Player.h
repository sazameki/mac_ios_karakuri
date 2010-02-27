/*!
    @file   Player.h
    @author numata
    @date   10/02/19
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/Karakuri.h>


class Player {

    KRChara2D*  mChara;
    
public:
	Player();
	virtual ~Player();
    
public:
    void    move(KRInput* input);
    
};

