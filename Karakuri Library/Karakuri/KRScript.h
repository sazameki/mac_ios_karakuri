/*
 *  KRScript.h
 *  Karakuri Library
 *
 *  Created by numata on 09/08/20.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>


class KRScript : KRObject {
    
    void    *mLuaState;
    
public:
    KRScript();
    virtual ~KRScript();
    
};



