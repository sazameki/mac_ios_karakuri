/*
 *  KRSimulator3D.h
 *  Karakuri Library
 *
 *  Created by numata on 09/08/20.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>


class KRSimulator3D : public KRObject {
    
private:
    KRVector3D  mGravity;
    
    void        *mDynamicsWorld;
    void        *mSolver;
    void        *mOverlappingPairCache;
    void        *mCollisionConfiguration;
    void        *mDispatcher;
    
public:
	KRSimulator3D(const KRVector3D& gravity);
	virtual ~KRSimulator3D();
    
public:
    void    step();
    void    step(float time);

public:
    void    setGravity(const KRVector3D& gravity);
    
public:
    virtual std::string to_s() const;

};


