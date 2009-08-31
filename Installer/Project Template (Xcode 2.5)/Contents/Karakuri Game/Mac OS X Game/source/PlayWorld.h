/*!
    @file   PlayWorld.h
    @author ___FULLUSERNAME___
    @date   ___DATE___

    Please write the description of this world.
 */

#pragma once

#include <Karakuri/Karakuri.h>


class PlayWorld : public KarakuriWorld {
    
    KRTexture2D     *mTex;
    KRVector2D      mPos;
    
public:
    //virtual std::string getLoadingScreenWorldName() const;

    virtual void    becameActive();
    virtual void    resignedActive();
    virtual void    updateModel(KRInput *input);
    virtual void    drawView(KRGraphics *g);

};

