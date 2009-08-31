/*
 *  KRSound.h
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/23.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>


class KRSound : public KRObject {
    
private:
    std::string mFileName;
    void        *mSoundImpl;
    KRVector3D  mSourcePos;
    bool        mDoLoop;

public:
    static  float       getListenerHorizontalOrientation();
    static  void        setListenerHorizontalOrientation(float radAngle);
    static  KRVector3D  getListenerPos();
    static  void        setListenerPos(float x, float y, float z);
    static  void        setListenerPos(const KRVector3D &vec3);

public:
    KRSound(const std::string& filename, bool doLoop = false);
    ~KRSound();
    
public:
    void        play();
    void        stop();

    bool        isPlaying() const;
    
    KRVector3D  getSourcePos() const;
    void        setSourcePos(const KRVector3D &vec3);

    float       getPitch() const;
    void        setPitch(float value);

    float       getVolume() const;
    void        setVolume(float value);
    
#pragma mark -
#pragma mark Debug Support

public:
    std::string to_s() const;

};


