/*!
    @file   LogoWorld.h
    @author numata
    @date   10/02/13

    Please write the description of this world.
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


