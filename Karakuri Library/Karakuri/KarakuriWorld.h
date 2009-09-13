//
//  KarakuriWorld.h
//  Karakuri Prototype
//
//  Created by numata on 09/07/23.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#pragma once

#include <Karakuri/KarakuriLibrary.h>

#include <Karakuri/KRInput.h>
#include <Karakuri/KRGraphics.h>
#include <Karakuri/KRSaveBox.h>


class KRControlManager;
class KRControl;
class KRButton;
class KRSlider;
class KRSwitch;


/*!
    @class KarakuriWorld
    @group  Game Foundation
 */
class KarakuriWorld : public KRObject {
    
private:
    std::string         mName;
    KRControlManager    *mControlManager;
    bool                mHasProcessedControl;
    bool                mIsControlProcessEnabled;
    
public:
    virtual std::string getLoadingScreenWorldName() const;

    void    startBecameActive();
    void    startResignedActive();
    void    startUpdateModel(KRInput *input);
    void    startDrawView(KRGraphics *g);

    virtual void    becameActive() = 0;
    virtual void    resignedActive() = 0;
    virtual void    updateModel(KRInput *input) = 0;
    virtual void    drawView(KRGraphics *g) = 0;

    virtual void    saveForEmergency(KRSaveBox *saveBox);
    
#pragma mark -
#pragma mark Control Support
public:
    void    addControl(KRControl *aControl);
    void    removeControl(KRControl *aControl);
    bool    hasProcessedControl() const;
    void    startControlProcess();
    void    stopControlProcess();
    
    virtual void    buttonPressed(KRButton *aButton);
    virtual void    sliderValueChanged(KRSlider *slider);
    virtual void    switchStateChanged(KRSwitch *switcher);

#pragma mark -
#pragma mark Debug Support

public:
    std::string     getName() const KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void            setName(const std::string& str) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    std::string     to_s() const;

};

