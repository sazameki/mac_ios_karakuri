/*!
    @file   LoadingWorld.h
    @author ___FULLUSERNAME___
    @date   ___DATE___
    
    Please write the description of this world.
 */

#pragma once

#include <Karakuri/Karakuri.h>


class LoadingWorld : public KRWorld {
    
    int         mDirection;
    int         mCount;
    
public:
    virtual void    becameActive();
    virtual void    resignedActive();
    virtual void    updateModel(KRInput* input);
    virtual void    drawView(KRGraphics* g);

};

