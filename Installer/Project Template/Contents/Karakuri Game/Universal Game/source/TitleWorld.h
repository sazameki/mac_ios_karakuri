/*!
    @file   TitleWorld.h
    @author ___FULLUSERNAME___
    @date   ___DATE___
    
    Game title world.
 */

#pragma once

#include <Karakuri/Karakuri.h>


class TitleWorld : public KRWorld {
    
public:
    virtual void    becameActive();
    virtual void    resignedActive();
    virtual void    updateModel(KRInput* input);
    virtual void    drawView(KRGraphics* g);

    //virtual void    buttonPressed(KRButton* aButton);
    //virtual void    sliderValueChanged(KRSlider* slider);    
    //virtual void    switchStateChanged(KRSwitch* switcher);
    
};

