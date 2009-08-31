/*
 *  KRSimulator3D.cpp
 *  Karakuri Library
 *
 *  Created by numata on 09/08/20.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#include "KRSimulator3D.h"

#include <Karakuri/KarakuriGame.h>
#include <Karakuri/bullet/btBulletDynamicsCommon.h>


KRSimulator3D::KRSimulator3D(const KRVector3D& gravity)
{
    mCollisionConfiguration = new btDefaultCollisionConfiguration();
	mDispatcher = new btCollisionDispatcher((btDefaultCollisionConfiguration *)mCollisionConfiguration);

    btVector3 worldAabbMin(-10000, -10000, -10000);
	btVector3 worldAabbMax(10000, 10000, 10000);
	int	maxProxies = 1024;
	mOverlappingPairCache = new btAxisSweep3(worldAabbMin, worldAabbMax, maxProxies);

    mSolver = new btSequentialImpulseConstraintSolver();

    mDynamicsWorld = new btDiscreteDynamicsWorld((btCollisionDispatcher *)mDispatcher,
                                                 (btAxisSweep3 *)mOverlappingPairCache,
                                                 (btSequentialImpulseConstraintSolver *)mSolver,
                                                 (btDefaultCollisionConfiguration *)mCollisionConfiguration);
    
    setGravity(gravity);
}

KRSimulator3D::~KRSimulator3D()
{
    delete (btDynamicsWorld *)mDynamicsWorld;
    delete (btSequentialImpulseConstraintSolver *)mSolver;
    delete (btAxisSweep3 *)mOverlappingPairCache;
    delete (btCollisionDispatcher *)mDispatcher;
    delete (btCollisionDispatcher *)mCollisionConfiguration;
}

void KRSimulator3D::step()
{
    step(1.0f / KRGame->getFrameRate());    
}

void KRSimulator3D::step(float time)
{
    ((btDynamicsWorld *)mDynamicsWorld)->stepSimulation(time);
}

void KRSimulator3D::setGravity(const KRVector3D& gravity)
{
    mGravity = gravity;
    ((btDynamicsWorld *)mDynamicsWorld)->setGravity(btVector3(gravity.x, gravity.y, gravity.z));
}

std::string KRSimulator3D::to_s() const
{
    return "<simulator3d>";
}



