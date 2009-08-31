/*
 *  KarakuriWorldManager.h
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/23.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>


class KarakuriWorld;

class KarakuriWorldManager : public KRObject {
    
private:
    KarakuriWorld *mCurrentWorld;
    std::map<std::string, KarakuriWorld *> mWorldMap;
    
public:
    KarakuriWorldManager();
    ~KarakuriWorldManager();

public:
    KarakuriWorld   *getCurrentWorld() const;
    void            registerWorld(const std::string& name, KarakuriWorld *aWorld);
    KarakuriWorld   *getWorldWithName(const std::string &name);
    KarakuriWorld   *selectWorldWithName(const std::string &name, bool useLoadingThread);

    
#pragma mark -
#pragma mark Debug Support

public:
    std::string     to_s() const;

};

extern KarakuriWorldManager *KRWorldManagerInst;

