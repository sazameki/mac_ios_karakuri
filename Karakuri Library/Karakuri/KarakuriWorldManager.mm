/*
 *  KarakuriWorldManager.cpp
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/23.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#include "KarakuriWorldManager.h"

#include "KarakuriGame.h"
#include "KarakuriWorld.h"

#import "KarakuriController.h"


KarakuriWorldManager *KRWorldManagerInst = NULL;


KarakuriWorldManager::KarakuriWorldManager()
    : mCurrentWorld(NULL)
{
    KRWorldManagerInst = this;
}


KarakuriWorldManager::~KarakuriWorldManager()
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

KRWorld *KarakuriWorldManager::getCurrentWorld() const
{
    return mCurrentWorld;
}

void KarakuriWorldManager::registerWorld(const std::string& name, KRWorld *aWorld)
{
    aWorld->setName(name);
    mWorldMap[name] = aWorld;
}

KRWorld *KarakuriWorldManager::getWorldWithName(const std::string &name)
{
    return mWorldMap[name];
}

KRWorld *KarakuriWorldManager::selectWorldWithName(const std::string &name, bool useLoadingThread)
{
    KRWorld *world = getWorldWithName(name);
    if (world == NULL) {
        return NULL;
    }
    gKRGameInst->startWorldChanging();
    if (mCurrentWorld != NULL) {
        mCurrentWorld->startResignedActive();
    }

    mCurrentWorld = world;
    
    if (useLoadingThread) {
        [[KarakuriController sharedController] startChaningWorld:mCurrentWorld];
    } else {
        mCurrentWorld->startBecameActive();
    }

    return world;
}

std::string KarakuriWorldManager::to_s() const
{
    return "<wmanager>()";
}




