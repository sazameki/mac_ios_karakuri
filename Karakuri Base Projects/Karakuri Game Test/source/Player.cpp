/*!
    @file   Player.cpp
    @author numata
    @date   10/02/19
 */

#include "Player.h"
#include "Globals.h"


Player::Player()
    : KRChara2D(CharaID::Player, CharaType::Player)
{
    setZOrder(1);
    
    // Make this character visible (initial state = -1)
    changeMotion(0);
}

Player::~Player()
{
    // Do nothing
}

void Player::grab(bool flag)
{
    // Save the center position
    KRVector2D centerPos = getCenterPos();

    // Change the scale
    if (flag) {
        setScale(KRVector2D(1.5, 1.5));        
    } else {        
        setScale(KRVector2D(1.0, 1.0));        
    }

    // Restore the center position
    setCenterPos(centerPos);
}


