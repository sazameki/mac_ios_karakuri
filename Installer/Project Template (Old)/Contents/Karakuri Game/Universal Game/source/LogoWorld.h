/*!
    @file   LogoWorld.h
    @author ___FULLUSERNAME___
    @date   ___DATE___

    Please write the description of this world.
 */

#pragma once

#include <Karakuri/Karakuri.h>


class LogoWorld : public KRWorld {

    KRTexture2D     *mTex;
    int             mCount;
    
public:
    //virtual std::string getLoadingScreenWorldName() const;

    virtual void    becameActive();
    virtual void    resignedActive();
    virtual void    updateModel(KRInput *input);
    virtual void    drawView(KRGraphics *g);
    
};


