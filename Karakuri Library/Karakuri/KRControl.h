/*!
    @file   KRControl.h
    @author numata
    @date   09/08/28
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>
#include <Karakuri/KRGraphics.h>
#include <Karakuri/KRInput.h>
#include <Karakuri/KarakuriWorld.h>


/*!
    @class KRControl
    @group  Game Controls
 */
class KRControl {
    
protected:
    KarakuriWorld   *mWorld;

    bool        mEnabled;
    bool        mSelected;
    KRRect2D    mFrame;

public:
	KRControl(const KRRect2D& frame);
	virtual ~KRControl();
    
public:
    bool    contains(const KRVector2D& pos);
    
public:
    void            setWorld(KarakuriWorld *aWorld);
    virtual bool    update(KRInput *input) = 0;
    virtual void    draw(KRGraphics *g) = 0;
    
};

