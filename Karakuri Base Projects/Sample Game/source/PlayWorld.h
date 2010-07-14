/*!
    @file   PlayWorld.h
    @author ___FULLUSERNAME___
    @date   ___DATE___

    Game play world.
 */

#pragma once

#include <Karakuri/Karakuri.h>
#include "Player.h"
#include "Enemy.h"


class PlayWorld : public KRWorld {
    
    KRLabel*            mScoreLabel;

    Player*             mDraggingPlayer;
    std::list<Enemy*>   mEnemies;    

    int                 mScore;
    
public:
    virtual void    becameActive();
    virtual void    resignedActive();
    virtual void    updateModel(KRInput* input);
    virtual void    drawView(KRGraphics* g);

    //virtual void    buttonPressed(KRButton* aButton);
    //virtual void    sliderValueChanged(KRSlider* slider);    
    //virtual void    switchStateChanged(KRSwitch* switcher);

};

