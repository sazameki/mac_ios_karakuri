/*!
    @file   LogoWorld.h
    @author ___FULLUSERNAME___
    @date   ___DATE___

    Logo world.
 */

#pragma once

#include <Karakuri/Karakuri.h>


class LogoWorld : public KRWorld {

    int             mCount;
    
public:
    virtual void    becameActive();
    virtual void    resignedActive();
    virtual void    updateModel(KRInput* input);
    virtual void    drawView(KRGraphics* g);
    
    //virtual void    buttonPressed(KRButton* aButton);
    //virtual void    sliderValueChanged(KRSlider* slider);    
    //virtual void    switchStateChanged(KRSwitch* switcher);
    
};


