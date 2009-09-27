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

void KRWorld::startBecameActive()
{
    mIsControlProcessEnabled = true;

    mControlManager = new KRControlManager();

    becameActive();
}

void KRWorld::startResignedActive()
{    
    resignedActive();

    delete mControlManager;
    mControlManager = NULL;
}

void KRWorld::startUpdateModel(KRInput *input)
{
    mHasProcessedControl = false;
    if (mIsControlProcessEnabled && mControlManager->updateControls(input)) {
        mHasProcessedControl = true;
    }

    updateModel(input);
}

void KRWorld::startDrawView(KRGraphics *g)
{
    drawView(g);
    
    mControlManager->drawAllControls(g);
}


#pragma mark -

std::string KRWorld::getLoadingScreenWorldName() const
{
    return "";
}

void KRWorld::saveForEmergency(KRSaveBox *saveBox)
{
    // Do nothing
}


#pragma mark -

void KRWorld::addControl(KRControl *aControl)
{
    aControl->setWorld(this);
    mControlManager->addControl(aControl);
}

void KRWorld::removeControl(KRControl *aControl)
{
    mControlManager->removeControl(aControl);
    aControl->setWorld(NULL);
}

bool KRWorld::hasProcessedControl() const
{
    return mHasProcessedControl;
}

void KRWorld::startControlProcess()
{
    mIsControlProcessEnabled = true;
}

void KRWorld::stopControlProcess()
{
    mIsControlProcessEnabled = false;
}

void KRWorld::buttonPressed(KRButton *aButton)
{
    // Do nothing
}

void KRWorld::sliderValueChanged(KRSlider *slider)
{
    // Do nothing
}

void KRWorld::switchStateChanged(KRSwitch *switcher)
{
    // Do nothing
}


#pragma mark -
#pragma mark Debug Support

std::string KRWorld::getName() const
{
    return mName;
}

void KRWorld::setName(const std::string& str)
{
    mName = str;
}

std::string KRWorld::to_s() const
{
    return "<world>(name=\"" + mName + "\")";
}

