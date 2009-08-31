//
//  KarakuriWorld.cpp
//  Karakuri Prototype
//
//  Created by numata on 09/07/23.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#include <Karakuri/KarakuriWorld.h>

#include <Karakuri/KRControlManager.h>

#import "KarakuriController.h"


#pragma mark -
#pragma mark Pre-process World Management

void KarakuriWorld::startBecameActive()
{
    mIsControlProcessEnabled = true;

    mControlManager = new KRControlManager();

    becameActive();
}

void KarakuriWorld::startResignedActive()
{    
    resignedActive();

    delete mControlManager;
    mControlManager = NULL;
}

void KarakuriWorld::startUpdateModel(KRInput *input)
{
    mHasProcessedControl = false;
    if (mIsControlProcessEnabled && mControlManager->updateControls(input)) {
        mHasProcessedControl = true;
    }

    updateModel(input);
}

void KarakuriWorld::startDrawView(KRGraphics *g)
{
    drawView(g);
    
    mControlManager->drawAllControls(g);
}


#pragma mark -

std::string KarakuriWorld::getLoadingScreenWorldName() const
{
    return "";
}

void KarakuriWorld::saveForEmergency(KRSaveBox *saveBox)
{
    // Do nothing
}


#pragma mark -

void KarakuriWorld::addControl(KRControl *aControl)
{
    aControl->setWorld(this);
    mControlManager->addControl(aControl);
}

void KarakuriWorld::removeControl(KRControl *aControl)
{
    mControlManager->removeControl(aControl);
    aControl->setWorld(NULL);
}

bool KarakuriWorld::hasProcessedControl() const
{
    return mHasProcessedControl;
}

void KarakuriWorld::startControlProcess()
{
    mIsControlProcessEnabled = true;
}

void KarakuriWorld::stopControlProcess()
{
    mIsControlProcessEnabled = false;
}

void KarakuriWorld::buttonPressed(KRButton *aButton)
{
    // Do nothing
}

void KarakuriWorld::sliderValueChanged(KRSlider *slider)
{
    // Do nothing
}

void KarakuriWorld::switchStateChanged(KRSwitch *switcher)
{
    // Do nothing
}


#pragma mark -
#pragma mark Debug Support

std::string KarakuriWorld::getName() const
{
    return mName;
}

void KarakuriWorld::setName(const std::string& str)
{
    mName = str;
}

std::string KarakuriWorld::to_s() const
{
    return "<world>(name=\"" + mName + "\")";
}

