/*
 *  KRWorldManager.cpp
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/23.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#include "KRWorldManager.h"

#include "KRGameManager.h"
#include "KRWorld.h"

#import "KRGameController.h"


KRWorldManager *gKRWorldManagerInst = NULL;


KRWorldManager::KRWorldManager()
    : mCurrentWorld(NULL)
{
    gKRWorldManagerInst = this;
}


KRWorldManager::~KRWorldManager()
{
    if (mCurrentWorld != NULL) {
        mCurrentWorld->startResignedActive();
        mCurrentWorld = NULL;
    }
    std::map<std::string, KRWorld *>::iterator it = mWorldMap.begin();
	while (it != mWorldMap.end()) {
        delete (*it).second;
		it++;
	}
}

KRWorld *KRWorldManager::getCurrentWorld() const
{
    return mCurrentWorld;
}

void KRWorldManager::registerWorld(const std::string& name, KRWorld *aWorld)
{
    aWorld->setName(name);
    mWorldMap[name] = aWorld;
}

KRWorld *KRWorldManager::getWorldWithName(const std::string &name)
{
    return mWorldMap[name];
}

KRWorld *KRWorldManager::selectWorldWithName(const std::string &name, bool useLoadingThread)
{
    KRWorld *world = getWorldWithName(name);
    if (world == NULL) {
        return NULL;
    }
    gKRGameMan->startWorldChanging();
    if (mCurrentWorld != NULL) {
        mCurrentWorld->startResignedActive();
    }

    mCurrentWorld = world;
    
    if (useLoadingThread) {
        [[KRGameController sharedController] startChaningWorld:mCurrentWorld];
    } else {
        mCurrentWorld->startBecameActive();
    }

    return world;
}

std::string KRWorldManager::to_s() const
{
    return "<wmanager>()";
}




