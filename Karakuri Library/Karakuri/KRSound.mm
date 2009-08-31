/*
 *  KRSound.cpp
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/23.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#include <Karakuri/KRSound.h>

#import <Karakuri/KarakuriSound.h>


static KRVector3D   sListenerPos            = KRVector3DZero;


float KRSound::getListenerHorizontalOrientation()
{
    return [KarakuriSound listenerHorizontalOrientation];
}

void KRSound::setListenerHorizontalOrientation(float radAngle)
{
    [KarakuriSound setListenerHorizontalOrientation:radAngle];
}

KRVector3D KRSound::getListenerPos()
{
    return sListenerPos;
}

void KRSound::setListenerPos(float x, float y, float z)
{
    sListenerPos.x = x;
    sListenerPos.y = y;
    sListenerPos.z = z;
    [KarakuriSound setListenerX:x y:y z:z];
}

void KRSound::setListenerPos(const KRVector3D &vec3)
{
    setListenerPos(vec3.x, vec3.y, vec3.z);
}

KRSound::KRSound(const std::string& filename, bool doLoop)
{
    mFileName = filename;
    mDoLoop = doLoop;
 
    mSourcePos = KRVector3DZero;
    
    // Get the path
    NSString *filenameStr = [NSString stringWithCString:filename.c_str() encoding:NSUTF8StringEncoding];
    mSoundImpl = [[KarakuriSound alloc] initWithName:filenameStr doLoop:(doLoop? YES: NO)];    
}

KRSound::~KRSound()
{
    [(KarakuriSound *)mSoundImpl release];
}

bool KRSound::isPlaying() const
{
    return [(KarakuriSound *)mSoundImpl isPlaying];
}

void KRSound::play()
{
    [(KarakuriSound *)mSoundImpl play];
}

void KRSound::stop()
{
    [(KarakuriSound *)mSoundImpl stop];
}

KRVector3D KRSound::getSourcePos() const
{
    return mSourcePos;
}

void KRSound::setSourcePos(const KRVector3D &vec3)
{
    mSourcePos = vec3;
    [(KarakuriSound *)mSoundImpl setSourceX:vec3.x y:vec3.y z:vec3.z];
}

float KRSound::getPitch() const
{
    return [(KarakuriSound *)mSoundImpl pitch];
}

void KRSound::setPitch(float value)
{
    [(KarakuriSound *)mSoundImpl setPitch:value];
}

float KRSound::getVolume() const
{
    return [(KarakuriSound *)mSoundImpl volume];
}

void KRSound::setVolume(float value)
{
    [(KarakuriSound *)mSoundImpl setVolume:value];
}

std::string KRSound::to_s() const
{
    return "<sound>(file=\"" + mFileName + "\", loop=" + (mDoLoop? "true": "false") + ")";
}



