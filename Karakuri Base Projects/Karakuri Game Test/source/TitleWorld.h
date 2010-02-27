/*!
    @file   TitleWorld.h
    @author numata
    @date   10/02/13
    
    Please write the description of this world.
 */

#pragma once

#include <Karakuri/Karakuri.h>


class TitleWorld : public KRWorld {
    
public:
    virtual void    becameActive();
    virtual void    resignedActive();
    virtual void    updateModel(KRInput* input);
    virtual void    drawView(KRGraphics* g);

};

