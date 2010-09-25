/*
 *  KRWorldManager.h
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/23.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>


class KRWorld;


class KRWorldManager : public KRObject {
    
private:
    KRWorld*                        mCurrentWorld;
    std::map<std::string, KRWorld*> mWorldMap;
    
public:
    KRWorldManager();
    ~KRWorldManager();

public:
    KRWorld*    getCurrentWorld() const;
    void        registerWorld(const std::string& name, KRWorld* aWorld);
    KRWorld*    getWorldWithName(const std::string &name);
    KRWorld*    selectWorldWithName(const std::string &name, bool useLoadingThread);

    
#pragma mark -
#pragma mark Debug Support

public:
    std::string     to_s() const;

};


extern KRWorldManager*  gKRWorldManagerInst;


