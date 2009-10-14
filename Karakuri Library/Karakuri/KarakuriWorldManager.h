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


class KRWorld;

class KarakuriWorldManager : public KRObject {
    
private:
    KRWorld *mCurrentWorld;
    std::map<std::string, KRWorld *> mWorldMap;
    
public:
    KarakuriWorldManager();
    ~KarakuriWorldManager();

public:
    KRWorld     *getCurrentWorld() const;
    void        registerWorld(const std::string& name, KRWorld *aWorld);
    KRWorld     *getWorldWithName(const std::string &name);
    KRWorld     *selectWorldWithName(const std::string &name, bool useLoadingThread);

    
#pragma mark -
#pragma mark Debug Support

public:
    std::string     to_s() const;

};

